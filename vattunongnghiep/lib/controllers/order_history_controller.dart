import 'package:agri_flutter/models/order_model.dart';
import 'package:agri_flutter/services/order_service.dart';
import 'package:get/get.dart';

class OrderHistoryController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();

  final isLoading = true.obs;
  final orderList = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      isLoading(true);
      final orders = await _orderService.getMyOrders();
      orderList.assignAll(orders);
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // --- ✅ HÀM MỚI ĐƯỢC THÊM VÀO ---
  /// Xử lý khi người dùng nhấn nút "Đã nhận được hàng"
  Future<void> confirmOrderReceived(String orderId) async {
    // (Tùy chọn: Thêm một isLoading riêng cho nút bấm)
    try {
      // 1. Gọi API
      final updatedOrder = await _orderService.completeOrderByCustomer(orderId);

      // 2. Cập nhật lại list trên UI
      // Cách 1: Tải lại toàn bộ list (Đơn giản nhất)
      await fetchOrderHistory();

      // // Cách 2: Tìm và thay thế (Nhanh hơn)
      // final index = orderList.indexWhere((o) => o.id == orderId);
      // if (index != -1) {
      //   orderList[index] = updatedOrder;
      // }

      Get.snackbar(
        "Thành công",
        "Đã xác nhận nhận hàng. Cảm ơn bạn!",
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      Get.snackbar(
        "Lỗi",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}