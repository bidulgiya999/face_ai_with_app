import 'package:flutter/material.dart';

/// 에러 처리 유틸리티
/// - 에러 메시지 표시
/// - 스낵바 표시
class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
} 