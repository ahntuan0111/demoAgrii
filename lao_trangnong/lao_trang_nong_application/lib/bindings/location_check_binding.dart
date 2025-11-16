
import 'package:get/get.dart';
import '../controllers/location_check_controller.dart';


class LocationCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationCheckController>(() => LocationCheckController());
  }
}
