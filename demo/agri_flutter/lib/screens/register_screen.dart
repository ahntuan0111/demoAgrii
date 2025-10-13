import 'package:agri_flutter/controllers/register_controller.dart';
import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:agri_flutter/shared/widgets/custom_button.dart';
import 'package:agri_flutter/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

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
          'Tạo tài khoản',
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextField(
                hint: 'Tên đầy đủ',
                controller: controller.fullNameController,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),

              // Nút đăng nhập bằng Zalo
              _socialButton(
                label: 'Đăng nhập bằng Zalo',
                textColor: Colors.black,
                iconPath: 'assets/icons/zalo.png',
                onPressed: () {
                  Get.snackbar("Thông báo", "Đăng nhập bằng Zalo (demo)");
                },
              ),
              const SizedBox(height: 10),

              // Nút đăng nhập bằng Facebook
              _socialButton(
                label: 'Đăng nhập bằng Facebook',
                textColor: Colors.black,
                iconPath: 'assets/icons/facebook.png',
                onPressed: () {
                  Get.snackbar("Thông báo", "Đăng nhập bằng Facebook (demo)");
                },
              ),

              const SizedBox(height: 20),

              // Nút Đăng ký chính
              CustomButton(label: 'Đăng ký', onPressed: controller.register),

              const SizedBox(height: 5),
              TextButton(
                onPressed: controller.goToLogin,
                child: const Text(
                  'Đã có tài khoản? Hãy đăng nhập!',
                  style: TextStyle(color: AppColors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget nút mạng xã hội - viền + nền xanh nhạt
  Widget _socialButton({
    required String label,

    required Color textColor,
    required VoidCallback onPressed,
    String? iconPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGreen, // nền khớp TextField
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton.icon(
        icon: iconPath != null
            ? Image.asset(iconPath, height: 22)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
