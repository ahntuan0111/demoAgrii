// bindings/protection_product_list_binding.dart

import 'package:get/get.dart';
import '../controllers/protection_product_list_controller.dart';

class ProtectionProductListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProtectionProductListController>(() => ProtectionProductListController());
  }
}