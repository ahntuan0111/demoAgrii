import 'dart:async';
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final fullNameController = TextEditingController();
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
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  // --- BIẾN MỚI ---
  // Dùng để lưu SĐT đã được xác thực
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

  // --- ------------------ ---
  // --- LOGIC ĐĂNG NHẬP (Giữ nguyên - Đã đúng) ---
  // --- ------------------ ---
  void toggleLoginPasswordVisibility() {
    isLoginPasswordHidden.value = !isLoginPasswordHidden.value;
  }

  Future<void> login() async {
    // (Hàm login của bạn đã đúng, giữ nguyên)
    if (!loginFormKey.currentState!.validate()) return;
    isLoading(true);
    try {
      final username = loginUsernameController.text.trim();
      final password = loginPasswordController.text.trim();
      final response = await _authService.login(username, password);
      await _storage.write('apiToken', response['token']);
      await _storage.write('user', response['user']);
      Get.snackbar(
        "Thành công",
        "Đăng nhập thành công!",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.situate);
    } catch (e) {
      Get.snackbar(
        "Đăng nhập thất bại",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // --- ------------------- ---
  // --- LOGIC ĐĂNG KÝ (ĐÃ CẬP NHẬT) ---
  // --- ------------------- ---
  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    // Kiểm tra xem SĐT đã được xác thực chưa
    if (verifiedPhoneNumber.value == null) {
      Get.snackbar("Lỗi", "Vui lòng xác thực SĐT trước khi đăng ký.");
      Get.offNamed(AppRoutes.otp); // Đưa người dùng về màn hình OTP
      return;
    }

    isLoading(true);
    try {
      final fullName = fullNameController.text.trim();
      final username = registerUsernameController.text.trim();
      final password = registerPasswordController.text.trim();

      // 7. GỌI API THẬT (với SĐT đã xác thực)
      final response = await _authService.register(
        fullName,
        username,
        password,
        verifiedPhoneNumber.value!, // <-- THÊM SĐT VÀO
      );

      // 8. ĐĂNG KÝ THÀNH CÔNG -> ĐĂNG NHẬP LUÔN
      await _storage.write('apiToken', response['token']);
      await _storage.write('user', response['user']);

      Get.snackbar(
        "Thành công",
        "Đăng ký thành công!",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.situate);
    } catch (e) {
      Get.snackbar(
        "Đăng ký thất bại",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
      verifiedPhoneNumber.value = null; // Xóa SĐT sau khi đăng ký
    }
  }

  // --- ------------------- ---
  // --- LOGIC OTP (ĐÃ CẬP NHẬT) ---
  // --- ------------------- ---
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
          // Tự động xác thực
          final userCredential = await _firebaseAuth.signInWithCredential(
            credential,
          );
          if (userCredential.user != null) {
            verifiedPhoneNumber.value = userCredential.user!.phoneNumber;
            Get.offNamed(AppRoutes.register); // Đi đến màn hình Đăng ký
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar("Lỗi", "Gửi OTP thất bại: ${e.message}");
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          Get.toNamed('/otpVerification');
          startCountdown();
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể gửi OTP: ${e.toString()}");
    } finally {
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

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // --- SỬA LOGIC TẠI ĐÂY ---
      if (userCredential.user != null) {
        // 1. Lấy SĐT đã xác thực
        verifiedPhoneNumber.value = userCredential.user!.phoneNumber;

        // 2. Xóa các ô OTP
        for (var controller in otpFields) {
          controller.clear();
        }

        // 3. Thông báo và điều hướng đến màn hình Đăng ký
        Get.snackbar(
          "Thành công",
          "Xác minh SĐT thành công! Vui lòng hoàn tất đăng ký.",
        );
        Get.offNamed(AppRoutes.register); // <-- ĐÂY LÀ SỬA ĐỔI QUAN TRỌNG
      }
      // --------------------------
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Lỗi", "Mã OTP không đúng hoặc hết hạn!");
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  /// Hàm nội bộ để gọi API Node.js sau khi Firebase xác thực thành công
  Future<void> _verifyFirebaseTokenAndLogin() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("Không tìm thấy người dùng Firebase!");
    }

    // Lấy Firebase ID Token
    String? firebaseToken = await user.getIdToken();
    if (firebaseToken == null) {
      throw Exception("Không thể lấy Firebase token!");
    }

    // GỌI API NODE.JS CỦA BẠN
    final response = await _authService.loginOrRegisterWithPhoneToken(
      firebaseToken,
    );

    // LƯU TOKEN SERVER VÀ USER
    await _storage.write('apiToken', response['token']);
    await _storage.write('user', response['user']);

    Get.snackbar("Thành công", "Đăng nhập bằng SĐT thành công!");
    Get.offAllNamed(AppRoutes.situate); // Chuyển đến màn hình chính
  }

  // --- ------------------- ---
  // --- VALIDATION METHODS ---
  // --- ------------------- ---

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

  // --- ------------------- ---
  // --- NAVIGATION ---
  // --- ------------------- ---

  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  void goToRegister() {
    // Chúng ta nên đi đến màn hình OTP trước khi đăng ký
    // Giả sử route của OtpScreen là 'otp'
    Get.offNamed(AppRoutes.otp);
  }
}