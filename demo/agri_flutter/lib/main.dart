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
    );
  }
}
