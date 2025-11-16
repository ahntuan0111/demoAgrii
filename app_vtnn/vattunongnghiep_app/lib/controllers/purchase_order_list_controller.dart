// controllers/purchase_order_list_controller.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/purchase_order_model.dart';
import '../routes/app_routes.dart';
import '../services/purchase_order_service.dart';

class PurchaseOrderListController extends GetxController {
  final PurchaseOrderService _poService = Get.find<PurchaseOrderService>();

  final isLoading = true.obs;
  final poList = <PurchaseOrder>[].obs;

  // Dùng để format ngày tháng (vd: 07:00 12/11/2025)
  final dateFormatter = DateFormat('HH:mm dd/MM/yyyy', 'vi_VN');

  // Dữ liệu giả cho các thẻ đếm (lấy từ API Dashboard sau)
  final pendingCount = 1.obs;
  final shippingCount = 0.obs;
  final completedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPurchaseOrders();
  }

  /// Tải danh sách đơn đặt hàng từ API
  Future<void> fetchPurchaseOrders() async {
    try {
      isLoading(true);
      final orders = await _poService.getMyPurchaseOrders();
      poList.assignAll(orders);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  /// Xử lý nút "Tạo đơn đặt hàng mới"
  void createNewPurchaseOrder() {
    // TODO: Điều hướng đến màn hình tạo PO (chưa làm)
    Get.toNamed(AppRoutes.createPurchaseOrder);
  }

  /// Xử lý khi nhấn vào xem chi tiết 1 PO
  void viewPurchaseOrderDetail(PurchaseOrder po) {
    // TODO: Điều hướng đến màn hình chi tiết PO (chưa làm)
    Get.toNamed(AppRoutes.purchaseOrderDetail, arguments: po);
  }
}