import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path;

/// GCP 스토리지 서비스 클래스
/// - 스토리지 초기화
/// - 이미지 업로드
class StorageService {
  static const _bucketName = 'skindeep_project';
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
  Future<String?> uploadImage(File imageFile) async {
    try {
      final client = await clientViaServiceAccount(
        _credentials,
        [StorageApi.devstorageFullControlScope],
      );

      final storage = StorageApi(client);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'face_image_$timestamp$extension';

      final fileContent = await imageFile.readAsBytes();
      final media = Media(
        Stream.fromIterable([fileContent]),
        fileContent.length,
      );

      await storage.objects.insert(
        Object(name: fileName),
        _bucketName,
        uploadMedia: media,
      );

      return 'https://storage.googleapis.com/$_bucketName/$fileName';
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
} 