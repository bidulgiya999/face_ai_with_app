import 'dart:io';
//import 'dart:ui' as ui;
//import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// 이미지 처리 유틸리티 클래스
/// - 이미지 변환 기능
class ImageUtils {
  /// 이미지 좌우 반전 처리
  /// - 이미지 파일 읽기
  /// - 반전 처리 및 저장
  static Future<File> flipImage(File imageFile) async {
    // 이미지 파일 읽기
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Failed to decode image');

    // 이미지 좌우 반전
    final flippedImage = img.flipHorizontal(image);
    
    // 임시 파일 생성
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/flipped_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // 변환된 이미지 저장
    final flippedFile = File(tempPath);
    await flippedFile.writeAsBytes(img.encodeJpg(flippedImage));
    
    return flippedFile;
  }
} 