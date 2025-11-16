// bindings/kyc_binding.dart

import 'package:get/get.dart';

import '../controllers/kyc_controller.dart';

class KycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycController>(() => KycController());
  }
}