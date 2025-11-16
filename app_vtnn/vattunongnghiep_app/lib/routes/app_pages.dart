// routes/app_pages.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../bindings/auth_binding.dart';
import '../bindings/create_purchase_order_binding.dart';
import '../bindings/location_check_binding.dart';
import '../bindings/purchase_order_detail_binding.dart';
import '../bindings/purchase_order_list_binding.dart';
import '../bindings/situate_binding.dart';
// import '../bindings/vtnn_order_list_binding.dart'; // <-- 1. XÓA BINDING
import '../bindings/vtnn_order_detail_binding.dart';
import '../bindings/welcome_binding.dart';
import '../screens/create_purchase_order_screen.dart';
import '../screens/location_check_screen.dart';
import '../screens/login_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/purchase_order_detail_screen.dart';
import '../screens/purchase_order_list_screen.dart';
import '../screens/register_screen.dart';
import '../screens/situate_screen.dart';
import '../screens/vtnn_order_detail_screen.dart';
import '../screens/welcome_screen.dart';
import '../shared/widgets/bottom_navigation.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
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
      name: AppRoutes.bottomNavigation,
      page: () => BottomNavigation(),
      // (Không cần binding ở đây nữa vì đã Put() trong main)
    ),
    GetPage(
      name: AppRoutes.vtnnHomePage,
      page: () => BottomNavigation(),
    ),
    GetPage(
      name: AppRoutes.purchaseOrderList,
      page: () => PurchaseOrderListScreen(),
      binding: PurchaseOrderListBinding(),
    ),
    GetPage(
      name: AppRoutes.createPurchaseOrder,
      page: () => const CreatePurchaseOrderScreen(),
      binding: CreatePurchaseOrderBinding(),
      fullscreenDialog: true, // Mở lên như một popup
    ),
    GetPage(
      name: AppRoutes.purchaseOrderDetail,
      page: () => const PurchaseOrderDetailScreen(),
      binding: PurchaseOrderDetailBinding(),
      fullscreenDialog: true, // Mở lên như một popup
      opaque: false, // Làm mờ nền
    ),
    GetPage(
      name: AppRoutes.vtnnOrderDetail,
      page: () => const VtnnOrderDetailScreen(),
      binding: VtnnOrderDetailBinding(),
    ),
  ];
}