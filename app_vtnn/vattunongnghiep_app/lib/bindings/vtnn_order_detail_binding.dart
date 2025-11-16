// bindings/vtnn_order_list_binding.dart
import 'package:get/get.dart';
import '../controllers/vtnn_order_detail_controller.dart';

class VtnnOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VtnnOrderDetailController>(() => VtnnOrderDetailController());
  }
}