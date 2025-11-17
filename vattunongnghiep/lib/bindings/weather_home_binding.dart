import 'package:get/get.dart';
import '../controllers/weather_controller.dart';

class WeatherHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WeatherHomeController());
  }
}