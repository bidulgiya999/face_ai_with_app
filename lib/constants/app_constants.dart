import 'package:flutter/material.dart';

/// 앱 전역 상수 관리
/// - UI 관련 상수
/// - 색상 상수
/// - 텍스트 상수
/// - 크기 관련 상수
class AppConstants {
  // 타원 관련 상수
  static const double OVAL_WIDTH_RATIO = 0.53;
  static const double OVAL_HEIGHT_RATIO = 0.45;
  static const double TEXT_PADDING = 40.0;
  static const double OVAL_RADIUS = 150.0;
  
  // 색상 관련 상수
  static const Color OVAL_COLOR = Color.fromRGBO(255, 255, 255, 0.3);
  static const Color TEXT_COLOR = Color.fromRGBO(255, 255, 255, 0.8);
  
  // 텍스트 관련 상수
  static const String FACE_GUIDE_TEXT = '얼굴을 타원형 안에 맞춰주세요';
  static const double TEXT_SIZE = 16.0;
} 