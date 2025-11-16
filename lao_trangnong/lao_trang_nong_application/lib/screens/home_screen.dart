import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart'; // Cần cho Get.toNamed

// Giả sử bạn có file AppRoutes, nếu không, hãy thay thế bằng chuỗi
// import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tất cả các biến này sẽ được cập nhật từ API sau
  String weeklyRevenue = '...';
  String conversionRate = '...';
  String deliveringOrders = '...';
  String codPending = '...';
  String unhandledOrders = '...';
  String codToSubmit = '...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5), // Màu nền xám nhạt
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildNotificationBanners(),
              const SizedBox(height: 16),
              _buildChartSection(),
              const SizedBox(height: 16),
              _buildWarningSection(),
              const SizedBox(height: 16),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* TODO: Logic cho nút + */ },
        backgroundColor: Colors.green.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- 1. APP BAR ---
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.green.shade800, // Màu xanh lá đậm
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tráng nông Dashboard',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Ánh Nguyễn Văn Minh • Long An', // Tên + Khu vực (để trống)
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.lightGreen[400],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, color: Colors.white, size: 8),
              SizedBox(width: 6),
              Text(
                'Online',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. CÁC THẺ TÓM TẮT (4 Ô) ---
  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          title: 'Doanh thu tuần',
          value: weeklyRevenue,
          change: '+...',
          icon: Icons.show_chart,
          changeColor: Colors.green,
          onTap: () { /* TODO */ },
        ),
        _buildStatCard(
          title: 'Tỷ lệ chuyển đổi',
          value: conversionRate,
          change: '+...',
          icon: Icons.pie_chart_outline,
          changeColor: Colors.green,
          onTap: () { /* TODO */ },
        ),
        _buildStatCard(
          title: 'Đang giao',
          value: deliveringOrders,
          change: 'Realtime',
          icon: Icons.local_shipping_outlined,
          changeColor: Colors.blue,
          onTap: () { /* TODO */ },
        ),
        _buildStatCard(
          title: 'COD chưa TT',
          value: codPending,
          change: '24 đơn',
          icon: Icons.access_time,
          changeColor: Colors.red,
          onTap: () { /* TODO */ },
        ),
      ],
    );
  }

  // --- 3. BANNER THÔNG BÁO (2 Ô) ---
  Widget _buildNotificationBanners() {
    return Column(
      children: [
        _buildBanner(
          icon: Icons.info_outline,
          iconColor: Colors.blue[700],
          text: 'Bạn có ${unhandledOrders} đơn cần xử lý',
          actionText: 'Xem ngay →',
          onTap: () { /* TODO */ },
        ),
        const SizedBox(height: 12),
        _buildBanner(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: Colors.orange[700],
          text: 'COD chờ nộp: ${codToSubmit}',
          actionText: 'Nộp tiền →',
          onTap: () { /* TODO */ },
        ),
      ],
    );
  }

  // --- 4. BIỂU ĐỒ DOANH SỐ ---
  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Doanh số vật tư tuần',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () { /* TODO */ },
                child: const Text('Chi tiết →',
                    style: TextStyle(color: Colors.blue, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // TODO: Thay thế bằng widget BarChart
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Biểu đồ Bar Chart ở đây',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. CẢNH BÁO KHẨN ---
  Widget _buildWarningSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Cảnh báo khẩn',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              InkWell(
                onTap: () { /* TODO */ },
                child: const Text('Chi tiết →',
                    style: TextStyle(color: Colors.blue, fontSize: 13)),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildWarningItem(
              'Sắp hết hạn', 'Phân bón NPK - Lô L2025-045 - 2 ngày', '80 bao'),
          const Divider(height: 24),
          _buildWarningItem('Đơn trễ', 'Quá thời gian giao dự kiến', '12 đơn'),
        ],
      ),
    );
  }

  // --- 6. CÁC NÚT TÁC VỤ NHANH ---
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thao tác nhanh',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildActionCard(
                icon: Icons.flash_on, label: 'Bán nhanh', onTap: () { /* TODO */ }),
            _buildActionCard(
                icon: Icons.grass_outlined,
                label: 'Nhà nông',
                onTap: () {
                  // Giả sử bạn có route này
                  // Get.toNamed(AppRoutes.nearestCustomers);
                }),
            _buildActionCard(
                icon: Icons.inventory_2_outlined,
                label: 'Kho',
                onTap: () { /* TODO */ }),
            _buildActionCard(
                icon: Icons.receipt_long_outlined,
                label: 'Đơn hàng',
                onTap: () {
                  Get.toNamed(AppRoutes.orderReception);
                }),
            _buildActionCard(
                icon: Icons.local_florist_outlined,
                label: 'Vườn mẫu',
                onTap: () { /* TODO */ }),
            _buildActionCard(
                icon: Icons.person_outline,
                label: 'Tài khoản',
                onTap: () {
                  // Get.toNamed(AppRoutes.account);
                }),
          ],
        ),
      ],
    );
  }

  // --- CÁC WIDGET CON (HELPER) ---

  // Thẻ tóm tắt
  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color changeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style:
                    const TextStyle(fontSize: 13, color: Colors.black54)),
                Icon(icon, size: 16, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Row(
              children: [
                Icon(
                  change.startsWith('+')
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14,
                  color: changeColor,
                ),
                const SizedBox(width: 4),
                Text(change,
                    style: TextStyle(
                        fontSize: 12,
                        color: changeColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Banner
  Widget _buildBanner({
    required IconData icon,
    required Color? iconColor,
    required String text,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 8),
            Text(actionText,
                style: const TextStyle(color: Colors.blue, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // Item cảnh báo
  Widget _buildWarningItem(String title, String subtitle, String tag) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red[100]!),
          ),
          child: Text(tag,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Thẻ tác vụ nhanh
  Widget _buildActionCard(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}