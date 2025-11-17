import 'package:agri_flutter/controllers/auth_controller.dart';
import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:agri_flutter/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/widgets/custom_textfield.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
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
        // 1. Thêm Form và key
        child: Form(
          key: controller.loginFormKey,
          child: Column(
            children: [
              CustomTextField(
                hint: 'Tên tài khoản',
                controller: controller.loginUsernameController,
                validator: controller.validateUsername, // 2. Thêm validator
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              // 3. Bọc mật khẩu trong Obx
              Obx(
                    () => CustomTextField(
                  hint: 'Mật khẩu',
                  controller: controller.loginPasswordController,
                  obscure: controller.isLoginPasswordHidden.value, // 4. Dùng .value
                  validator: controller.validatePassword, // 5. Thêm validator
                  textInputAction: TextInputAction.done,
                  // 6. Thêm icon ẩn/hiện
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isLoginPasswordHidden.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.toggleLoginPasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 7. Bọc nút bấm trong Obx để xử lý loading
              Obx(
                    () => controller.isLoading.value
                    ? const CircularProgressIndicator(color: AppColors.green)
                    : CustomButton(
                  label: 'Đăng nhập',
                  onPressed: controller.login,
                ),
              ),
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
      ),
    );
  }
}