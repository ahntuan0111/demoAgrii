import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/manager_order_model.dart';
import '../routes/app_routes.dart';
import '../screens/order_reception_screen.dart';
import '../services/order_service.dart';

class OrderReceptionController extends GetxController with WidgetsBindingObserver {
  final OrderService _orderService = Get.find<OrderService>();

  final isLoading = true.obs;
  final orderList = <ManagerOrder>[].obs;
  final isOnline = true.obs;

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final distanceFormatter = NumberFormat("###.0#", "vi_VN");

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchOrders();
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

  Future<void> fetchOrders() async {
    if (!isOnline.value) {
      orderList.clear();
      return;
    }
    isLoading(true);
    try {
      final List<ManagerOrder> orders = await _orderService.getManagerOrders();
      orderList.assignAll(orders);
    } catch (e) {
      Get.snackbar(
        "Lỗi tải đơn hàng",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
      orderList.clear();
    } finally {
      isLoading(false);
    }
  }

  void toggleOnlineStatus(bool value) {
    isOnline.value = value;
    if (value) {
      fetchOrders();
    } else {
      orderList.clear();
    }
  }

  void viewDetail(ManagerOrder order) {
    // Bạn có thể điều hướng đến màn hình chi tiết đơn hàng (chỉ xem) ở đây
    Get.snackbar("Thông báo", "Xem chi tiết đơn: ${order.id}");
  }

  void showAcceptConfirmation(ManagerOrder order) {
    Get.dialog(
      AcceptOrderDialog(order: order),
      barrierDismissible: false,
    );
  }

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

  Future<void> acceptOrder(ManagerOrder order) async {
    try {
      await _orderService.acceptDelivery(order.id);
      Get.back(); // Đóng dialog
      Get.snackbar("Thành công", "Đã nhận đơn. Chuẩn bị đi lấy hàng.");

      // Cập nhật lại danh sách để UI đổi trạng thái ngay lập tức
      fetchOrders();

      // Điều hướng đến màn hình Lấy hàng
      Get.toNamed(AppRoutes.pickupMap, arguments: order);
    } catch (e) {
      Get.back();
      Get.snackbar("Nhận đơn thất bại", e.toString().replaceFirst("Exception: ", ""), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // --- ✅ HÀM MỚI: XỬ LÝ LOGIC ĐIỀU HƯỚNG THÔNG MINH ---
  void handleOrderAction(ManagerOrder order) {
    switch (order.status) {
      case 'ready_for_pickup':
      // Trạng thái 1: Chưa nhận -> Hiện Popup nhận đơn
        showAcceptConfirmation(order);
        break;

      case 'awaiting_payment':
      // Trạng thái 2: Đã nhận, đang đi lấy -> Mở lại bản đồ Lấy hàng (PickupMap)
        Get.toNamed(AppRoutes.pickupMap, arguments: order);
        break;

      case 'out_for_delivery':
      // Trạng thái 3: Đã lấy, đang đi giao -> Mở bản đồ Giao hàng (DeliveryMap)
      // (Hiện tại nếu bạn chưa có DeliveryMap, có thể dùng tạm PickupMap hoặc hiển thị thông báo)
        Get.snackbar("Thông báo", "Tiếp tục giao hàng cho khách: ${order.customerName}");
        // TODO: Get.toNamed(AppRoutes.deliveryMap, arguments: order);
        break;

      case 'delivered':
        Get.snackbar("Thông báo", "Đơn hàng đã giao thành công.");
        break;

      default:
        Get.snackbar("Thông báo", "Trạng thái đơn hàng: ${order.status}");
    }
  }
}