// screens/permission_screen.dart (ĐÃ THÊM TILE CÒN THIẾU)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/permission_controller.dart';
import '../shared/themes/app_colors.dart';

class PermissionScreen extends GetView<PermissionController> {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Icon Khóa
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // Text
              const Text(
                'Quyền truy cập',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Để sử dụng đầy đủ tính năng',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // --- ✅ SỬA LẠI TẠI ĐÂY ---

              // Tile Quyền 1: Camera
              Obx(() => _buildPermissionTile(
                icon: Icons.camera_alt_outlined,
                title: 'Camera', // Chỉ Camera
                subtitle: 'Để chụp ảnh giao hàng và KYC',
                isGranted: controller.cameraPermissionGranted.value,
              )),
              const SizedBox(height: 16),

              // Tile Quyền 2: Bộ sưu tập (MỚI)
              Obx(() => _buildPermissionTile(
                icon: Icons.image_outlined,
                title: 'Ảnh & Bộ sưu tập', // Quyền Storage/Photos
                subtitle: 'Để tải ảnh lên cho KYC',
                isGranted: controller.storagePermissionGranted.value,
              )),
              const SizedBox(height: 16),

              // Tile Quyền 3: Gọi điện
              Obx(() => _buildPermissionTile(
                icon: Icons.call_outlined,
                title: 'Gọi điện',
                subtitle: 'Để liên hệ với Nhà nông và đội',
                isGranted: controller.phonePermissionGranted.value,
              )),

              // ------------------------

              const Spacer(),

              // Nút Bấm
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null // Vô hiệu hóa khi đang load
                    : controller.requestAllPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3),
                )
                    : const Text(
                  'Cho phép tất cả',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              )),
              const SizedBox(height: 8),
              const Text(
                'Bạn có thể thay đổi quyền này trong Cài đặt',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để vẽ 1 ô quyền (Giữ nguyên)
  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          // Dấu tick (nếu đã cấp)
          if (isGranted)
            const Icon(Icons.check_circle, color: AppColors.green)
        ],
      ),
    );
  }
}