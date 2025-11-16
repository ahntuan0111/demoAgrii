// bindings/create_purchase_order_binding.dart
import 'package:get/get.dart';
import '../controllers/create_purchase_order_controller.dart';
// (Đảm bảo bạn đã đăng ký ProductService trong main.dart)
// import 'package:agri_flutter/services/product_service.dart';

class CreatePurchaseOrderBinding extends Bindings {
  @override
  void dependencies() {
    // (Nếu ProductService chưa được đăng ký vĩnh viễn, hãy đăng ký ở đây)
    // Get.lazyPut<ProductService>(() => ProductService());

    Get.lazyPut<CreatePurchaseOrderController>(() => CreatePurchaseOrderController());
  }
}