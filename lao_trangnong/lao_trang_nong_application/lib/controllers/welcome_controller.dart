import 'package:get/get.dart';

import '../routes/app_routes.dart';


class WelcomeController extends GetxController {
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }
}
