import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';


class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      {
        "icon": "🤝",
        "title": "Kết nối Nhà nông",
        "desc": "Tiếp cận hàng nghìn Nhà nông cần vật tư nông nghiệp chất lượng",
        "button": "Tiếp tục"
      },
      {
        "icon": "🚚",
        "title": "Bán & chăm sóc",
        "desc": "Bán hàng trực tiếp, giao tận nơi và hưởng hoa hồng hấp dẫn",
        "button": "Tiếp tục"
      },
      {
        "icon": "👥",
        "title": "Mở rộng đội TN",
        "desc": "Phát triển đội Trạng nông, nhận hoa hồng đội và thăng tiến",
        "button": "Bắt đầu"
      },
    ];

    return Scaffold(
      body: Obx(() {
        final page = controller.currentPage.value;

        return Container(
          width: double.infinity,
          color: Colors.green.shade800,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.skip,
                  child: const Text("Bỏ qua", style: TextStyle(color: Colors.white)),
                ),
              ),
              const Spacer(),
              Text(
                pages[page]["icon"]!,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 24),
              Text(
                pages[page]["title"]!,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                pages[page]["desc"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: page == index ? Colors.white : Colors.white24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(pages[page]["button"]!),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
