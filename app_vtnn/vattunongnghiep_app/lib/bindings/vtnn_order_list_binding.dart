// bindings/vtnn_order_list_binding.dart
import 'package:get/get.dart';
import '../controllers/vtnn_order_list_controller.dart';

class VtnnOrderListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VtnnOrderListController>(() => VtnnOrderListController());
  }
}