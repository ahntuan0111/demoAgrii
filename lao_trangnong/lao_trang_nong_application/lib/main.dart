import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/auth_service.dart';
import 'services/order_service.dart';
import 'services/storage_service.dart';
import 'services/user_service.dart';
import 'controllers/order_reception_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo GetStorage
  await GetStorage.init();

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Đăng ký các service (Giữ nguyên)
  Get.put(AuthService(), permanent: true);
  Get.put(UserService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(OrderService(), permanent: true);

  // Lưu ý: Controller thường không nên put ở main nếu không dùng xuyên suốt app,
  // nhưng nếu app của bạn cần nó sống mãi thì giữ lại.
  Get.put(OrderReceptionController(), permanent: true);

  // --- ✅ XỬ LÝ LOGIC ĐIỀU HƯỚNG BAN ĐẦU ---
  final storage = GetStorage();
  String initialRoute;

  final bool hasSeenWelcome = storage.read('hasSeenWelcome') ?? false;

  if (!hasSeenWelcome) {
    initialRoute = AppRoutes.onboarding;
    await storage.write('hasSeenWelcome', true);
  } else {
    final token = storage.read('apiToken');
    if (token != null) {
      initialRoute = AppRoutes.homePage; // (Hoặc homeVtnn)
    } else {
      initialRoute = AppRoutes.welcome;
    }
  }
  // ------------------------------------

  // Truyền initialRoute vào MyApp
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  // Thêm biến để nhận route từ main
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agri App',

      // --- ✅ DÙNG ROUTE ĐÃ TÍNH TOÁN ---
      initialRoute: initialRoute,
      // -------------------------------

      getPages: AppPages.routes,
      theme: ThemeData(
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
          labelLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}