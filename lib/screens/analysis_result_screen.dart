import 'package:flutter/material.dart';
import '../models/yolo_result.dart';
import '../widgets/result_image_view.dart';

class AnalysisResultScreen extends StatelessWidget {
  final YOLOResult result;

  const AnalysisResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 결과'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      '피부 분석이 완료되었습니다',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ResultImageView(result: result),
              SizedBox(height: 20),
              Text(
                '감지된 객체',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              ...result.detections.map((detection) => Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(detection.className),
                  subtitle: Text('신뢰도: ${(detection.confidence * 100).toStringAsFixed(1)}%'),
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
} 