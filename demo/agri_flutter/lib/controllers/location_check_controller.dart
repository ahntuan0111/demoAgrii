import 'package:agri_flutter/routes/app_routes.dart';
import 'package:get/get.dart';


class LocationCheckController extends GetxController {
  var progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    simulateCheck();
  }

 Future<void> simulateCheck() async {
  for (int i = 0; i <= 100; i += 10) {
    await Future.delayed(const Duration(milliseconds: 300));
    progress.value = i / 100;
  }

  await Future.delayed(const Duration(milliseconds: 800));

  if (Get.isRegistered<LocationCheckController>()) {
    Get.toNamed(AppRoutes.welcome);
  }
}

}
