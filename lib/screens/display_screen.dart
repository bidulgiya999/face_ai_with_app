import 'dart:io';
//import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'package:flutter/rendering.dart';
import '../services/storage_service.dart';
//import '../utils/error_handler.dart';
import '../utils/image_utils.dart';

/// 촬영된 사진을 표시하고 업로드하는 화면 위젯
/// - 촬영된 이미지 표시
/// - 이미지 업로드 기능
/// - 업로드 상태 표시
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final CameraLensDirection lensDirection;

  const DisplayPictureScreen({
    super.key, 
    required this.imagePath,
    required this.lensDirection,
  });

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

/// 화면의 상태 관리 클래스
/// - 스토리지 초기화
/// - 업로드 상태 관리
class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final StorageService _storageService = StorageService();
  bool _isUploading = false;
  String? _uploadedUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  /// 스토리지 서비스 초기화
  Future<void> _initializeStorage() async {
    try {
      await _storageService.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = '스토리지 초기화 실패: $e';
      });
    }
  }

  /// 이미지 업로드 처리
  /// - 전면 카메라 이미지 반전 처리
  /// - GCP 스토리지 업로드
  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      File imageFile = File(widget.imagePath);
      
      if (widget.lensDirection == CameraLensDirection.front) {
        imageFile = await ImageUtils.flipImage(imageFile);
      }

      final url = await _storageService.uploadImage(imageFile);
      setState(() {
        _uploadedUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '업로드 실패: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('촬영된 사진')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.zero,
            child: Transform.scale(
              scaleX: widget.lensDirection == CameraLensDirection.front ? -1.0 : 1.0,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_isUploading)
                  const CircularProgressIndicator()
                else if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red))
                else if (_uploadedUrl != null)
                  const Text('업로드 완료!', style: TextStyle(color: Colors.green))
                else
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: const Text('이미지 업로드'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 