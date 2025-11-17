import 'package:agri_flutter/services/auth_service.dart';
import 'package:agri_flutter/services/cart_service.dart';
import 'package:agri_flutter/services/order_service.dart';
import 'package:agri_flutter/services/product_service.dart';
import 'package:agri_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agri_flutter/routes/app_pages.dart';
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/cart_controller.dart';
import 'firebase_options.dart';

// --- (THÊM MỚI) ---
// Import 'kIsWeb' để kiểm tra xem có phải đang chạy trên Web không
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  // Đảm bảo Flutter đã khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo GetStorage
  await GetStorage.init();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Put services (Giữ nguyên)
  Get.put(AuthService(), permanent: true);
  Get.put(ProductService(), permanent: true);
  Get.put(OrderService(), permanent: true);
  Get.put(CartService(), permanent: true);
  Get.put(UserService(), permanent: true);

  Get.put(CartController(), permanent: true);

  // --- LOGIC ĐIỀU HƯỚNG MỚI ---
  // (Giữ nguyên logic của bạn, nó đã rất tốt)
  // -----------------------------
  final storage = GetStorage();
  String initialRoute;

  // 1. Kiểm tra xem người dùng đã từng xem màn hình Welcome chưa
  // (mặc định là 'false' - tức là chưa xem)
  final bool hasSeenWelcome = storage.read('hasSeenWelcome') ?? false;

  if (!hasSeenWelcome) {
    // 1.1. Lần đầu tiên mở app -> Đi đến Welcome
    initialRoute = AppRoutes.welcome;
    // Đánh dấu là đã xem, để lần sau không vào nữa
    await storage.write('hasSeenWelcome', true);
  } else {
    // 1.2. Không phải lần đầu -> Kiểm tra trạng thái đăng nhập

    // (Logic này của bạn dùng 'apiToken' để kiểm tra, rất chính xác)
    final token = storage.read('apiToken');

    if (token != null) {
      // 2. Đã đăng nhập -> Vào thẳng màn hình chính
      initialRoute = AppRoutes.bottomNavigation;
    } else {
      // 3. Chưa đăng nhập -> Vào màn hình đăng nhập
      // (Chúng ta không vào 'welcome' nữa, mà vào 'login')
      initialRoute = AppRoutes.login;
    }
  }
  // -----------------------------
  // --- KẾT THÚC LOGIC MỚI ---

  // 3. Truyền 'initialRoute' đã xác định vào MyApp
  runApp(MyApp(initialRoute: initialRoute)); // <-- Giữ nguyên
}

class MyApp extends StatelessWidget {
  // 4. Nhận route khởi tạo từ hàm main
  final String initialRoute; // <-- Giữ nguyên

  const MyApp({
    super.key,
    required this.initialRoute, // <-- Giữ nguyên
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agrii',
      // 5. Sử dụng route đã được quyết định
      initialRoute: initialRoute, // <-- Giữ nguyên
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

      // --- (BẮT ĐẦU PHẦN CHỈNH SỬA - CÁCH 1) ---
      builder: (context, child) {
        // 1. Kiểm tra nếu là Web
        if (kIsWeb) {
          // 2. Trả về giao diện đã được căn giữa và giới hạn kích thước
          return Scaffold(
            // Màu nền xám bên ngoài khung điện thoại
            backgroundColor: Colors.grey[200],
            body: Center(
              child: Container(
                // Kích thước của khung (ví dụ: iPhone 11 Pro)
                // Bạn có thể thay đổi kích thước này
                width: 375.0,
                height: 812.0,

                // Cắt nội dung tràn viền
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white, // Màu nền của app bên trong
                  // Thêm bóng đổ cho đẹp
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  // Bo góc
                  borderRadius: BorderRadius.circular(24),
                  // Thêm viền mỏng (tùy chọn)
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                ),

                // 'child' chính là toàn bộ GetMaterialApp của bạn
                child: child,
              ),
            ),
          );
        }

        // 3. Nếu là mobile (Android/iOS), trả về bình thường
        return child!;
      },
      // --- (KẾT THÚC PHẦN CHỈNH SỬA) ---
    );
  }
}