import 'package:flutter/material.dart';
//import 'package:camera/camera.dart';
import 'camera_screen.dart';

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
            if (!context.mounted) return;
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CameraScreen(),
              ),
            );
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