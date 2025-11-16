import 'package:get/get.dart';
import 'package:lao_trang_nong_application/screens/onboarding_screen.dart';

import '../bindings/account_setup_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/delivery_binding.dart';
import '../bindings/kyc_binding.dart';
import '../bindings/location_check_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../bindings/order_reception_binding.dart';
import '../bindings/permission_binding.dart';
import '../bindings/pickup_map_binding.dart';
import '../bindings/pickup_steps_binding.dart';
import '../bindings/report_issue_binding.dart';
import '../bindings/situate_binding.dart';
import '../bindings/welcome_binding.dart';
import '../screens/account_setup_screen.dart';
import '../screens/delivery_screen.dart';
import '../screens/home_screen.dart';
import '../screens/kyc_screen.dart';
import '../screens/location_check_screen.dart';
import '../screens/login_screen.dart';
import '../screens/order_reception_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/permission_screen.dart';
import '../screens/pickup_map_screen.dart';
import '../screens/pickup_steps_screen.dart';
import '../screens/register_screen.dart';
import '../screens/report_issue_screen.dart';
import '../screens/situate_screen.dart';
import '../screens/welcome_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => WelcomeScreen(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => OtpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => OtpVerificationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.locationCheck,
      page: () => LocationCheckScreen(),
      binding: LocationCheckBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.situate,
      page: () => SituateScreen(),
      binding: SituateBinding(),
    ),
    GetPage(
      name: AppRoutes.permission,
      page: () => const PermissionScreen(),
      binding: PermissionBinding(),
    ),
    GetPage(
      name: AppRoutes.kyc,
      page: () => const KycScreen(),
      binding: KycBinding(),
    ),
    GetPage(
      name: AppRoutes.accountSetup,
      page: () => const AccountSetupScreen(),
      binding: AccountSetupBinding(),
    ),
    GetPage(
      name: AppRoutes.homePage,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.orderReception, // (Tên route của bạn cho màn hình này)
      page: () => const OrderReceptionScreen(),
      binding: OrderReceptionBinding(), // <-- Gán binding mới
    ),
    GetPage(
      name: AppRoutes.pickupMap,
      page: () => PickupMapScreen(),
      binding: PickupMapBinding(),
    ),
    GetPage(
      name: AppRoutes.pickupSteps,
      page: () => PickupStepsScreen(),
      binding: PickupStepsBinding(),
    ),
    GetPage(
      name: AppRoutes.deliveryScreen,
      page: () => const DeliveryScreen(),
      binding: DeliveryBinding(),
    ),
    GetPage(
      name: AppRoutes.reportIssue,
      page: () => const ReportIssueScreen(),
      binding: ReportIssueBinding(),
    ),
  ];
}
