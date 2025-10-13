import 'package:agri_flutter/controllers/login_controller.dart';
import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:agri_flutter/shared/widgets/custom_button.dart';
import 'package:agri_flutter/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Đăng nhập',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/images/logo.png', // đường dẫn logo của bạn
              height: 30,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomTextField(
              hint: 'Tên tài khoản',
              controller: controller.usernameController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hint: 'Mật khẩu',
              controller: controller.passwordController,
              obscure: true,
            ),
            const SizedBox(height: 16),
            CustomButton(label: 'Đăng nhập', onPressed: controller.login),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.goToRegister,
              child: const Text(
                'Chưa có tài khoản? Hãy đăng ký!',
                style: TextStyle(color: AppColors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
