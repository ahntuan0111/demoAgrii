// screens/home_famer_screen.dart (ĐÃ SỬA LỖI OVERFLOW)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart'; // Make sure this path is correct

class HomeFamerScreen extends StatefulWidget {
  const HomeFamerScreen({super.key});

  @override
  State<HomeFamerScreen> createState() => _HomeFamerScreenState();
}

class _HomeFamerScreenState extends State<HomeFamerScreen> {
  late TextEditingController _aiQuestionController;
  @override
  void initState() {
    super.initState();
    _aiQuestionController = TextEditingController();
  }

  @override
  void dispose() {
    _aiQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF7),
      body: SafeArea(
        // --- ✅ SỬA LỖI: BỌC BẰNG SingleChildScrollView ---
        child: SingleChildScrollView(
          child: Column(
            // --- ✅ SỬA LỖI: CĂN LỀ TRÁI ---
            crossAxisAlignment: CrossAxisAlignment.start,
            // -----------------------------
            children: [
              // Header
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D994D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.eco, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sản phẩm ở Green Valley Supplies',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF0E1B0E),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green[200],
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.search, color: Color(0xFF4D994D)),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tìm kiếm sản phẩm',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // AI NHÀ NÔNG Section
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F0), // Màu nền hơi xanh xám
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TIÊU ĐỀ
                      const Text(
                        'AI NHÀ NÔNG',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20), // Reduced space
                      // KHUNG NHẬP LIỆU
                      Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding:
                          const EdgeInsets.only(left: 16.0, right: 8.0),
                          child: TextField(
                            controller: _aiQuestionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                              'Bà con đang cần hỗ trợ về vấn đề gì ?',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon:
                                Icon(Icons.send, color: Colors.grey[400]),
                                onPressed: () {
                                  String question = _aiQuestionController.text;
                                  if (question.isNotEmpty) {
                                    Get.toNamed(AppRoutes.chatBox,
                                        arguments: question);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // CÁC NÚT GỢI Ý
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center, // Center chips horizontally
                        children: [
                          _buildSuggestionChip('Sâu bệnh'),
                          _buildSuggestionChip('Dinh dưỡng'),
                          _buildSuggestionChip('Thuốc/Phân phù hợp'),
                          _buildSuggestionChip('Kỹ thuật canh tác'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // LIÊN KẾT GỌI TỔNG ĐÀI
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Gọi chuyên gia / Tổng đài',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Banner Image
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/header_image.png',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.green[100],
                    ),
                  ),
                ),
              ),
              // Recommendation Section
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/recommendation_image.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
                          color: Colors.green[100],
                        ),
                      ),
                    ),
                    title: const Text(
                      'Khuyến nghị theo cây trồng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: const Text('Dành cho cây lúa'),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.green[700]),
                  ),
                ),
              ),
              // Categories Title (Aligned Left)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Các loại',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
              ),
              // Categories List
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16, left: 16),
                child: SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryIconItem(
                        iconAsset: 'assets/icons/category_seed_icon.png',
                        label: 'Hạt giống',
                        onTap: () => Get.toNamed(AppRoutes.seedList),
                      ),
                      _CategoryIconItem(
                        iconAsset: 'assets/icons/category_tool_icon.png',
                        label: 'Dụng cụ',
                        onTap: () => Get.toNamed(AppRoutes.toolList),
                      ),
                      _CategoryIconItem(
                        iconAsset: 'assets/icons/category_protect_icon.png',
                        label: 'Sản phẩm\nbảo vệ',
                        onTap: () =>
                            Get.toNamed(AppRoutes.protectionProductList),
                      ),
                      _CategoryIconItem(
                        iconAsset: 'assets/icons/category_organic_icon.png',
                        label: 'Sản phẩm\nhữu cơ',
                        onTap: () => Get.toNamed(AppRoutes.organicProductList),
                      ),
                      _CategoryIconItem(
                        iconAsset: 'assets/icons/category_livestock_icon.png',
                        label: 'Chăn nuôi',
                        onTap: () {
                          Get.snackbar(
                              'Thông báo', 'Chức năng đang phát triển');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Promotions Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    children: const [
                      _PromoCard(
                        image: 'assets/images/promo_special.png',
                        title: 'Khuyến mãi đặc biệt',
                        subtitle: 'Giảm giá sốc',
                      ),
                      _PromoCard(
                        image: 'assets/images/promo_delivery.png',
                        title: 'Giao hàng nhanh chóng',
                        subtitle: 'Nhận hàng trong ngày',
                      ),
                      _PromoCard(
                        image: 'assets/images/promo_safety.png',
                        title: 'Sử dụng an toàn',
                        subtitle: 'Hướng dẫn chi tiết',
                      ),
                    ],
                  ),
                ),
              ),
              // Weather Section
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/weather_bg.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
                          color: Colors.green[100],
                        ),
                      ),
                    ),
                    title: const Text('Thời tiết & Mùa vụ'),
                    subtitle: const Text(
                        'Phú Tân, Châu Đốc | mưa 20% | gió 15 km/h | nhiệt 30°C'),
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('Xem chi tiết'),
                    ),
                  ),
                ),
              ),
              // Best Sellers Title (Aligned Left)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Bán chạy nhất',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
              ),
              // Best Sellers List
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0), // Adjust padding
                child: SizedBox(
                  height: 190, // Increased height slightly for wrapped text
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _BestSellerCard(
                        image: 'assets/images/best_seller_1.png',
                        title: 'Phân bón',
                        price: '₫150,000',
                      ),
                      _BestSellerCard(
                        image: 'assets/images/best_seller_2.png',
                        title: 'Thuốc trừ sâu',
                        price: '₫200,000',
                      ),
                      _BestSellerCard(
                        image: 'assets/images/best_seller_3.png',
                        title: 'Bình Phun Xịt Điện Mitsukaisho 20L 20D',
                        price: '₫850.000',
                      ),
                      _BestSellerCard(
                        image: 'assets/images/best_seller_4.png',
                        title: 'Gói hạt giống',
                        price: '₫75,000',
                      ),
                    ],
                  ),
                ),
              ),

              // Sustainable Farming Card
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FCF7), // Màu nền nhạt
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tìm hiểu thêm về nông nghiệp bền vững',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF0E1B0E),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Đọc ngay',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4D994D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/sustainable_farming.png',
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 80,
                                height: 60,
                                color: Colors.green[100],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Spacer at the bottom
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Suggestion Chip builder function
  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
      ),
      onPressed: () {
        Get.toNamed(AppRoutes.chatBox, arguments: label); // Corrected route name
      },
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    );
  }
} // End of _HomeFamerScreenState class

// Promo Card Widget
class _PromoCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _PromoCard({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.green[100],
                child: const Icon(Icons.image_outlined, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF0E1B0E),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4D994D),
            ),
          ),
        ],
      ),
    );
  }
}

// Category Icon Item Widget
class _CategoryIconItem extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  const _CategoryIconItem({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.category, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0E1B0E),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Best Seller Card Widget
class _BestSellerCard extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  const _BestSellerCard(
      {required this.image, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Reduced width slightly
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Larger radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Softer shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), // Match container radius
            child: Image.asset(
              image,
              width: double.infinity, // Image takes full width
              height: 100, // Fixed height for image consistency
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 100,
                color: Colors.green[100],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0), // Padding for text content
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14 // Slightly smaller font
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Allow title to wrap
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}