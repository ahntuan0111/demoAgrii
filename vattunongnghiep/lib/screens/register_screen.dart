import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:agri_flutter/shared/widgets/custom_button.dart';
import 'package:agri_flutter/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Thêm nút back để quay lại màn hình OTP nếu muốn
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextField(
                  hint: 'Tên đầy đủ',
                  controller: controller.fullNameController,
                  validator: controller.validateFullName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hint: 'Tên tài khoản',
                  controller: controller.registerUsernameController,
                  validator: controller.validateUsername,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Obx(
                      () => CustomTextField(
                    hint: 'Mật khẩu',
                    controller: controller.registerPasswordController,
                    obscure: controller.isRegisterPasswordHidden.value,
                    validator: controller.validatePassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isRegisterPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleRegisterPasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nút Đăng ký (Sẽ không còn xoay vô hạn)
                Obx(
                      () => controller.isLoading.value
                      ? const CircularProgressIndicator(color: AppColors.green)
                      : CustomButton(
                    label: 'Đăng ký',
                    onPressed: controller.register,
                  ),
                ),
                const SizedBox(height: 20),

                // Các nút social
                _socialButton(
                  label: 'Đăng nhập bằng Zalo',
                  textColor: Colors.black,
                  iconPath: 'assets/icons/zalo.png',
                  onPressed: () {
                    Get.snackbar("Thông báo", "Đăng nhập bằng Zalo (demo)");
                  },
                ),
                const SizedBox(height: 10),
                _socialButton(
                  label: 'Đăng nhập bằng Facebook',
                  textColor: Colors.black,
                  iconPath: 'assets/icons/facebook.png',
                  onPressed: () {
                    Get.snackbar("Thông báo", "Đăng nhập bằng Facebook (demo)");
                  },
                ),
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
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required Color textColor,
    required VoidCallback onPressed,
    String? iconPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
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