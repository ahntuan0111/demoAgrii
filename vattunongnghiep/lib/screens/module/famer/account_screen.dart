import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart'; // Assuming you use GetX for navigation

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // State variable for the notification switch
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(), // Or Navigator.pop(context)
        ),
        title: const Text('Tài khoản', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.eco, color: Colors.green[700]),
          ),  
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Vai trò & Quyền lợi ---
            _buildSectionHeader('Vai trò & Quyền lợi'),
            _buildInfoRow(Icons.person_outline, 'Người dùng: Nông dân'),
            const SizedBox(height: 24),

            // --- Hồ sơ Nông dân số ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Hồ sơ Nông dân số'),
                TextButton(
                  onPressed: () { /* TODO: Implement Edit Profile Action */ },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Chỉnh sửa', style: TextStyle(color: Colors.black54)),
                )
              ],
            ),
            _buildProfileDetailRow(Icons.eco_outlined, 'Cây trồng chính', 'Lúa'),
            _buildProfileDetailRow(Icons.map_outlined, 'Số mảnh vư...', '3'), // Truncated text
            _buildProfileDetailRow(Icons.card_giftcard_outlined, 'Mã giới thiệu', 'ABC1234'),
            const SizedBox(height: 24),

            // --- Lịch sử đặt hàng ---
            _buildSectionHeader('Lịch sử đặt hàng'),
            // THAY THẾ các mục _buildOrderHistoryItem CŨ bằng ListTile MỚI
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_outlined, color: Colors.black54),
              title: const Text('Đơn hàng của tôi'),
              subtitle: const Text('Xem tất cả đơn hàng đã đặt', style: TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                // 3. ĐIỀU HƯỚNG ĐẾN ROUTE MỚI
                Get.toNamed(AppRoutes.orderHistory);
              },
            ),

            // --- Chỉnh sửa thông tin cá nhân ---
            _buildSectionHeader('Chỉnh sửa thông tin cá nhân'),
            ListTile(
              leading: const Icon(Icons.person_pin_outlined, color: Colors.black54),
              title: const Text('Chỉnh sửa hồ sơ'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () { /* TODO: Navigate to Edit Personal Info Screen */ },
            ),
            const SizedBox(height: 24),

            // --- Thông báo ---
            _buildSectionHeader('Thông báo'),
            ListTile(
              leading: const Icon(Icons.notifications_none_outlined, color: Colors.black54),
              title: const Text('Bật thông báo'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // TODO: Save notification preference
                },
                activeColor: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            // --- Chính sách & Thông tin liên hệ ---
            _buildSectionHeader('Chính sách & Thông tin liên hệ'),
            _buildPolicyLink(Icons.description_outlined, 'Điều khoản dịch vụ'),
            _buildPolicyLink(Icons.shield_outlined, 'Chính sách bảo mật'),
            _buildPolicyLink(Icons.help_outline, 'Liên hệ hỗ trợ'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // You might want to add your BottomNavigationBar here if needed
      // bottomNavigationBar: BottomNavigationBar(...),
    );
  }

  // Helper Widgets
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0), // Added top padding
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryItem(IconData icon, String status, String orderId) {
    return ListTile(
      dense: true, // Make list tile items more compact
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black54),
      title: Text(status),
      subtitle: Text('Order $orderId', style: const TextStyle(color: Colors.grey)),
      onTap: () { /* TODO: Navigate to specific order details */ },
    );
  }

  Widget _buildPolicyLink(IconData icon, String title) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      onTap: () { /* TODO: Navigate to policy/contact screen */ },
    );
  }
}