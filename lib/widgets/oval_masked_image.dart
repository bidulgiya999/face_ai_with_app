import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class OvalMaskedImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final BoxFit fit;

  const OvalMaskedImage({
    super.key,
    required this.imagePath,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 클리핑된 이미지
        ClipPath(
          clipper: OvalClipper(),
          child: Image.file(
            File(imagePath),
            height: height,
            fit: fit,
          ),
        ),
        // 블러 효과와 테두리
        CustomPaint(
          painter: OvalMaskPainter(),
          child: SizedBox(
            width: double.infinity,
            height: height,
          ),
        ),
      ],
    );
  }
}

class OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final ovalWidth = size.width * AppConstants.OVAL_WIDTH_RATIO;
    final ovalHeight = size.height * AppConstants.OVAL_HEIGHT_RATIO;
    final left = (size.width - ovalWidth) / 2;
    final top = (size.height - ovalHeight) / 2;

    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, ovalWidth, ovalHeight),
        const Radius.circular(AppConstants.OVAL_RADIUS),
      ));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OvalMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ovalWidth = size.width * AppConstants.OVAL_WIDTH_RATIO;
    final ovalHeight = size.height * AppConstants.OVAL_HEIGHT_RATIO;
    final left = (size.width - ovalWidth) / 2;
    final top = (size.height - ovalHeight) / 2;

    final ovalRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, ovalWidth, ovalHeight),
      const Radius.circular(AppConstants.OVAL_RADIUS),
    );

    // 바깥 영역만 블러 처리
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addRRect(ovalRect);
    final blurRegion = Path.combine(
      PathOperation.difference,
      backgroundPath,
      ovalPath,
    );

    canvas.drawPath(
      blurRegion,
      Paint()
        ..color = Colors.black.withAlpha(150)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // 타원 테두리 그리기
    canvas.drawRRect(
      ovalRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 