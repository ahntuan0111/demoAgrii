import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agri_flutter/routes/app_pages.dart';
import 'package:agri_flutter/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agrii',
      initialRoute: AppRoutes.locationCheck,
      getPages: AppPages.routes,
      theme: ThemeData(
        // ✅ Toàn bộ app dùng font 
        fontFamily: 'Roboto',

        // ✅ AppBar mặc định
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

        // ✅ Text mặc định cho toàn bộ app
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
