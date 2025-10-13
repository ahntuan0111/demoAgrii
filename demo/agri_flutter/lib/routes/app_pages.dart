import 'package:agri_flutter/bindings/location_check_binding.dart';
import 'package:agri_flutter/bindings/otp_binding.dart';
import 'package:agri_flutter/bindings/welcome_binding.dart';
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:agri_flutter/screens/location_check_screen.dart';
import 'package:agri_flutter/screens/otp_screen.dart';
import 'package:agri_flutter/screens/otp_verification_screen.dart';
import 'package:agri_flutter/screens/welcome_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.welcome,
      page: () => WelcomeScreen(),
      binding: WelcomeBinding(),
    ),
    GetPage(name: AppRoutes.otp, page: () => OtpScreen()),

    GetPage(
      name: AppRoutes.otpVerification,
      page: () => OtpVerificationScreen(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: AppRoutes.locationCheck,
      page: () => const LocationCheckScreen(),
      binding: LocationCheckBinding(),
    ),
  ];
}
