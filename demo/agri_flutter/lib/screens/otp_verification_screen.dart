import 'package:agri_flutter/controllers/otp_controller.dart';
import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:agri_flutter/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationScreen extends GetView<OtpController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 6 controller + 6 focus node cho từng ô OTP
    final List<TextEditingController> otpFields = List.generate(
      6,
      (index) => TextEditingController(),
    );
    final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

    void handleInput(String value, int index) {
      if (value.isNotEmpty && index < 5) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      } else if (value.isEmpty && index > 0) {
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
      }

      // Gộp tất cả 6 số lại thành 1 chuỗi
      String code = otpFields.map((c) => c.text).join();
      controller.otpCode.value = code;
    }

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
          'Xác minh số điện thoại',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // 6 ô nhập OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 45,
                  height: 55,
                  child: CustomTextField(
                    hint: '',
                    controller: otpFields[index],
                    keyboardType: TextInputType.number,
                    obscure: true,
                    maxLength: 1,
                    onChanged: (value) => handleInput(value, index),
                  ), // Tự động focus ô đầu
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Nút xác minh
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.verifyOtp(controller.otpCode.value),
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

            const SizedBox(height: 16),

            // Gửi lại OTP + đếm ngược
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
