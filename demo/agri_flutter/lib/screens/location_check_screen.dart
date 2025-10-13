import 'package:agri_flutter/controllers/location_check_controller.dart';
import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LocationCheckScreen extends GetView<LocationCheckController> {
  const LocationCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              Obx(() => LinearProgressIndicator(
                    value: controller.progress.value,
                    color: AppColors.green,
                    backgroundColor: AppColors.lightGreen,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                  )),
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
