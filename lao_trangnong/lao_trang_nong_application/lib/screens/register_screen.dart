
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../shared/themes/app_colors.dart';
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/custom_textfield.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        // ... (AppBar giữ nguyên)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          // 1. Thêm Form và key
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextField(
                  hint: 'Tên đầy đủ',
                  controller: controller.fullNameController,
                  validator: controller.validateFullName, // 2. Thêm validator
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hint: 'Tên tài khoản',
                  // 3. Đổi controller
                  controller: controller.registerUsernameController,
                  validator: controller.validateUsername, // 4. Thêm validator
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                // 5. Bọc mật khẩu trong Obx
                Obx(
                      () => CustomTextField(
                    hint: 'Mật khẩu',
                    // 6. Đổi controller
                    controller: controller.registerPasswordController,
                    // 7. Dùng .value
                    obscure: controller.isRegisterPasswordHidden.value,
                    validator: controller.validatePassword, // 8. Thêm validator
                    textInputAction: TextInputAction.done,
                    // 9. Thêm icon ẩn/hiện
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

                // ... (Các nút social giữ nguyên)
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
                const SizedBox(height: 20),

                // 10. Bọc nút Đăng ký trong Obx
                Obx(
                      () => controller.isLoading.value
                      ? const CircularProgressIndicator(color: AppColors.green)
                      : CustomButton(
                    label: 'Đăng ký',
                    onPressed: controller.register,
                  ),
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

  // ... (Widget _socialButton giữ nguyên)
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