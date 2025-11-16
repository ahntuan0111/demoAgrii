// controllers/auth_controller.dart (DÀNH CHO APP VTNN)
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final GetStorage _storage = GetStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // --- Trạng thái chung ---
  final isLoading = false.obs;

  // --- Form Keys ---
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final phoneFormKey = GlobalKey<FormState>();

  // --- Controllers cho Đăng ký ---
  final fullNameController = TextEditingController(); // Sẽ là Tên Cửa Hàng
  final registerUsernameController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final isRegisterPasswordHidden = true.obs;

  // --- Controllers cho Đăng nhập ---
  final loginUsernameController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final isLoginPasswordHidden = true.obs;

  // --- Controllers cho OTP ---
  final phoneController = TextEditingController();
  final verificationId = ''.obs;
  final List<TextEditingController> otpFields = List.generate(
      6, (index) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(
      6, (index) => FocusNode());

  final verifiedPhoneNumber = Rxn<String>();
  final isResendEnabled = false.obs;
  final countdown = 30.obs;
  Timer? _timer;

  // --- Khởi tạo ---
  @override
  void onInit() {
    super.onInit();
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes[0].requestFocus();
    }
  }

  // --- Hủy (Dispose) ---
  @override
  void onClose() {
    // Huỷ tất cả controllers
    fullNameController.dispose();
    registerUsernameController.dispose();
    registerPasswordController.dispose();
    loginUsernameController.dispose();
    loginPasswordController.dispose();
    phoneController.dispose();
    for (var controller in otpFields) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.onClose();
  }

  // --- LOGIC ĐĂNG NHẬP (Giữ nguyên) ---
  void toggleLoginPasswordVisibility() {
    isLoginPasswordHidden.value = !isLoginPasswordHidden.value;
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading(true);
    try {
      final username = loginUsernameController.text.trim();
      final password = loginPasswordController.text.trim();
      final response = await _authService.login(username, password);
      await _storage.write('apiToken', response['token']);
      await _storage.write('user', response['user']);
      Get.snackbar("Thành công", "Đăng nhập thành công!");
      Get.offAllNamed(AppRoutes.situate); // Chuyển đến SituateScreen
    } catch (e) {
      Get.snackbar("Đăng nhập thất bại",
          e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIC ĐĂNG KÝ (Giữ nguyên - 4 tham số) ---
  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    // 1. Kiểm tra SĐT (Giữ nguyên)
    if (verifiedPhoneNumber.value == null) {
      Get.snackbar("Lỗi", "Vui lòng xác thực SĐT trước khi đăng ký.");
      Get.offNamed(AppRoutes.otp);
      return;
    }

    isLoading(true);
    try {
      final fullName = fullNameController.text.trim();
      final username = registerUsernameController.text.trim();
      final password = registerPasswordController.text.trim();

      // 2. GỌI API THẬT (với 4 tham số)
      final response = await _authService.register(
        fullName,
        username,
        password,
        verifiedPhoneNumber.value!,
      );

      // 3. ĐĂNG KÝ THÀNH CÔNG -> ĐĂNG NHẬP LUÔN
      await _storage.write('apiToken', response['token']);
      await _storage.write('user', response['user']);

      Get.snackbar("Thành công", "Đăng ký thành công!");
      Get.offAllNamed(AppRoutes.situate);
    } catch (e) {
      Get.snackbar("Đăng ký thất bại",
          e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
      verifiedPhoneNumber.value = null;
    }
  }

  // --- LOGIC OTP (Giữ nguyên) ---
  void startCountdown() {
    countdown.value = 30;
    isResendEnabled.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        isResendEnabled.value = true;
        t.cancel();
      }
    });
  }

  Future<void> sendOtp() async {
    if (!phoneFormKey.currentState!.validate()) return;
    isLoading(true);
    try {
      String phoneNumber = phoneController.text.trim();
      if (phoneNumber.startsWith('0')) {
        phoneNumber = '+84${phoneNumber.substring(1)}';
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _handleOtpSuccess(credential);
          isLoading(false);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar("Lỗi", "Gửi OTP thất bại: ${e.message}");
          isLoading(false);
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          isLoading(false);
          Get.toNamed('/otpVerification');
          startCountdown();
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
          isLoading(false);
          Get.snackbar("Hết giờ", "Hết thời gian chờ SMS. Vui lòng thử lại.");
        },
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể gửi OTP: ${e.toString()}");
      isLoading(false);
    }
  }

  void resendOtp() {
    if (isResendEnabled.value) {
      sendOtp();
    }
  }

  Future<void> verifyOtp() async {
    final code = otpFields.map((c) => c.text).join();
    if (code.length < 6) {
      Get.snackbar("Lỗi", "Vui lòng nhập đủ 6 số!");
      return;
    }
    isLoading(true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: code,
      );

      await _handleOtpSuccess(credential);

    } on FirebaseAuthException catch (e) {
      Get.snackbar("Lỗi", "Mã OTP không đúng hoặc hết hạn!");
      isLoading(false);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
      isLoading(false);
    }
  }

  /// Xử lý sau khi OTP thành công (Giữ nguyên)
  Future<void> _handleOtpSuccess(PhoneAuthCredential credential) async {
    final userCredential = await _firebaseAuth.signInWithCredential(
      credential,
    );

    if (userCredential.user != null) {
      verifiedPhoneNumber.value = userCredential.user!.phoneNumber;
      for (var controller in otpFields) {
        controller.clear();
      }
      Get.snackbar(
        "Thành công",
        "Xác minh SĐT thành công! Vui lòng hoàn tất đăng ký.",
      );
      Get.offNamed(AppRoutes.register);
    }
  }

  // --- VALIDATION & NAVIGATION (Giữ nguyên) ---
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Tên tài khoản không được để trống";
    }
    if (value.length < 3) {
      return "Tên tài khoản phải có ít nhất 3 ký tự";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Mật khẩu không được để trống";
    }
    if (value.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return "Họ tên không được để trống";
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Số điện thoại không được để trống";
    }
    if (value.length != 10 || !value.startsWith('0')) {
      return "Số điện thoại không hợp lệ";
    }
    return null;
  }

  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  void goToRegister() {
    Get.offNamed(AppRoutes.otp);
  }
}