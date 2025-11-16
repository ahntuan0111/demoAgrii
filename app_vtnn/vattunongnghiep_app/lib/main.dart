import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// --- ✅ 1. SỬA IMPORT TẠI ĐÂY ---
// (Sửa từ '..._data_file.dart' thành '..._data_local.dart')
import 'package:intl/date_symbol_data_local.dart';
// ---------------------------------

import 'package:vattunongnghiep_app/services/auth_service.dart';
import 'package:vattunongnghiep_app/services/product_service.dart';
import 'package:vattunongnghiep_app/services/purchase_order_service.dart';
import 'package:vattunongnghiep_app/services/storage_service.dart';
import 'package:vattunongnghiep_app/services/user_service.dart';
import 'package:vattunongnghiep_app/services/vtnn_order_service.dart';
import 'controllers/vtnn_order_list_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo GetStorage
  await GetStorage.init();

  // --- ✅ 2. SỬA HÀM GỌI TẠI ĐÂY ---
  // (Tham số thứ 2 là 'null', điều này là ĐÚNG với '..._data_local.dart')
  await initializeDateFormatting('vi_VN', null);
  // -------------------------------

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Đăng ký các service
  Get.put(AuthService(), permanent: true);
  Get.put(UserService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(PurchaseOrderService(), permanent: true);
  Get.put(VtnnOrderService(), permanent: true);
  Get.put(VtnnOrderListController(), permanent: true);
  Get.put(ProductService(), permanent: true);


  // (Nếu App VTNN cần 'CartController' hoặc 'OrderReceptionController',
  //  bạn cũng cần Get.put() chúng ở đây)

  // --- ✅ 3. THÊM LẠI LOGIC INITIAL ROUTE ---
  final storage = GetStorage();
  String initialRoute;

  final bool hasSeenWelcome = storage.read('hasSeenWelcome') ?? false;

  if (!hasSeenWelcome) {
    initialRoute = AppRoutes.welcome;
    await storage.write('hasSeenWelcome', true);
  } else {
    final token = storage.read('apiToken');
    if (token != null) {
      initialRoute = AppRoutes.bottomNavigation; // (Hoặc homeVtnn)
    } else {
      initialRoute = AppRoutes.login;
    }
  }
  // ------------------------------------

  runApp(MyApp(initialRoute: initialRoute)); // <-- 4. SỬA LẠI ĐÂY
}

class MyApp extends StatelessWidget {
  // --- ✅ 5. THÊM CONSTRUCTOR ĐỂ NHẬN ROUTE ---
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});
  // ---------------------------------------

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agrii VTNN', // (Sửa tên App)

      // --- ✅ 6. SỬ DỤNG BIẾN INITIAL ROUTE ---
      initialRoute: initialRoute,
      // -----------------------------------

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