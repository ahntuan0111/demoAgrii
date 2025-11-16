import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lao_trang_nong_application/services/auth_service.dart';
import 'package:lao_trang_nong_application/services/order_service.dart';
import 'package:lao_trang_nong_application/services/storage_service.dart';
import 'package:lao_trang_nong_application/services/user_service.dart';
import 'controllers/order_reception_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo GetStorage
  await GetStorage.init();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Đăng ký các service (sử dụng permanent để giữ sống trong toàn bộ vòng đời app)
  Get.put(AuthService(), permanent: true);
  Get.put(UserService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(OrderService(), permanent: true);


  Get.put(OrderReceptionController(), permanent: true);
  // 👉 Quan trọng: Gọi runApp sau khi khởi tạo xong tất cả
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agri App',
      initialRoute: AppRoutes.homePage, // Route đầu tiên
      getPages: AppPages.routes, // Danh sách route từ GetX
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
