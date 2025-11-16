
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../controllers/bottom_navigation_controller.dart';
import '../../screens/home_screen.dart';
import '../../screens/vtnn_order_list_screen.dart';

class BottomNavigation extends StatelessWidget{
  final BottomNaviController bottomNaviController = Get.put(BottomNaviController());
  BottomNavigation({super.key});

  final List<Widget> screens = [
    VtnnHomeScreen(),
    VtnnOrderListScreen(),
  ];

  final List<String> titles = [
    "Trang chủ",
    "Đơn hàng",
    "Thu tiền",
    "Xuất kho",
    "Kho và Quỷ",
  ];

  final Color primaryGreen = const Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: screens[bottomNaviController.currentIndex.value],

      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              currentIndex: bottomNaviController.currentIndex.value,
              onTap: (index) => bottomNaviController.changeTab(index),
              selectedItemColor: primaryGreen,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
              ),
              iconSize: 28,
              elevation: 0,
              items: [
                _buildAnimatedItem(
                  icon: Icons.home,
                  label: "Trang chủ",
                  isSelected: bottomNaviController.currentIndex.value == 0,
                ),
                _buildAnimatedItem(
                  icon: Icons.event_note_outlined,
                  label: "Đơn hàng",
                  isSelected: bottomNaviController.currentIndex.value == 1,
                ),
                _buildAnimatedItem(
                  icon: Icons.monetization_on_outlined,
                  label: "Thu tiền",
                  isSelected: bottomNaviController.currentIndex.value == 2,
                ),
                _buildAnimatedItem(
                  icon: Icons.warehouse,
                  label: "Xuất kho",
                  isSelected: bottomNaviController.currentIndex.value == 3,
                ),
                _buildAnimatedItem(
                  icon: Icons.archive,
                  label: "Kho và Quỷ",
                  isSelected: bottomNaviController.currentIndex.value == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  BottomNavigationBarItem _buildAnimatedItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(
          top: isSelected ? 0 : 4,
          bottom: isSelected ? 4 : 0,
        ),
        child: Icon(
          icon,
          size: isSelected ? 32 : 26,
        ),
      ),
      label: label,
    );
  }
}