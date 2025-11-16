// controllers/location_check_controller.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/location_service.dart'; // <-- 2. Import (để dùng Colors)

class LocationCheckController extends GetxController {
  // 3. Xóa 'progress' (không dùng thanh % nữa, dùng vòng xoay)
  // var progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // 4. Thay thế hàm giả lập bằng hàm kiểm tra thật
    checkLocationAndProceed();
  }

  // 5. HÀM MỚI (THAY THẾ simulateCheck)
  Future<void> checkLocationAndProceed() async {
    try {
      // (Tùy chọn) Thêm 1-2 giây chờ để người dùng đọc text
      await Future.delayed(const Duration(seconds: 2));

      // 6. GỌI HÀM XIN QUYỀN & LẤY VỊ TRÍ
      //    -> Chính dòng này sẽ kích hoạt HỘP THOẠI XIN QUYỀN
      final position = await LocationService.getCurrentPosition();

      // 7. NẾU THÀNH CÔNG -> ĐI TIẾP
      Get.offNamed(AppRoutes.welcome); // Dùng offNamed để thay thế màn hình

    } on LocationException catch (e) {
      // 8. NẾU THẤT BẠI (do người dùng từ chối/tắt GPS)
      Get.snackbar(
        "Không thể tiếp tục",
        e.toString(), // Hiển thị lỗi từ LocationService
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      // (Bạn có thể thêm 1 nút "Thử lại" trên UI để gọi lại hàm này)
    } catch (e) {
      // 9. Bắt các lỗi chung khác
      Get.snackbar("Lỗi không xác định", e.toString());
    }
  }
}