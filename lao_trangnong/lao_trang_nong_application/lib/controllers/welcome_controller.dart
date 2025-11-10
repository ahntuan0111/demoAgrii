
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:get/get.dart';


class WelcomeController extends GetxController {
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }
}
