
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';

import '../routes/app_routes.dart';
import '../shared/themes/app_colors.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Chào mừng đến với Agrii',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/images/logo.png', height: 150),
              const SizedBox(height: 20),
              const Text(
                'Đối tác đáng tin cậy của bạn trong lĩnh vực nống nghiệp, kết nối với đại lý địa phương để đáp ứng mọi nhu cầu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              _buildFeature(
                Icons.check_circle,
                'Lựa chọn nguồn cung cấp đa dạng',
              ),
              _buildFeature(
                Icons.check_circle,
                'Giá cả cạnh tranh',
              ),
              _buildFeature(
                Icons.check_circle,
                'Giao hàng nhanh chóng và đáng tin cậy',
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(
                    context,
                    "Đăng ký",
                    label: "Đăng ký",
                    onPressed: () {
                      Get.toNamed(AppRoutes.otp);
                    },
                    background: AppColors.green,
                    textColor: AppColors.white,
                  ),
                  const SizedBox(width: 20),
                   _actionButton(
                    context,
                    "Đăng nhập",
                    label: "Đăng nhập",
                    onPressed: () {
                     Get.toNamed(AppRoutes.login);
                    },
                    background: AppColors.white,
                    borderColor: AppColors.green,
                    textColor: AppColors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của chúng tôi.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.green),
              ),
            ],
          ),
          
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}

 Widget _actionButton(BuildContext context, String s, {
    required String label,
    required VoidCallback onPressed,
    Color? background,
    Color? borderColor,
    Color? textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        side: borderColor != null ? BorderSide(color: borderColor) : null,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
    );
  }

