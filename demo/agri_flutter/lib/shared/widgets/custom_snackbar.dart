import 'package:get/get.dart';

void showCustomSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 2),
  );
}
