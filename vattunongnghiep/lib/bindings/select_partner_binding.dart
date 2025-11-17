// bindings/select_partner_binding.dart
import 'package:get/get.dart';
import 'package:agri_flutter/controllers/select_partner_controller.dart';

class SelectPartnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectPartnerController>(() => SelectPartnerController());
  }
}