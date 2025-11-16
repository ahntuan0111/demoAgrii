
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../shared/themes/app_colors.dart';
import '../shared/widgets/custom_textfield.dart';

// 2. Đổi thành GetView<AuthController>
class OtpVerificationScreen extends GetView<AuthController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Xoá controller và focus node cục bộ
    // 4. Sửa hàm handleInput
    void handleInput(String value, int index) {
      if (value.isNotEmpty && index < 5) {
        Future.microtask(() {
          controller.otpFocusNodes[index + 1].requestFocus();
        });
      } else if (value.isEmpty && index > 0) {
        Future.microtask(() {
          controller.otpFocusNodes[index - 1].requestFocus();
        });
      }
    }


    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        // ... (AppBar giữ nguyên)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Phần Text giữ nguyên)
            const Text(
              'Nhập mã',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chúng tôi đã gửi mã xác minh đến số điện thoại của bạn. '
                  'Vui lòng kiểm tra mã OTP qua Zalo OA hoặc SMS.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 28),

            // 5. Cập nhật 6 ô nhập OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                    (index) => SizedBox(
                  width: 45,
                  height: 55,
                  child: CustomTextField(
                    hint: '',
                    // 6. Dùng controller & focus node từ AuthController
                    controller: controller.otpFields[index],
                    focusNode: controller.otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    obscure: false, // Để true sẽ thành dấu •, nên để false
                    maxLength: 1,
                    onChanged: (value) => handleInput(value, index),
                    textAlign: TextAlign.center, // Thêm để căn giữa
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 7. Bọc nút xác minh trong Obx
            Obx(
                  () => SizedBox(
                width: double.infinity,
                child: controller.isLoading.value
                    ? const Center(
                    child: CircularProgressIndicator(color: AppColors.green))
                    : ElevatedButton(
                  // 8. Gọi hàm verifyOtp (không cần tham số)
                  onPressed: controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Xác minh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 9. Khối Gửi lại OTP (đã dùng Obx)
            // Khối này đã chính xác vì nó dùng 'controller'
            Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: controller.isResendEnabled.value
                        ? controller.resendOtp
                        : null,
                    child: Text(
                      'Gửi lại OTP',
                      style: TextStyle(
                        color: controller.isResendEnabled.value
                            ? AppColors.green
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '00:${controller.countdown.value.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}