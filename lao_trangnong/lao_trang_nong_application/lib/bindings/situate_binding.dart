
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

import '../controllers/situate_controller.dart';

class SituateBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<SituateController>(() => SituateController());
  }
}