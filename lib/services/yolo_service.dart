import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/yolo_result.dart';

class YOLOService {
  static const String _baseUrl = 'https://yolo-inference-sesac-1052278692063.us-central1.run.app';
  
  Future<YOLOResult> detectObjects(String? imageUrl) async {
    if (imageUrl == null) {
      throw Exception('Image URL cannot be null');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image_url': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        return YOLOResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to detect objects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error detecting objects: $e');
    }
  }
} 