import 'package:agri_flutter/screens/module/famer/chat_history_screen.dart';
import 'package:agri_flutter/screens/module/famer/home_famer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/bottom_navigation_controller.dart';
import '../../screens/module/famer/account_screen.dart';
import '../../screens/module/famer/chatbox_screen.dart';
import '../../screens/module/famer/shopping_cart_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget{
  final BottomNaviController bottomNaviController = Get.put(BottomNaviController());
  BottomNavigation({super.key});

  final List<Widget> screens = [
    HomeFamerScreen(),
    ShoppingCartScreen(),
    ChatHistoryScreen(),
    AccountScreen(),
  ];

  final List<String> titles = [
    "Trang chủ",
    "Giỏ Hàng",
    "Chat box AI",
    "Tài khoản",
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
                  label: "Home",
                  isSelected: bottomNaviController.currentIndex.value == 0,
                ),
                _buildAnimatedItem(
                  icon: Icons.shopping_cart,
                  label: "Giỏ hàng",
                  isSelected: bottomNaviController.currentIndex.value == 1,
                ),
                _buildAnimatedItem(
                  icon: Icons.message_outlined,
                  label: "Chatbox",
                  isSelected: bottomNaviController.currentIndex.value == 2,
                ),
                _buildAnimatedItem(
                  icon: Icons.person,
                  label: "Tài khoản",
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