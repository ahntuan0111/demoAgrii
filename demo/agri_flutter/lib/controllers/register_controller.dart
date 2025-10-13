
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RegisterController extends GetxController {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // ✅ Giả lập đăng ký
  void register() {
    if (fullNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng điền đầy đủ thông tin!",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (passwordController.text.length < 6) {
      Get.snackbar("Lỗi", "Mật khẩu phải có ít nhất 6 ký tự!",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Giả lập xử lý
    Get.snackbar("Thành công", "Đăng ký thành công!",
        snackPosition: SnackPosition.BOTTOM);

    // Chuyển sang trang đăng nhập
    Get.offNamed(AppRoutes.login);
  }

  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
