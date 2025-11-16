import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/manager_order_model.dart';
import '../routes/app_routes.dart';
import '../screens/order_reception_screen.dart';
import '../services/order_service.dart';
// --- ✅ 1. BẬT API SERVICE ---

class OrderReceptionController extends GetxController with WidgetsBindingObserver {
  // --- ✅ 2. BẬT API SERVICE ---
  final OrderService _orderService = Get.find<OrderService>();

  final isLoading = true.obs;
  final orderList = <ManagerOrder>[].obs;
  final isOnline = true.obs;

  final currencyFormatter =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final distanceFormatter = NumberFormat("###.0#", "vi_VN");

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchOrders(); // Gọi hàm fetchOrders đã sửa
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isOnline.value) {
      fetchOrders();
    }
  }

  /// --- ✅ 3. VIẾT LẠI HÀM FETCHORDERS ĐỂ GỌI API ---
  Future<void> fetchOrders() async {
    // Nếu offline, không làm gì cả
    if (!isOnline.value) {
      orderList.clear();
      return;
    }

    isLoading(true);
    try {
      // Gọi API từ service
      final List<ManagerOrder> orders = await _orderService.getManagerOrders();
      orderList.assignAll(orders);
    } catch (e) {
      Get.snackbar(
        "Lỗi tải đơn hàng",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
      orderList.clear(); // Xóa list nếu có lỗi
    } finally {
      isLoading(false);
    }
  }

  /// Xử lý nút gạt Online/Offline
  void toggleOnlineStatus(bool value) {
    isOnline.value = value;
    if (value) {
      fetchOrders(); // Tải API khi bật online
    } else {
      orderList.clear(); // Xóa đơn khi offline
    }
  }

  /// Xử lý nút "Chi tiết"
  void viewDetail(ManagerOrder order) {
    Get.snackbar("Thông báo", "Chuyển đến chi tiết đơn: ${order.id.substring(0, 8)}...");
    // TODO: Mở màn hình chi tiết thật
    // Get.toNamed(AppRoutes.orderDetail, arguments: order);
  }

  /// Hiển thị popup xác nhận
  void showAcceptConfirmation(ManagerOrder order) {
    Get.dialog(
      AcceptOrderDialog(order: order),
      barrierDismissible: false,
    );
  }

  /// Xử lý Gọi khách
  Future<void> callCustomer(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar("Lỗi", "Nông dân này chưa cập nhật SĐT.");
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar("Lỗi", "Không thể thực hiện cuộc gọi đến $phoneNumber");
    }
  }

  /// --- ✅ 4. VIẾT LẠI HÀM ACCEPTORDER ĐỂ GỌI API ---
  Future<void> acceptOrder(ManagerOrder order) async {
    // (Chúng ta không dùng isLoading(true) ở đây để tránh
    // làm toàn bộ màn hình bị mờ, chỉ xử lý trong try/catch)
    try {
      // 1. Gọi API "Nhận đơn"
      await _orderService.acceptDelivery(order.id);

      // 2. Đóng popup
      Get.back();
      Get.snackbar("Thành công", "Đã nhận đơn. Chuẩn bị đi lấy hàng.");

      // 3. Xóa đơn hàng khỏi danh sách (cập nhật UI)
      orderList.remove(order);

      // 4. Điều hướng đến màn hình Lấy hàng (Map)
      Get.toNamed(AppRoutes.pickupMap, arguments: order);

    } catch (e) {
      Get.back(); // Đóng popup nếu lỗi
      Get.snackbar(
        "Nhận đơn thất bại",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}