import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Cần cho SystemUiOverlayStyle
import 'package:get/get.dart';

import '../routes/app_routes.dart'; // Cần cho Get.toNamed

// Giả sử bạn có file AppRoutes, nếu không, hãy thay thế bằng chuỗi
// import '../routes/app_routes.dart';

class VtnnHomeScreen extends StatefulWidget {
  const VtnnHomeScreen({super.key});

  @override
  State<VtnnHomeScreen> createState() => _VtnnHomeScreenState();
}

class _VtnnHomeScreenState extends State<VtnnHomeScreen> {
  // --- DỮ LIỆU GIẢ LẬP (SẼ LẤY TỪ API SAU) ---
  String revenueToday = '0đ';
  String ordersToday = '0';
  String profitToday = '0đ';
  String pendingOrders = '2'; // Cần soạn
  String pendingCash = '3'; // Chờ thu tiền
  String unpaidOrders = '1'; // Tồn thấp / HSD

  String pendingOrderCount = '7 đơn';
  String processingOrderCount = '3 đơn';

  Color? get kAppGrey => Color(0xFFF4F6F5);
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    // (Giả sử AppColors)
    const Color kAppGreen = Color(0xFF1B5E20);
    const Color kAppGrey = Color(0xFFF4F6F5);

    return Scaffold(
      backgroundColor: kAppGrey,
      appBar: _buildAppBar(kAppGreen),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildKpiSection(),
              const SizedBox(height: 24),
              _buildQuickAccessSection(),
              const SizedBox(height: 24),
              _buildOrderManagementSection(),
              const SizedBox(height: 16),
              _buildSupportCard(),
              const SizedBox(height: 16),
              _buildNewsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* TODO: Logic cho nút + */ },
        backgroundColor: kAppGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- 1. APP BAR ---
  AppBar _buildAppBar(Color kAppGreen) {
    return AppBar(
      backgroundColor: kAppGrey,
      elevation: 0,
      // Đặt style cho status bar (đồng hồ, pin)
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black54),
        onPressed: () { /* TODO: Mở Drawer */ },
      ),
      title: const Text(
        'Quản lý VTNN',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: Colors.black54),
          onPressed: () { /* TODO: Mở thông báo */ },
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
          onPressed: () { /* TODO: Mở Chat */ },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // --- 2. SEARCH BAR ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm sản phẩm, đơn khách',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  // --- 3. KPI SECTION ---
  Widget _buildKpiSection() {
    return Column(
      children: [
        _buildSectionHeader(
            'KPI Hôm nay', 'Xem KPI', () { /* TODO: Navigate to KPI screen */ }),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.0, // Làm cho card rộng hơn
          children: [
            _buildKpiCard('Doanh thu', revenueToday, '+...', Icons.monetization_on_outlined, Colors.green),
            _buildKpiCard('Đơn hàng', ordersToday, '+...', Icons.receipt_long_outlined, Colors.blue),
            _buildKpiCard('Lợi nhuận', profitToday, '+...', Icons.trending_up, Colors.purple),
            _buildKpiCard('Cần soạn', pendingOrders, '... đơn', Icons.inventory_2_outlined, Colors.orange),
            _buildKpiCard('Chờ thu tiền', pendingCash, '... đơn', Icons.account_balance_wallet_outlined, Colors.teal),
            _buildKpiCard('Tồn thấp / HSD', unpaidOrders, '... thấp - ... HSD', Icons.warning_amber_rounded, Colors.red),
          ],
        )
      ],
    );
  }

  // --- 4. QUICK ACCESS SECTION ---
  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Truy cập nhanh', null, null),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildQuickActionCard('Báo cáo KPI', Icons.bar_chart, () { /* TODO */ }),
            _buildQuickActionCard('Bán tại quầy', Icons.point_of_sale_outlined, () { /* TODO */ }),
            _buildQuickActionCard('Khách hàng', Icons.people_outline, () { /* TODO */ }),
            _buildQuickActionCard(
                'Nhập từ Agrii',
                Icons.warehouse_outlined,
                    () {
                  Get.toNamed(AppRoutes.purchaseOrderList); // <-- SỬA LẠI HÀM NÀY
                }
            ),
          ],
        ),
      ],
    );
  }

  // --- 5. ORDER MANAGEMENT SECTION ---
  Widget _buildOrderManagementSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Quản lý Đơn hàng', 'Xem', () { /* TODO: Navigate to Order List */ }),
          const SizedBox(height: 8),
          _buildOrderSummaryRow(
              'Đơn chờ xác nhận', pendingOrderCount, Colors.orange),
          const Divider(height: 24),
          _buildOrderSummaryRow(
              'Đơn đang xử lý', processingOrderCount, Colors.blue),
        ],
      ),
    );
  }

  // --- 6. SUPPORT CARD ---
  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3FF), // Màu xanh nhạt
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hỗ trợ người dùng', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Bạn cần hỗ trợ? Nhấn Agrii AI nhé!\nĐể dàng quản lý sản phẩm, đơn hàng, khách hàng; cần gì cứ nhờ Agrii hỗ trợ ngay.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () { /* TODO: Chat */ },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Chat ngay'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded), // (ZaloOA icon)
                      onPressed: () { /* TODO: Zalo */ },
                    ),
                    IconButton(
                      icon: const Icon(Icons.facebook_outlined), // (Messenger icon)
                      onPressed: () { /* TODO: Messenger */ },
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Giờ hỗ trợ: 8:00-21:00 • SLA < 15 phút', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          Image.asset('assets/images/logo.png', height: 40), // (Giả sử logo)
        ],
      ),
    );
  }

  // --- 7. NEWS CARD ---
  Widget _buildNewsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.library_books_outlined, color: Colors.green.shade800, size: 16),
                    const SizedBox(width: 8),
                    const Text('Tin tức nông nghiệp', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Cẩm nang sản xuất lúa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const Text('Cập nhật các phương pháp canh tác hiệu quả.', style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/placeholder.png', width: 80, height: 60, fit: BoxFit.cover), // (Ảnh minh họa)
          ),
        ],
      ),
    );
  }

  // --- WIDGETS CON (HELPER) ---

  // Helper: Header chung
  Widget _buildSectionHeader(String title, String? actionText, VoidCallback? onActionPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        if (actionText != null)
          InkWell(
            onTap: onActionPressed,
            child: Text(actionText,
                style: const TextStyle(color: Colors.blue, fontSize: 13)),
          ),
      ],
    );
  }

  // Helper: Thẻ KPI
  Widget _buildKpiCard(String title, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper: Thẻ Tác vụ nhanh
  Widget _buildQuickActionCard(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.green.shade800),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Dòng tóm tắt đơn hàng
  Widget _buildOrderSummaryRow(String label, String count, Color dotColor) {
    return Row(
      children: [
        Icon(Icons.circle, color: dotColor, size: 10),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 15)),
        const Spacer(),
        Text(count,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}