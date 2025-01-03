import '../constants/photo_types.dart';

class FacePhotos {
  final String? front;
  final String? left;
  final String? right;

  const FacePhotos({
    this.front,
    this.left,
    this.right,
  });

  bool get isComplete => front != null && left != null && right != null;

  FacePhotos copyWith({
    String? front,
    String? left,
    String? right,
  }) {
    return FacePhotos(
      front: front ?? this.front,
      left: left ?? this.left,
      right: right ?? this.right,
    );
  }

  String? getPhotoForType(FacePhotoType type) {
    switch (type) {
      case FacePhotoType.front:
        return front;
      case FacePhotoType.left:
        return left;
      case FacePhotoType.right:
        return right;
    }
  }
} 