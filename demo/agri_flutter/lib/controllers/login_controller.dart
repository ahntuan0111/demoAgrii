import 'package:agri_flutter/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = GetStorage();

  void login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Lỗi",
        "Vui lòng nhập đầy đủ thông tin!",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // ✅ Lưu thông tin đăng nhập vào GetStorage
    storage.write('username', usernameController.text.trim());
    storage.write('password', passwordController.text.trim());
    storage.write('isLoggedIn', true);

    // ✅ Thông báo thành công
    Get.snackbar(
      "Thành công",
      "Đăng nhập thành công!",
      snackPosition: SnackPosition.BOTTOM,
    );

    // ✅ Điều hướng sang màn hình chính (locationCheck)
    Get.offAllNamed(AppRoutes.situate);
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
