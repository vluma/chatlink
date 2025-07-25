import 'package:flutter/material.dart';

/// Toast工具类扩展
extension ScaffoldMessengerExtensions on ScaffoldMessengerState {
  /// 显示Toast消息
  void showToast(String message) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.black54,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}