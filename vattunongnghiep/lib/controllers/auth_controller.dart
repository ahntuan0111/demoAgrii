import 'dart:async';
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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

  // --- BIẾN QUAN TRỌNG ---
  final verifiedPhoneNumber = Rxn<String>();

  final isResendEnabled = false.obs;
  final countdown = 60.obs; // Tăng lên 60s cho chuẩn
  Timer? _timer;

  // --- Khởi tạo ---
  @override
  void onInit() {
    super.onInit();
    // Không nên gọi requestFocus ở onInit của controller
    // Hãy để màn hình (View) tự xử lý autofocus
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
  // --- LOGIC ĐĂNG NHẬP ---
  // --- ------------------ ---
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
  // --- LOGIC ĐĂNG KÝ ---
  // --- ------------------- ---
  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

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

      final response = await _authService.register(
        fullName,
        username,
        password,
        verifiedPhoneNumber.value!,
      );

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
      verifiedPhoneNumber.value = null;
    }
  }

  // --- ------------------- ---
  // --- LOGIC OTP (ĐÃ CẬP NHẬT) ---
  // --- ------------------- ---
  void startCountdown() {
    countdown.value = 60; // Chuẩn 60s
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

        // --- 1. XỬ LÝ TỰ ĐỘNG (SỐ TEST / ANDROID AUTO-READ) ---
        // Đây là lý do "skip" màn hình
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Auto-retrieval (verificationCompleted) triggered.");
          isLoading(true);
          try {
            await _signInWithCredential(credential); // Gọi hàm chung
          } catch (e) {
            print("Auto-retrieval failed: ${e.toString()}");
            // Bắt lỗi (vd: session-expired) và bỏ qua
          } finally {
            isLoading(false);
          }
        },

        // --- 2. XỬ LÝ LỖI ---
        verificationFailed: (FirebaseAuthException e) {
          isLoading(false);
          Get.snackbar("Lỗi", "Gửi OTP thất bại: ${e.message}");
        },

        // --- 3. XỬ LÝ GỬI THÀNH CÔNG (CẦN NHẬP TAY) ---
        codeSent: (String verId, int? resendToken) {
          isLoading(false);
          verificationId.value = verId;

          // --- ✅ SỬA LỖI ĐƯỜNG DẪN TẠI ĐÂY ---
          Get.toNamed(AppRoutes.otpVerification); // Dùng AppRoutes
          // ----------------------------------

          startCountdown();
        },

        // --- 4. HẾT THỜI GIAN CHỜ TỰ ĐỘNG ---
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar("Lỗi", "Không thể gửi OTP: ${e.toString()}");
    }
  }

  void resendOtp() {
    if (isResendEnabled.value) {
      sendOtp();
    }
  }

  // --- HÀM XÁC MINH (NHẬP TAY) ---
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
      // Gọi hàm chung
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      Get.snackbar("Lỗi", "Mã OTP không đúng hoặc hết hạn!");
    } catch (e) {
      isLoading(false);
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // --- HÀM CHUNG ĐỂ XỬ LÝ XÁC THỰC ---
  // (Dùng cho cả auto-verify và nhập tay)
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    if (userCredential.user != null) {
      // 1. Lấy SĐT đã xác thực
      verifiedPhoneNumber.value = userCredential.user!.phoneNumber;

      // 2. ĐĂNG XUẤT KHỎI FIREBASE (Vì ta chỉ mượn Firebase để xác thực SĐT)
      await _firebaseAuth.signOut();
      print("Firebase signed out, phone number saved.");

      // 3. Xóa các ô OTP
      for (var controller in otpFields) {
        controller.clear();
      }

      // 4. Thông báo và điều hướng đến màn hình Đăng ký
      Get.snackbar(
        "Thành công",
        "Xác minh SĐT thành công! Vui lòng hoàn tất đăng ký.",
      );
      Get.offNamed(AppRoutes.register);
    }
  }


  /// Hàm này dùng cho flow "Đăng nhập bằng SĐT", không phải "Đăng ký"
  Future<void> _verifyFirebaseTokenAndLogin() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("Không tìm thấy người dùng Firebase!");
    }
    String? firebaseToken = await user.getIdToken();
    if (firebaseToken == null) {
      throw Exception("Không thể lấy Firebase token!");
    }
    final response = await _authService.loginOrRegisterWithPhoneToken(firebaseToken);
    await _storage.write('apiToken', response['token']);
    await _storage.write('user', response['user']);
    Get.snackbar("Thành công", "Đăng nhập bằng SĐT thành công!");
    Get.offAllNamed(AppRoutes.situate);
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
    Get.offNamed(AppRoutes.otp);
  }
}