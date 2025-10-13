import 'dart:async';
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:get/get.dart';


class OtpController extends GetxController {
  var phoneNumber = ''.obs;
  var otpCode = ''.obs;
  var isResendEnabled = false.obs;
  var countdown = 30.obs;
  Timer? timer;

  void sendOtp(String phone) {
    if (phone.isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng nhập số điện thoại!");
      return;
    }

    if (phone.length != 10 && !phone.startsWith('0')) {
      Get.snackbar("Lỗi", "Số điện thoại không hợp lệ!");
      return;
    }

    phoneNumber.value = phone;
    Get.toNamed(AppRoutes.otpVerification);
    startCountdown();
  }

  void startCountdown() {
    countdown.value = 30;
    isResendEnabled.value = false;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        isResendEnabled.value = true;
        t.cancel();
      }
    });
  }

  void verifyOtp(String code) {
    if (code.length < 6) {
      Get.snackbar("Lỗi", "Vui lòng nhập đủ 6 số!");
      return;
    }
    Get.snackbar("Thành công", "Xác minh OTP thành công!");
    Get.offAllNamed(AppRoutes.register);
  }

  void resendOtp() {
    if (!isResendEnabled.value) return;
    Get.snackbar("Thông báo", "Đã gửi lại mã OTP!");
    startCountdown();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
