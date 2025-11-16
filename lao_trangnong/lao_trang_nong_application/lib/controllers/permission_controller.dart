// controllers/permission_controller.dart (ĐÃ SỬA LỖI LOGIC)
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart'; // Import để dùng Get.snackbar

import '../routes/app_routes.dart';

class PermissionController extends GetxController {
  final isLoading = false.obs;

  // Lưu trạng thái của từng quyền
  final cameraPermissionGranted = false.obs;
  final storagePermissionGranted = false.obs; // <-- ĐỔI TÊN TỪ photos
  final phonePermissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermissions(); // Kiểm tra trạng thái hiện tại khi mở
  }

  /// Kiểm tra các quyền đã có
  Future<void> checkPermissions() async {
    cameraPermissionGranted.value = await Permission.camera.isGranted;
    storagePermissionGranted.value = await Permission.storage.isGranted; // <-- SỬA (dùng .storage)
    phonePermissionGranted.value = await Permission.phone.isGranted;
  }

  /// Hàm được gọi bởi nút "Cho phép tất cả"
  Future<void> requestAllPermissions() async {
    isLoading(true);

    try {
      // 1. Yêu cầu các quyền
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage, // <-- SỬA (dùng .storage)
        Permission.phone,
      ].request();

      // 2. Kiểm tra lại (Giữ nguyên)
      await checkPermissions();

      // 3. Kiểm tra các biến RxBool
      if (cameraPermissionGranted.value &&
          storagePermissionGranted.value && // <-- SỬA (dùng .storage)
          phonePermissionGranted.value) {

        // 4. Nếu tất cả đều là 'true' -> Đi đến màn hình KYC
        Get.offAllNamed(AppRoutes.kyc);

      } else {
        // 5. Nếu 1 trong 3 là 'false' -> Báo lỗi
        Get.snackbar(
          "Cần cấp quyền",
          "Vui lòng cấp tất cả các quyền để tiếp tục.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // 6. Kiểm tra xem có bị 'Từ chối vĩnh viễn' không
        if (statuses.containsValue(PermissionStatus.permanentlyDenied)) {
          await Future.delayed(const Duration(seconds: 2));
          openAppSettings(); // Mở Cài đặt của ứng dụng
        }
      }

    } catch (e) {
      Get.snackbar("Lỗi", "Không thể yêu cầu quyền: $e");
    } finally {
      isLoading(false);
    }
  }
}