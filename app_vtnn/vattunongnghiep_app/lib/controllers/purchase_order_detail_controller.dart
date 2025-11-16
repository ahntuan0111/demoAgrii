// controllers/purchase_order_detail_controller.dart (ĐÃ SỬA LỖI)
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vattunongnghiep_app/controllers/purchase_order_list_controller.dart';
import 'package:flutter/material.dart'; // <-- 1. IMPORT (Cần cho Future.delayed)

import '../models/purchase_order_model.dart';
import '../services/purchase_order_service.dart';

class PurchaseOrderDetailController extends GetxController {
  final PurchaseOrderService _poService = Get.find<PurchaseOrderService>();

  // Dữ liệu PO được truyền từ màn hình list
  late final PurchaseOrder po;

  final isLoading = false.obs;

  // Biến state cho nút bấm
  final isButtonEnabled = false.obs;
  final statusText = 'Chờ xử lý'.obs;

  // Formatters
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final dateFormatter = DateFormat('dd/MM/yyyy', 'vi_VN');

  @override
  void onInit() {
    super.onInit();
    // 1. Lấy đơn hàng từ arguments
    po = Get.arguments as PurchaseOrder;

    // 2. Cập nhật trạng thái cho UI
    updateStatusUI(po.status);
  }

  /// Cập nhật UI dựa trên trạng thái
  void updateStatusUI(String status) {
    // po.status = status; // <-- 2. XÓA DÒNG GÂY LỖI NÀY

    // Logic của bạn: Chỉ bật nút khi 'Đã gửi hàng'
    if (status == 'shipped') {
      isButtonEnabled.value = true;
      statusText.value = 'Đã gửi hàng';
    } else if (status == 'pending') {
      isButtonEnabled.value = false;
      statusText.value = 'Chờ xử lý';
    } else if (status == 'completed') {
      isButtonEnabled.value = false;
      statusText.value = 'Đã nhận hàng';
    } else {
      isButtonEnabled.value = false;
      statusText.value = status; // Hiển thị các trạng thái khác (VD: 'processing')
    }
  }

  /// Nút "Xác nhận đã nhận hàng"
  Future<void> confirmReception() async {
    if (!isButtonEnabled.value) return; // Không làm gì nếu nút bị tắt

    isLoading(true);
    try {
      // 1. Gọi API (BE)
      await _poService.receivePurchaseOrder(po.id);

      // 2. Cập nhật UI
      updateStatusUI('completed'); // Cập nhật UI ngay lập tức
      Get.snackbar("Thành công", "Đã xác nhận nhận hàng và nhập kho.");

      // 3. Tải lại danh sách ở màn hình trước
      if (Get.isRegistered<PurchaseOrderListController>()) {
        Get.find<PurchaseOrderListController>().fetchPurchaseOrders();
      }

      // 4. Tự động đóng popup sau 2 giây
      await Future.delayed(const Duration(seconds: 2));
      Get.back();

    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }
}