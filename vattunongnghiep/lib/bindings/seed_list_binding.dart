// bindings/seed_list_binding.dart

import 'package:get/get.dart';
import '../controllers/seed_list_controller.dart';

class SeedListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeedListController>(() => SeedListController());
  }
}