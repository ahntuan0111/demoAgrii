import 'package:get/get.dart';
import '../controllers/order_reception_controller.dart';
import '../services/order_service.dart';

class OrderReceptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderService>(() => OrderService());

    // Controller
    Get.lazyPut<OrderReceptionController>(() => OrderReceptionController());
  }
}