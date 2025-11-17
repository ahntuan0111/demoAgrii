import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agri_flutter/models/order_model.dart';
import 'package:agri_flutter/models/cart_item_model.dart';
// --- ✅ THÊM IMPORT CONTROLLER ---
import 'package:agri_flutter/controllers/order_history_controller.dart';

// --- ✅ CHUYỂN SANG GETVIEW ĐỂ TRUY CẬP CONTROLLER ---
class OrderDetailScreen extends GetView<OrderHistoryController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy dữ liệu Order từ arguments
    final Order order = Get.arguments as Order;

    final currencyFormatter =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormatter = DateFormat('HH:mm - dd/MM/yyyy');

    // --- ✅ LẤY LOGIC TRẠNG THÁI ---
    final String statusText;
    switch (order.status) {
      case 'completed':
        statusText = "Đã hoàn tất";
        break;
      case 'delivered':
        statusText = "Đã giao hàng";
        break;
      case 'cancelled':
        statusText = "Đã hủy";
        break;
      default:
        statusText = "Đang xử lý";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // (AppBar giữ nguyên)
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text('Chi tiết đơn hàng',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Thông tin chung ---
            _buildSectionHeader('Thông tin đơn hàng'),
            _buildDetailRow('Mã đơn hàng:', order.id),
            _buildDetailRow('Ngày đặt:', dateFormatter.format(order.createdAt)),
            _buildDetailRow('Trạng thái:', statusText), // <-- Dùng statusText mới
            const Divider(height: 24),

            // (Các phần còn lại giữ nguyên)
            _buildSectionHeader('Địa chỉ giao hàng'),
            Text(order.shippingAddress, style: const TextStyle(fontSize: 15)),
            const Divider(height: 24),

            _buildSectionHeader('Danh sách sản phẩm'),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: order.orderItems.length,
              itemBuilder: (context, index) {
                final item = order.orderItems[index];
                return _buildOrderItemTile(item, currencyFormatter);
              },
            ),
            const Divider(height: 24),

            _buildSectionHeader('Tổng kết hóa đơn'),
            _buildTotalRow(
                'Tổng tiền hàng:', currencyFormatter.format(order.subtotal)),
            _buildTotalRow(
                'Phí vận chuyển:', currencyFormatter.format(order.shippingFee)),
            _buildTotalRow('VAT (8%):', currencyFormatter.format(order.vatFee)),
            const Divider(thickness: 1, height: 20),
            _buildTotalRow(
                'Tổng cộng:', currencyFormatter.format(order.totalPrice),
                isTotal: true),
            _buildTotalRow(
                'Thanh toán:',
                order.paymentMethod == 'cod'
                    ? 'Thanh toán khi nhận hàng'
                    : 'Đã thanh toán online',
                isPayment: true),

            // --- ✅ THÊM NÚT BẤM VÀO CUỐI ---
            if (order.status == 'delivered') ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Gọi controller (đã được GetView tìm thấy)
                    controller.confirmOrderReceived(order.id);
                    // (Tùy chọn: Đóng màn hình chi tiết sau khi nhấn)
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Đã nhận được hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // (Các hàm _build... bên dưới giữ nguyên)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Text(value,
              style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
  Widget _buildOrderItemTile(CartItem item, NumberFormat formatter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 30)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                Text(item.variantName,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('x${item.quantity}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(formatter.format(item.price * item.quantity),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildTotalRow(String label, String value,
      {bool isTotal = false, bool isPayment = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isPayment ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}