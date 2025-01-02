/// 카메라 화면 위젯
/// - 카메라 프리뷰 표시
/// - 전/후면 카메라 전환 기능
/// - 사진 촬영 기능
/// - 얼굴 인식 가이드 오버레이 표시

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/camera_provider.dart';
import '../widgets/oval_guide.dart';
import 'display_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cameraProvider.controller == null) {
        cameraProvider.loadCameras();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('사진 촬영')),
      body: cameraProvider.controller?.value.isInitialized ?? false
          ? Column(
              children: [
                Container(
                  padding: EdgeInsets.zero,
                  child: CameraPreview(
                    cameraProvider.controller!,
                    child: const OvalGuide(),
                  ),
                ),
                const Spacer(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: _buildActionButtons(context, cameraProvider),
    );
  }

  /// 카메라 화면의 액션 버튼들을 구성하는 메서드
  /// - 카메라 전환 버튼
  /// - 촬영 버튼
  Widget _buildActionButtons(BuildContext context, CameraProvider cameraProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'toggleCamera',
          onPressed: cameraProvider.toggleCamera,
          child: const Icon(Icons.flip_camera_ios),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'takePicture',
          onPressed: () => _takePicture(context, cameraProvider),
          child: const Icon(Icons.camera_alt),
        ),
      ],
    );
  }

  /// 사진 촬영 및 결과 화면 이동 처리
  /// - 사진 촬영
  /// - 촬영 결과 화면으로 이동
  Future<void> _takePicture(BuildContext context, CameraProvider cameraProvider) async {
    try {
      final image = await cameraProvider.controller?.takePicture();
      if (image == null || !context.mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
            lensDirection: cameraProvider.currentCamera!.lensDirection,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }
} 