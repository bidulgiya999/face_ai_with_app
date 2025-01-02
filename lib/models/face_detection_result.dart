class FaceDetectionResult {
  final String imageUrl;
  final List<FaceBox> faces;

  FaceDetectionResult({
    required this.imageUrl,
    required this.faces,
  });

  factory FaceDetectionResult.fromJson(Map<String, dynamic> json) {
    return FaceDetectionResult(
      imageUrl: json['image_url'] as String,
      faces: (json['faces'] as List)
          .map((face) => FaceBox.fromJson(face))
          .toList(),
    );
  }
}

class FaceBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double confidence;

  FaceBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.confidence,
  });

  factory FaceBox.fromJson(Map<String, dynamic> json) {
    return FaceBox(
      x1: json['x1'].toDouble(),
      y1: json['y1'].toDouble(),
      x2: json['x2'].toDouble(),
      y2: json['y2'].toDouble(),
      confidence: json['confidence'].toDouble(),
    );
  }
} 