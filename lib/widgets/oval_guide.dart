import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 얼굴 인식 가이드 위젯
/// - 타원형 가이드 그리기
/// - 가이드 텍스트 표시
/// - 위치 및 크기 계산
class OvalGuide extends StatelessWidget {
  const OvalGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: OvalPainter(),
      child: Container(),
    );
  }
}

class OvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawOval(canvas, size);
    _drawGuidanceText(canvas, size);
  }

  void _drawOval(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConstants.OVAL_COLOR
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final ovalWidth = size.width * AppConstants.OVAL_WIDTH_RATIO;
    final ovalHeight = size.height * AppConstants.OVAL_HEIGHT_RATIO;
    
    final left = (size.width - ovalWidth) / 2;
    final top = (size.height - ovalHeight) / 2;

    final oval = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, ovalWidth, ovalHeight),
      const Radius.circular(AppConstants.OVAL_RADIUS),
    );

    canvas.drawRRect(oval, paint);
  }

  void _drawGuidanceText(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: AppConstants.FACE_GUIDE_TEXT,
      style: TextStyle(
        color: AppConstants.TEXT_COLOR,
        fontSize: AppConstants.TEXT_SIZE,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final ovalHeight = size.height * AppConstants.OVAL_HEIGHT_RATIO;
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height + ovalHeight) / 2 + AppConstants.TEXT_PADDING,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 