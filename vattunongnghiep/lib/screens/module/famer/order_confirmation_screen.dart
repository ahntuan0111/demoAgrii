// screens/order_confirmation_screen.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/cart_item_model.dart';
import '../../../routes/app_routes.dart';

// 1. CHUYỂN SANG STATELESSWIDGET
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  // (Không cần initState)

  @override
  Widget build(BuildContext context) {

    // 2. TRÍCH XUẤT DỮ LIỆU TỪ ARGUMENTS TRONG HÀM BUILD
    final Map<String, dynamic> orderData = Get.arguments as Map<String, dynamic>;

    // 3. ĐỌC TỪ CÁC KEY ĐÃ SỬA
    final String deliveryTime = orderData['deliveryTime'] as String;
    final String deliveryAddress = orderData['deliveryAddress'] as String;
    final List<CartItem> cartItems = orderData['cartItems'] as List<CartItem>;
    final double total = orderData['total'] as double;
    final double auxiliaryFee = orderData['auxiliaryFee'] as double;

    final currencyFormatter =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.offAllNamed(AppRoutes.bottomNavigation), // Quay về trang chủ
        ),
        title: const Text('Xác nhận đơn hàng',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.eco, color: Colors.green[700]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Phần cảm ơn ---
            const Text('Cảm ơn bạn đã đặt hàng!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Đơn hàng của bạn đã được đặt và đang được xử lý. Bạn sẽ nhận được thông báo khi đơn hàng được giao.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 22),

            // --- Ảnh minh họa ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/order_confirmed_bg.png', // Thêm ảnh này vào assets
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // --- Chi tiết giao hàng ---
            const Text('Chi tiết giao hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDetailRow('Thời gian nhận hàng', deliveryTime,
                subtext: 'Standard Shipping'),
            const Divider(height: 24),
            _buildDetailRow('Địa chỉ nhận hàng', deliveryAddress),
            const SizedBox(height: 24),

            // --- Tóm tắt đơn hàng ---
            const Text('Tóm tắt đơn hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...cartItems.map((item) => _buildOrderItem(
              name: item.name,
              quantity: item.quantity,
              price: item.price * item.quantity,
              formatter: currencyFormatter,
            )),
            const Divider(height: 16),
            _buildTotalRow('Phụ phí (VAT)', auxiliaryFee, currencyFormatter),
            const SizedBox(height: 8),
            _buildTotalRow('Total', total, currencyFormatter, isTotal: true),
            const SizedBox(height: 24),

            // --- Mẹo an toàn ---
            const Text('Mẹo an toàn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Luôn mặc đồ bảo hộ khi tiếp xúc với hóa chất. Bảo quản sản phẩm ở nơi khô ráo, thoáng mát, tránh xa tầm tay trẻ em và vật nuôi. Thực hiện cẩn thận hướng dẫn sử dụng.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  // (Các hàm _build... giữ nguyên, nhưng là hàm private top-level)

  Widget _buildDetailRow(String title, String value, {String? subtext}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        if (subtext != null) ...[
          const SizedBox(height: 4),
          Text(subtext,
              style: TextStyle(color: Colors.green[700], fontSize: 14)),
        ]
      ],
    );
  }

  Widget _buildOrderItem(
      {required String name,
        required int quantity,
        required double price,
        required NumberFormat formatter}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              Text('Quantity: $quantity',
                  style: TextStyle(color: Colors.green[700], fontSize: 14)),
            ],
          ),
          Text(formatter.format(price),
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, NumberFormat formatter,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(
            formatter.format(value),
            style: TextStyle(
                fontSize: isTotal ? 20 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  /* TODO: Navigate to order tracking */
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17CF17),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Theo dõi đơn hàng',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.bottomNavigation),
                child: const Text('Tiếp tục mua sắm',
                    style: TextStyle(fontSize: 16, color: Colors.green)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}