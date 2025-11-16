// controllers/vtnn_order_list_controller.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/vtnn_order_model.dart';
import '../routes/app_routes.dart';
import '../services/vtnn_order_service.dart';

class VtnnOrderListController extends GetxController {
  final VtnnOrderService _orderService = Get.find<VtnnOrderService>();

  final isLoading = true.obs;

  // Danh sách
  final allOrders = <VtnnOrder>[].obs; // Danh sách GỐC
  final filteredOrders = <VtnnOrder>[].obs; // Danh sách đã lọc (để hiển thị)

  // Tabs
  final selectedStatusTab = 'Tất cả'.obs;
  final tabs = [
    'Tất cả',
    'Đang xử lý', // (pending_vtnn_prep, preparing)
    'Chờ thu tiền', // (awaiting_payment, delivered)
    'Đã thu tiền' // (completed)
    'Hoàn tất'
  ];

  // Format tiền
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
  }

  /// Tải TẤT CẢ đơn hàng từ API
  Future<void> fetchAllOrders() async {
    try {
      isLoading(true);
      final orders = await _orderService.getStoreOrders();
      allOrders.assignAll(orders);
      // Lọc theo tab hiện tại (mặc định là 'Tất cả')
      filterOrders(selectedStatusTab.value);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  /// Lọc danh sách dựa trên tab
  void filterOrders(String tabName) {
    selectedStatusTab.value = tabName;

    if (tabName == 'Tất cả') {
      filteredOrders.assignAll(allOrders);
    }
    else if (tabName == 'Đang xử lý') {
      filteredOrders.assignAll(allOrders.where((order) =>
      order.status == 'pending_vtnn_prep' || order.status == 'preparing'));
    }
    else if (tabName == 'Chờ thu tiền') {
      // (Theo BE, Lão Nông thanh toán khi status là 'awaiting_payment',
      //  VTNN xác nhận và chuyển sang 'out_for_delivery')
      filteredOrders.assignAll(allOrders.where((order) =>
      order.status == 'ready_for_pickup' ||
          order.status == 'awaiting_payment'));
    }
    else if (tabName == 'Đã thu tiền') {
      filteredOrders.assignAll(allOrders.where((order) =>
      order.status == 'out_for_delivery' ||
          order.status == 'delivered' ||
          order.status == 'completed'));
    }
  }

  /// Xử lý khi nhấn vào xem chi tiết 1 đơn hàng
  void viewOrderDetail(VtnnOrder order) {
    Get.toNamed(AppRoutes.vtnnOrderDetail, arguments: order);
  }
}