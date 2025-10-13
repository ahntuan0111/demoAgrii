import 'package:agri_flutter/controllers/situate_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

class SituateBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<SituateController>(() => SituateController());
  }
}