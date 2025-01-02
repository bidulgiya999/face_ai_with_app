import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/photo_types.dart';

class PhotoPreviewList extends StatelessWidget {
  final Map<FacePhotoType, String?> photos;
  
  const PhotoPreviewList({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Row(
        children: [
          if (photos[FacePhotoType.front] != null)
            _buildPreview(context, photos[FacePhotoType.front]!, '정면'),
          if (photos[FacePhotoType.left] != null)
            _buildPreview(context, photos[FacePhotoType.left]!, '왼쪽'),
          if (photos[FacePhotoType.right] != null)
            _buildPreview(context, photos[FacePhotoType.right]!, '오른쪽'),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            contentPadding: const EdgeInsets.all(8),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Image.file(
                  File(imagePath),
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 