// Thêm 2 import này
import 'package:agri_flutter/controllers/auth_controller.dart';
import 'package:agri_flutter/services/auth_service.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Đăng ký AuthController, fenix: true để giữ state
    // (như text đã nhập) khi chuyển qua lại các màn hình auth
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}