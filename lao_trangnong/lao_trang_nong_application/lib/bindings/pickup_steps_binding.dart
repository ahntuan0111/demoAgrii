// bindings/pickup_steps_binding.dart
import 'package:get/get.dart';

import '../controllers/pickup_steps_controller.dart';

class PickupStepsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PickupStepsController>(() => PickupStepsController());
  }
}