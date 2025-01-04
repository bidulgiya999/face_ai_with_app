import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/storage_service.dart';

class AnalysisResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const AnalysisResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final storageService = GetIt.I<StorageService>();

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      await storageService.initialize();
    } catch (e) {
      print('Storage initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 실제 받은 데이터 확인
    print('전체 응답 데이터: ${widget.result}');
    print('이미지 URL 목록: ${widget.result['result_images']}');

    final resultImages = widget.result['result_images'] as List<dynamic>;
    final frontResult = resultImages[0];
    print('첫 번째 이미지 URL: $frontResult');  // URL 형식 확인

    return Scaffold(
      appBar: AppBar(title: const Text('분석 결과')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('정면 분석 결과'),
            // 이미지 로드 실패 원인 확인
            Image.network(
              frontResult,
              errorBuilder: (context, error, stackTrace) {
                print('이미지 로드 실패: $error');
                return Text('이미지를 불러올 수 없습니다: $error');
              },
            ),
            const SizedBox(height: 16),
            
            Text('좌측면 분석 결과'),
            Image.network(resultImages[1]),
            const SizedBox(height: 16),
            
            Text('우측면 분석 결과'),
            Image.network(resultImages[2]),
          ],
        ),
      ),
    );
  }
} 