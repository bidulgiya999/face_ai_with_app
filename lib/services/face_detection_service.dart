import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/face_detection_result.dart';

class FaceDetectionService {
  static const String _baseUrl = 'https://asia-northeast3-[PROJECT_ID].cloudfunctions.net/detect_faces';

  /// GCP에 업로드된 이미지들의 얼굴 영역을 감지
  Future<List<FaceDetectionResult>> detectFaces(List<String> imageUrls) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'images': imageUrls,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        return results
            .map((result) => FaceDetectionResult.fromJson(result))
            .toList();
      } else {
        throw Exception('Failed to detect faces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error detecting faces: $e');
    }
  }
} 