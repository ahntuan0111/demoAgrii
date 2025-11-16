import 'package:get/get.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;

  void nextPage() {
    if (currentPage.value < 2) {
      currentPage.value++;
    } else {
      Get.offAllNamed('/welcome');
    }
  }

  void skip() {
    Get.offAllNamed('/welcome');
  }
}
