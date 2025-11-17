import 'package:agri_flutter/controllers/auth_controller.dart';
import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:agri_flutter/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationScreen extends GetView<AuthController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hàm xử lý chuyển focus khi nhập số
    void handleInput(String value, int index) {
      if (value.length == 1 && index < 5) {
        // Nhập xong 1 số -> chuyển sang ô kế tiếp
        FocusScope.of(context).requestFocus(controller.otpFocusNodes[index + 1]);
      } else if (value.isEmpty && index > 0) {
        // Xóa -> quay lại ô trước
        FocusScope.of(context).requestFocus(controller.otpFocusNodes[index - 1]);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập mã xác minh',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã OTP đã được gửi đến ${controller.phoneController.text}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 40),

            // Hàng 6 ô nhập OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                    (index) => SizedBox(
                  width: 45,
                  height: 55,
                  child: TextField(
                    controller: controller.otpFields[index],
                    focusNode: controller.otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: "", // Ẩn bộ đếm ký tự
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: AppColors.green, width: 2),
                      ),
                    ),
                    onChanged: (value) => handleInput(value, index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Nút Xác minh
            Obx(
                  () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: AppColors.green.withOpacity(0.6),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'Xác minh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Đếm ngược và Gửi lại
            Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa nhận được mã? ", style: TextStyle(color: Colors.black54)),
                  GestureDetector(
                    onTap: controller.isResendEnabled.value ? controller.resendOtp : null,
                    child: Text(
                      controller.isResendEnabled.value
                          ? 'Gửi lại'
                          : 'Gửi lại sau ${controller.countdown.value}s',
                      style: TextStyle(
                        color: controller.isResendEnabled.value
                            ? AppColors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
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