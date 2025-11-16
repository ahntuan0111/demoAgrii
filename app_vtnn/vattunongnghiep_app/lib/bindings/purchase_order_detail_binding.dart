// bindings/purchase_order_detail_binding.dart
import 'package:get/get.dart';
import '../controllers/purchase_order_detail_controller.dart';

class PurchaseOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchaseOrderDetailController>(() => PurchaseOrderDetailController());
  }
}