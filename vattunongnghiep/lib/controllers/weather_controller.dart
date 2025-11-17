import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class WeatherHomeController extends GetxController {
  final temperature = 0.0.obs;
  final rainfall = 0.0.obs;
  final windSpeed = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData();
  }

  void fetchWeatherData() async {
    // Gọi API hoặc lấy dữ liệu local ở đây
    temperature.value = 30.5;
    rainfall.value = 10;
    windSpeed.value = 15;
  }
}