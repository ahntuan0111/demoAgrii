// screens/location_check_screen.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/location_check_controller.dart';
import '../shared/themes/app_colors.dart';


class LocationCheckScreen extends GetView<LocationCheckController> {
  const LocationCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller vẫn được 'GetView' tìm thấy
    // (và hàm onInit của nó tự động chạy)
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Chào mừng đến với Agrii",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Chúng tôi đang kiểm tra vị trí của bạn để đảm bảo bạn đang ở Việt Nam.\nVui lòng chờ trong giây lát.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Image.asset('assets/images/logo.png', height: 150),
              const SizedBox(height: 32),

              // --- THAY ĐỔI TẠI ĐÂY ---
              // Thay thế LinearProgressIndicator bằng Circular
              const CircularProgressIndicator(
                color: AppColors.green,
              ),
              // ------------------------

              const SizedBox(height: 20),
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
}