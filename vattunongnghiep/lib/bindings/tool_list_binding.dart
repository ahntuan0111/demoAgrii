// bindings/tool_list_binding.dart

import 'package:get/get.dart';
import '../controllers/tool_list_controller.dart';

class ToolListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ToolListController>(() => ToolListController());
  }
}