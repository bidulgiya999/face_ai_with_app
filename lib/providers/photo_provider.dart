import 'package:flutter/material.dart';
import '../constants/photo_types.dart';

class PhotoProvider extends ChangeNotifier {
  final Map<FacePhotoType, String?> _photos = {
    FacePhotoType.front: null,
    FacePhotoType.left: null,
    FacePhotoType.right: null,
  };

  FacePhotoType _currentPhotoType = FacePhotoType.front;
  
  Map<FacePhotoType, String?> get photos => _photos;
  FacePhotoType get currentPhotoType => _currentPhotoType;
  bool get isCompleted => !_photos.values.contains(null);
  bool get hasAnyPhotos => _photos.values.any((photo) => photo != null);

  void addPhoto(String path) {
    _photos[_currentPhotoType] = path;
    
    // 다음 타입으로 자동 이동
    switch (_currentPhotoType) {
      case FacePhotoType.front:
        _currentPhotoType = FacePhotoType.left;
        break;
      case FacePhotoType.left:
        _currentPhotoType = FacePhotoType.right;
        break;
      case FacePhotoType.right:
        // 마지막 사진이므로 타입 변경 없음
        break;
    }
    
    notifyListeners();
  }

  void reset() {
    _photos.updateAll((key, value) => null);
    _currentPhotoType = FacePhotoType.front;
    notifyListeners();
  }

  void setCurrentType(FacePhotoType type) {
    _currentPhotoType = type;
    notifyListeners();
  }

  bool hasPhotoForType(FacePhotoType type) {
    return _photos[type] != null;
  }

  void updatePhoto(String path) {
    _photos[_currentPhotoType] = path;
    // 사진 수정 시에는 다음 타입으로 이동하지 않음
    notifyListeners();
  }
} 