class YOLOResult {
  final String imageUrl;
  final List<Detection> detections;
  final String resultImageUrl;
  
  YOLOResult({
    required this.imageUrl,
    required this.detections,
    required this.resultImageUrl,
  });
  
  factory YOLOResult.fromJson(Map<String, dynamic> json) {
    return YOLOResult(
      imageUrl: json['image_url'],
      detections: (json['detections'] as List)
          .map((d) => Detection.fromJson(d))
          .toList(),
      resultImageUrl: json['result_image'].replaceFirst('gs://', 'https://storage.googleapis.com/'),
    );
  }
}

class Detection {
  final List<double> bbox;  // 경계 상자 좌표 [x1, y1, x2, y2]
  final double confidence;  // 신뢰도 점수
  final String className;  // 감지된 클래스 이름
  
  Detection({
    required this.bbox,
    required this.confidence,
    required this.className,
  });
  
  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      bbox: (json['bbox'] as List).cast<double>(),
      confidence: json['confidence'],
      className: json['class_name'],
    );
  }
} 