import 'package:agri_flutter/bindings/location_check_binding.dart';
import 'package:agri_flutter/bindings/login_binding.dart';
import 'package:agri_flutter/bindings/otp_binding.dart';
import 'package:agri_flutter/bindings/register_binding.dart';
import 'package:agri_flutter/bindings/role_select_binding.dart';
import 'package:agri_flutter/bindings/situate_binding.dart';
import 'package:agri_flutter/bindings/welcome_binding.dart';
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:agri_flutter/screens/location_check_screen.dart';
import 'package:agri_flutter/screens/otp_screen.dart';
import 'package:agri_flutter/screens/otp_verification_screen.dart';
import 'package:agri_flutter/screens/register_screen.dart';
import 'package:agri_flutter/screens/role_select_screen.dart';
import 'package:agri_flutter/screens/situate_screen.dart';
import 'package:agri_flutter/screens/welcome_screen.dart';
import 'package:agri_flutter/screens/login_screen.dart';
import 'package:get/get.dart';
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
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.situate,
      page: () => SituateScreen(),
      binding: SituateBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelect,
      page: () =>  RoleSelectScreen(),
      binding: RoleSelectBinding(),
    ),
  ];
}
