import 'package:flutter/material.dart';
import '../models/yolo_result.dart';

class ResultImageView extends StatelessWidget {
  final YOLOResult result;

  const ResultImageView({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 원본 이미지
        Image.network(
          result.imageUrl,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircularProgressIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            return Text('Error loading image');
          },
        ),
        SizedBox(height: 16),
        // YOLO 결과 이미지
        Image.network(
          result.resultImageUrl,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircularProgressIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            return Text('Error loading result image');
          },
        ),
      ],
    );
  }
} 