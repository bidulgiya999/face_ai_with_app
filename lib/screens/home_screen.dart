import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'camera_screen.dart';
import '../providers/camera_provider.dart';

/// 앱의 메인 화면
/// - 카메라 촬영 시작 버튼 표시
/// - 카메라 화면으로의 네비게이션 처리
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피부 분석 앱'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () async {
            try {
              // 사용 가능한 카메라 목록 가져오기
              final cameras = await availableCameras();
              
              // 전면 카메라 찾기
              final frontCamera = cameras.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.front,
                orElse: () => cameras.first, // 전면 카메라가 없으면 첫 번째 카메라 사용
              );
              
              if (!context.mounted) return;
              
              // CameraProvider 초기화
              final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
              await cameraProvider.initializeCamera(frontCamera);
              
              if (!context.mounted) return;
              
              // 카메라 화면으로 이동
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('카메라 초기화 실패: $e')),
              );
            }
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_front),
              SizedBox(width: 8),
              Text('얼굴 촬영하기'),
            ],
          ),
        ),
      ),
    );
  }
} 