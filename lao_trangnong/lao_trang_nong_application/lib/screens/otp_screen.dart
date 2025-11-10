import 'package:agri_flutter/controllers/auth_controller.dart'; // 1. Đổi import
import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:agri_flutter/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 2. Đổi thành GetView<AuthController>
class OtpScreen extends GetView<AuthController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Xoá các controller cục bộ

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        // ... (AppBar giữ nguyên)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        // 4. Thêm Form và key
        child: Form(
          key: controller.phoneFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vui lòng nhập số điện thoại của bạn để nhận mã xác minh.',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: 'Số điện thoại',
                controller: controller.phoneController, // 5. Dùng AuthController
                validator: controller.validatePhone, // 6. Thêm validator
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: 24),
              // 7. Bọc nút trong Obx
              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  child: controller.isLoading.value
                      ? const Center(
                      child: CircularProgressIndicator(color: AppColors.green))
                      : ElevatedButton(
                    onPressed: controller.sendOtp, // 8. Gọi hàm controller
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Gửi OTP',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}