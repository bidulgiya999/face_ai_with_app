import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

/// GCP 스토리지 서비스 클래스
/// - 스토리지 초기화
/// - 이미지 업로드
class StorageService {
  static const _bucketName = 'skindeep_project';
  // static const _resultBucketName = 'skindeep_project_result';
  late final ServiceAccountCredentials _credentials;

  /// 스토리지 서비스 초기화
  /// - 서비스 계정 인증
  Future<void> initialize() async {
    try {
      final serviceAccountJson = await rootBundle.loadString('assets/sesac-24-109.json');
      print('Service account JSON loaded: ${serviceAccountJson.substring(0, 100)}...');
      _credentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson)
      );
    } catch (e, stackTrace) {
      print('Storage initialization error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 이미지 파일 업로드
  /// - 파일 업로드 및 URL 반환
  Future<String?> uploadImage(File imageFile, {String? fileName}) async {
    try {
      // 이미지 로드 및 메타데이터 제거
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      
      // 새로운 이미지로 저장 (메타데이터 없이)
      final cleanImageFile = File(imageFile.path.replaceAll('.jpg', '_clean.jpg'));
      await cleanImageFile.writeAsBytes(img.encodeJpg(image));

      // 정리된 이미지 업로드
      final client = await clientViaServiceAccount(
        _credentials,
        [StorageApi.devstorageFullControlScope],
      );

      final storage = StorageApi(client);
      
      fileName ??= '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';

      final fileContent = await cleanImageFile.readAsBytes();
      final media = Media(
        Stream.fromIterable([fileContent]),
        fileContent.length,
      );

      await storage.objects.insert(
        Object(name: fileName),
        _bucketName,
        uploadMedia: media,
      );

      // 임시 파일 삭제
      await cleanImageFile.delete();

      return 'https://storage.googleapis.com/$_bucketName/$fileName';
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> requestAnalysis(Map<String, String> imageUrls) async {
    const cloudRunUrl = 'https://yolo-inference-sesac-hnvs3juqba-uc.a.run.app/analyze';
    
    try {
      print('Sending analysis request with URLs: $imageUrls');  // 요청 로깅
      
      final response = await http.post(
        Uri.parse(cloudRunUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'front_image': imageUrls['front'],
          'left_image': imageUrls['left'],
          'right_image': imageUrls['right'],
        }),
      );

      print('Received response with status: ${response.statusCode}');  // 응답 상태 로깅
      print('Response body: ${response.body}');  // 응답 내용 로깅

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('분석 요청 실패: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('분석 요청 오류: $e');
      rethrow;
    }
  }

  Future<String> getSignedUrl(String gcsUrl) async {
    try {
      final publicUrl = gcsUrl.replaceFirst('gs://', 'https://storage.googleapis.com/');
      print('Accessing result image at: $publicUrl');  // 디버깅용
      return publicUrl;
    } catch (e) {
      print('Error getting URL: $e');
      rethrow;
    }
  }
} 