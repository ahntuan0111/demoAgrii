import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vattunongnghiep_app/controllers/vtnn_order_list_controller.dart';
import '../models/vtnn_order_model.dart';
import '../services/vtnn_order_service.dart';

class VtnnOrderDetailController extends GetxController {
  // --- 1. DEPENDENCIES ---
  final VtnnOrderService _orderService = Get.find<VtnnOrderService>();
  final VtnnOrderListController _listController = Get.find<VtnnOrderListController>();

  // --- 2. STATE ---
  final isLoading = false.obs;
  late final Rx<VtnnOrder> order;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  // --- 3. KHỞI TẠO ---
  @override
  void onInit() {
    super.onInit();
    order = (Get.arguments as VtnnOrder).obs;
  }

  // --- 4. LOGIC TRẠNG THÁI (ĐÃ CẬP NHẬT 1-1 VỚI BE) ---

  String getStatusText(String status) {
    switch (status) {
      case 'pending_vtnn_prep': // <-- Trạng thái 1
        return 'Chờ xử lý';
      case 'preparing':         // <-- Trạng thái 2
        return 'Đang xử lý';
      case 'ready_for_pickup':  // <-- Trạng thái 3
        return 'Chờ lấy hàng'; // (Khác với text cũ)
      case 'awaiting_payment':  // <-- Trạng thái 4
        return 'Chờ thu tiền';
      case 'out_for_delivery':  // <-- Trạng thái 5
      case 'delivered':
      case 'completed':
        return 'Đã hoàn tất';
      case 'cancelled':         // <-- Trạng thái 6
        return 'Đã hủy';
      default:
        return 'Không rõ';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending_vtnn_prep': // <-- Trạng thái 1 (Màu mới)
        return Colors.orange.shade700;
      case 'preparing':         // <-- Trạng thái 2
        return Colors.blue.shade700;
      case 'ready_for_pickup':  // <-- Trạng thái 3
      case 'awaiting_payment':  // <-- Trạng thái 4
        return Colors.purple.shade700;
      case 'out_for_delivery':
      case 'delivered':
      case 'completed':
        return const Color(0xFF1B5E20);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // --- 5. ACTIONS (ĐÃ CẬP NHẬT ĐẦY ĐỦ) ---

  /// Action cho (1) 'pending_vtnn_prep' -> (2) 'preparing'
  Future<void> confirmProcessing() async {
    await _updateOrderStatus(
      'preparing', // Trạng thái mới
      "Đã xác nhận xử lý đơn hàng.",
    );
  }

  /// Action cho (2) 'preparing' -> (3) 'ready_for_pickup'
  Future<void> confirmPreparation() async {
    await _updateOrderStatus(
      'ready_for_pickup', // Trạng thái mới
      "Xác nhận chuẩn bị thành công!",
    );
  }

  /// Action cho (3) 'ready_for_pickup' -> (4) 'awaiting_payment'
  Future<void> confirmManagerArrival() async {
    await _updateOrderStatus(
      'awaiting_payment', // Trạng thái mới
      "Đã xác nhận Lão Nông/Tráng Nông đến.",
    );
  }

  /// Action cho (4) 'awaiting_payment' -> (5) 'out_for_delivery'
  Future<void> confirmPayment() async {
    await _updateOrderStatus(
      'out_for_delivery', // Trạng thái mới
      "Xác nhận thu tiền thành công!",
    );
  }

  /// Action cho nút "Báo thiếu hàng"
  void reportStockIssue() {
    Get.defaultDialog(
      title: "Báo thiếu hàng",
      middleText: "Chức năng này đang được phát triển. Vui lòng liên hệ Admin.",
      textConfirm: "Đã hiểu",
      onConfirm: () => Get.back(),
    );
  }

  /// Hàm chung gọi API
  Future<void> _updateOrderStatus(String newStatus, String successMessage) async {
    isLoading(true);
    try {
      final updatedOrder = await _orderService.updateOrderStatus(order.value.id, newStatus);
      order.value = updatedOrder; // Cập nhật UI ngay lập tức
      _listController.fetchAllOrders(); // Tải lại danh sách
      Get.snackbar("Thành công", successMessage, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Thất bại", "Cập nhật thất bại: ${e.toString().replaceFirst("Exception: ", "")}", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void closeScreen() {
    Get.back();
  }
}