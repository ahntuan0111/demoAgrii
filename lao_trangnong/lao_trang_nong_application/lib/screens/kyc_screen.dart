// screens/kyc_screen.dart (ĐÃ SỬA LỖI HIỂN THỊ ẢNH)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/kyc_controller.dart';
import '../shared/themes/app_colors.dart';

class KycScreen extends GetView<KycController> {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green, // Màu xanh
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Xác minh danh tính',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.skip,
            child: const Text('Để sau',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Phần Header Xanh ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: AppColors.green,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings_outlined,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text('Xác minh KYC',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(
                    'Giúp chúng tôi xác minh danh tính của bạn\nđể tăng độ tin cậy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // --- Phần Nội dung Trắng ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. Ô CMND/CCCD ---
                  const Text('CMND/CCCD',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Mặt trước và mặt sau', // Sửa text cho rõ
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildImagePickerBox(
                    context: context,
                    title: 'Chụp / Tải ảnh CMND',
                    icon: Icons.image_outlined,
                    onTap: controller.handleIdUpload,

                    // --- ✅ SỬA LỖI 1 TẠI ĐÂY ---
                    // Obx phải trả về 1 Widget (Row), không phải 1 List
                    imageFiles: Obx(() {
                      return Row(
                        children: [
                          Expanded(child: _buildImagePreviewBox(
                              controller.idFrontImage.value, label: 'Mặt trước')
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _buildImagePreviewBox(
                              controller.idBackImage.value, label: 'Mặt sau')
                          ),
                        ],
                      );
                    }),
                    // --------------------------
                  ),

                  const SizedBox(height: 24),

                  // --- 2. Ô Ảnh Chân dung ---
                  const Text('Ảnh chân dung',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Ảnh selfie rõ mặt',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildImagePickerBox(
                    context: context,
                    title: 'Chụp ảnh chân dung',
                    icon: Icons.camera_alt_outlined,
                    onTap: controller.handleSelfieUpload,

                    // --- ✅ SỬA LỖI 2 TẠI ĐÂY ---
                    // Obx phải trả về 1 Widget
                    imageFiles: Obx(() {
                      // Bọc trong Row để nó chiếm không gian
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildImagePreviewBox(
                              controller.selfieImage.value, label: 'Selfie', width: 120),
                        ],
                      );
                    }),
                    // --------------------------
                  ),

                  const SizedBox(height: 32),

                  // --- 3. Nút Hoàn tất ---
                  Obx(() => ElevatedButton(
                    onPressed:
                    controller.isLoading.value ? null : controller.submitKyc,
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
                            color: Colors.white, strokeWidth: 3))
                        : const Text(
                      'Hoàn tất xác minh',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  )),
                  const SizedBox(height: 12),

                  // --- 4. Nút Bỏ qua ---
                  OutlinedButton(
                    onPressed: controller.skip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Bỏ qua, làm sau',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thông tin của bạn được bảo mật và chỉ dùng để xác minh',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con để vẽ ô chọn ảnh
  Widget _buildImagePickerBox({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Widget imageFiles,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Hiển thị ảnh đã chọn (widget reactive được truyền vào)
          imageFiles,

          const SizedBox(height: 12),

          // Nút bấm
          OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.grey[700]),
            label: Text(
              title,
              style: TextStyle(
                  color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ✅ WIDGET HELPER MỚI (SỬA LẠI) ---
  // Hộp preview chung cho 1 ảnh
  Widget _buildImagePreviewBox(File? imageFile, {String? label, double? width}) {
    return Container(
      width: width, // Cho phép tùy chỉnh width
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageFile != null
            ? Image.file(
          imageFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        )
            : Center( // Nếu ảnh null, hiển thị placeholder
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 36, color: Colors.grey[400]),
              if (label != null) const SizedBox(height: 6),
              if (label != null)
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}