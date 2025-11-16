// bindings/pickup_map_binding.dart
import 'package:get/get.dart';
import '../controllers/pickup_map_controller.dart';

class PickupMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PickupMapController>(() => PickupMapController());
  }
}