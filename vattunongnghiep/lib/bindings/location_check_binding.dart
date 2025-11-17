
import 'package:agri_flutter/controllers/location_check_controller.dart';
import 'package:get/get.dart';


class LocationCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationCheckController>(() => LocationCheckController());
  }
}
