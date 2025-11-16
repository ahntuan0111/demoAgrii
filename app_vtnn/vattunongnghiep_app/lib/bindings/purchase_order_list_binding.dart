// bindings/purchase_order_list_binding.dart
import 'package:get/get.dart';
import '../controllers/purchase_order_list_controller.dart';
class PurchaseOrderListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchaseOrderListController>(() => PurchaseOrderListController());
  }
}