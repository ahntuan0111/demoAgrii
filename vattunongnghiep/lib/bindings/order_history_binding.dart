// bindings/order_history_binding.dart
import 'package:get/get.dart';
import 'package:agri_flutter/controllers/order_history_controller.dart';

class OrderHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
  }
}