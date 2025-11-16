// Thêm 2 import này
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Đăng ký AuthController, fenix: true để giữ state
    // (như text đã nhập) khi chuyển qua lại các màn hình auth
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}