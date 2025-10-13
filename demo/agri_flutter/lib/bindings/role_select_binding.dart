import 'package:agri_flutter/controllers/role_select_controller.dart';
import 'package:get/get.dart';

class RoleSelectBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<RoleSelectController>(() => RoleSelectController());
  }
}