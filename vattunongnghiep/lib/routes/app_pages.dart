import 'package:agri_flutter/bindings/location_check_binding.dart';
import 'package:agri_flutter/bindings/situate_binding.dart';
import 'package:agri_flutter/bindings/welcome_binding.dart';
import 'package:agri_flutter/models/product_model.dart';
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:agri_flutter/screens/location_check_screen.dart';
import 'package:agri_flutter/screens/module/famer/chat_history_screen.dart';
import 'package:agri_flutter/screens/otp_screen.dart';
import 'package:agri_flutter/screens/otp_verification_screen.dart';
import 'package:agri_flutter/screens/register_screen.dart';
import 'package:agri_flutter/screens/situate_screen.dart';
import 'package:agri_flutter/screens/welcome_screen.dart';
import 'package:agri_flutter/screens/login_screen.dart';
import 'package:agri_flutter/shared/widgets/bottom_navigation.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../bindings/auth_binding.dart';
import '../bindings/checkout_binding.dart';
import '../bindings/home_famer_binding.dart';
import '../bindings/order_history_binding.dart';
import '../bindings/organic_product_list_binding.dart';
import '../bindings/protection_product_list_binding.dart';
import '../bindings/seed_list_binding.dart';
import '../bindings/select_partner_binding.dart';
import '../bindings/tool_list_binding.dart';
import '../bindings/weather_home_binding.dart';
import '../screens/module/famer/chat_topic_screen.dart';
import '../screens/module/famer/chatbox_screen.dart';
import '../screens/module/famer/checkout_screen.dart';
import '../screens/module/famer/home_famer_screen.dart';
import '../screens/module/famer/order_confirmation_screen.dart';
import '../screens/module/famer/order_detail_screen.dart';
import '../screens/module/famer/order_history_screen.dart';
import '../screens/module/famer/organic_product_list_screen.dart';
import '../screens/module/famer/product_detail_screen.dart';
import '../screens/module/famer/protection_product_list_screen.dart';
import '../screens/module/famer/seed_list_screen.dart';
import '../screens/module/famer/select_partner_screen.dart';
import '../screens/module/famer/shopping_cart_screen.dart';
import '../screens/module/famer/tool_list_screen.dart';
import '../screens/module/famer/weather_home_screen.dart';

// --- ✅ THÊM IMPORT CÒN THIẾU ---

import '../bindings/cart_binding.dart';
// -----------------------------

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
    ),

    // --- ✅ THÊM GETPAGE CÒN THIẾU ---
    GetPage(
      name: AppRoutes.homeFamer,
      page: () => HomeFamerScreen(),
      binding: HomeFamerBinding(),
    ),
    // --- ✅ THÊM GETPAGE CÒN THIẾU ---
    GetPage(
      name: AppRoutes.cart,
      page: () => ShoppingCartScreen(),
      binding: CartBinding(),
    ),

    GetPage(
      name: AppRoutes.seedList,
      page: () => SeedListScreen(),
      binding: SeedListBinding(),
    ),
    GetPage(
      name: AppRoutes.toolList,
      page: () => ToolListScreen(),
      binding: ToolListBinding(),
    ),
    GetPage(
      name: AppRoutes.protectionProductList,
      page: () => ProtectionProductListScreen(),
      binding: ProtectionProductListBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      // (Dòng này của bạn đã chính xác)
      page: () => ProductDetailScreen(product: Get.arguments as Product),
    ),
    GetPage(
      name: AppRoutes.organicProductList,
      page: () => OrganicProductListScreen(),
      binding: OrganicProductListBinding(),
    ),
    GetPage(
      name: AppRoutes.chatBox,
      page: () => ChatBoxScreen(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => CheckOutScreen(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.orderConfirmation,
      // (Dòng này của bạn đã chính xác)
      page: () => OrderConfirmationScreen(),
    ),
    GetPage(
      name: AppRoutes.weatherHome,
      page: () => WeatherHomeScreen(),
      binding: WeatherHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chatBoxHistory,
      page: () => ChatHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.chatTopic,
      page: () => const ChatTopicScreen(),
    ),

    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryScreen(),
      binding: OrderHistoryBinding(), // Binding để tạo controller
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailScreen(),
      // (Không cần binding vì nó nhận 'Order' qua arguments)
    ),
  ];
}