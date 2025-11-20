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

  // --- Controllers ---
  final fullNameController = TextEditingController();
  final registerUsernameController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final isRegisterPasswordHidden = true.obs;

  final loginUsernameController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final isLoginPasswordHidden = true.obs;

  final phoneController = TextEditingController();
  final verificationId = ''.obs;
  final List<TextEditingController> otpFields = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());

  final verifiedPhoneNumber = Rxn<String>();
  final isResendEnabled = false.obs;
  final countdown = 60.obs;
  Timer? _timer;

  @override
  void onClose() {
    fullNameController.dispose();
    registerUsernameController.dispose();
    registerPasswordController.dispose();
    loginUsernameController.dispose();
    loginPasswordController.dispose();
    phoneController.dispose();
    for (var c in otpFields) c.dispose();
    for (var n in otpFocusNodes) n.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // --- LOGIC ĐĂNG NHẬP ---
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
      Get.offAllNamed(AppRoutes.situate);
    } catch (e) {
      Get.snackbar("Đăng nhập thất bại", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIC ĐĂNG KÝ (ĐÃ SỬA) ---
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
      final phoneNumber = verifiedPhoneNumber.value!;

      final response = await _authService.register(
        fullName,
        username,
        password,
        phoneNumber,
      );

      await _storage.write('apiToken', response['token']);
      await _storage.write('user', response['user']);

      // --- ✅ CHỈ XÓA SĐT KHI THÀNH CÔNG ---
      verifiedPhoneNumber.value = null;

      Get.snackbar("Thành công", "Đăng ký thành công!");
      Get.offAllNamed(AppRoutes.situate);
    } catch (e) {
      Get.snackbar("Đăng ký thất bại", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      // --- ✅ KHÔNG XÓA SĐT Ở ĐÂY (để user có thể thử lại nếu lỗi) ---
      isLoading(false);
    }
  }

  // --- LOGIC OTP (ĐÃ SỬA) ---
  void startCountdown() {
    countdown.value = 60;
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
      if (phoneNumber.startsWith('0')) phoneNumber = '+84${phoneNumber.substring(1)}';

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verify
          isLoading(true);
          try {
            await _signInWithCredential(credential);
          } catch (_) {} finally {
            isLoading(false);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading(false);
          Get.snackbar("Lỗi", "Gửi OTP thất bại: ${e.message}");
        },
        codeSent: (String verId, int? resendToken) {
          isLoading(false);
          verificationId.value = verId;
          Get.toNamed(AppRoutes.otpVerification);
          startCountdown();
        },
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
    if (isResendEnabled.value) sendOtp();
  }

  // --- HÀM VERIFY OTP (ĐÃ SỬA LỖI NÚT XOAY) ---
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
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Lỗi", "Mã OTP không đúng hoặc hết hạn!");
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      // --- ✅ QUAN TRỌNG: LUÔN TẮT LOADING ---
      isLoading(false);
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user != null) {
      verifiedPhoneNumber.value = userCredential.user!.phoneNumber;
      await _firebaseAuth.signOut();
      for (var controller in otpFields) controller.clear();

      Get.snackbar("Thành công", "Xác minh SĐT thành công!");
      Get.offNamed(AppRoutes.register);
    }
  }

  Future<void> _verifyFirebaseTokenAndLogin() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) throw Exception("Không tìm thấy người dùng Firebase!");
    String? firebaseToken = await user.getIdToken();
    if (firebaseToken == null) throw Exception("Không thể lấy Firebase token!");
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
    if (value == null || value.isEmpty) return "Tên tài khoản không được để trống";
    if (value.length < 3) return "Tên tài khoản phải có ít nhất 3 ký tự";
    return null;
  }
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Mật khẩu không được để trống";
    if (value.length < 6) return "Mật khẩu phải có ít nhất 6 ký tự";
    return null;
  }
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return "Họ tên không được để trống";
    return null;
  }
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Số điện thoại không được để trống";
    if (value.length != 10 || !value.startsWith('0')) return "Số điện thoại không hợp lệ";
    return null;
  }

  // --- ------------------- ---
  // --- NAVIGATION ---
  // --- ------------------- ---

// --- Navigation ---
  void goToLogin() => Get.offNamed(AppRoutes.login);
  void goToRegister() => Get.offNamed(AppRoutes.otp);

  // ✅ Quay về màn hình Welcome
  void goToWelcome() => Get.offAllNamed(AppRoutes.welcome);
}