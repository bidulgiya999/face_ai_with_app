import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// 카메라 상태 관리 프로바이더
/// - 카메라 초기화 및 제어
/// - 카메라 전환
class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  CameraDescription? _currentCamera;
  List<CameraDescription> _cameras = [];

  CameraController? get controller => _controller;
  CameraDescription? get currentCamera => _currentCamera;

  /// 카메라 초기화
  Future<void> initializeCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _currentCamera = camera;
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// 카메라 목록 로드 및 초기화
  Future<void> loadCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final frontCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
        await initializeCamera(frontCamera);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 전/후면 카메라 전환
  Future<void> toggleCamera() async {
    if (_cameras.isEmpty) {
      await loadCameras();
      return;
    }

    try {
      final lensDirection = _currentCamera?.lensDirection;
      CameraDescription? newCamera;
      if (lensDirection == CameraLensDirection.front) {
        newCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
      } else {
        newCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
      }
      await initializeCamera(newCamera);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
} 