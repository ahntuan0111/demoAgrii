// shared/widgets/custom_snackbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Hàm này chấp nhận 'isError' để đổi màu
void showCustomSnackbar(String title, String message, {bool isError = false}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
    // Tự động đổi màu dựa trên 'isError'
    backgroundColor: isError ? Colors.red[700] : Colors.green[700],
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
  );
}