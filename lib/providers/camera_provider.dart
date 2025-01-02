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
  /// - 카메라 컨트롤러 생성 및 초기화
  Future<void> initializeCamera(CameraDescription camera) async {
    _currentCamera = camera;
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    await _controller?.initialize();
    notifyListeners();
  }

  /// 카메라 목록 로드 및 초기화
  Future<void> loadCameras() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      await initializeCamera(_cameras.first);
    }
  }

  /// 전/후면 카메라 전환
  Future<void> toggleCamera() async {
    if (_currentCamera == null) return;

    final lensDirection = _currentCamera!.lensDirection;
    CameraDescription newCamera;
    
    if (lensDirection == CameraLensDirection.back) {
      newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    }

    await _controller?.dispose();
    await initializeCamera(newCamera);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
} 