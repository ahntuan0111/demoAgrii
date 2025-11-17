import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agri_flutter/controllers/order_history_controller.dart';
import 'package:agri_flutter/models/order_model.dart';
import 'package:agri_flutter/routes/app_routes.dart';

class OrderHistoryScreen extends GetView<OrderHistoryController> {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormatter = DateFormat('dd/MM/yyyy');

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
        title: const Text('Đơn hàng của tôi',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        // (Body Obx giữ nguyên)
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        }
        if (controller.orderList.isEmpty) {
          return const Center(
              child: Text("Bạn chưa có đơn hàng nào.",
                  style: TextStyle(fontSize: 16, color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.orderList.length,
          itemBuilder: (context, index) {
            final order = controller.orderList[index];
            return _buildOrderItem(order, currencyFormatter, dateFormatter);
          },
        );
      }),
    );
  }

  // --- ✅ WIDGET NÀY ĐÃ ĐƯỢC CẬP NHẬT HOÀN TOÀN ---
  Widget _buildOrderItem(
      Order order, NumberFormat formatter, DateFormat dFormatter) {

    // Logic lấy tên và số lượng
    final firstItemName = order.orderItems.isNotEmpty
        ? order.orderItems[0].name
        : "Không có sản phẩm";
    final totalItems =
    order.orderItems.fold<int>(0, (sum, item) => sum + item.quantity);

    // --- Cập nhật logic trạng thái ---
    final String statusText;
    final Color statusColor;
    switch (order.status) {
      case 'completed':
        statusText = "Đã hoàn tất";
        statusColor = Colors.green;
        break;
      case 'delivered':
        statusText = "Đã giao hàng";
        statusColor = Colors.blue.shade700;
        break;
      case 'cancelled':
        statusText = "Đã hủy";
        statusColor = Colors.red;
        break;
      default: // pending_..., preparing, out_for_delivery
        statusText = "Đang xử lý";
        statusColor = Colors.orange.shade700;
    }
    // --- Kết thúc cập nhật ---

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(AppRoutes.orderDetail, arguments: order);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (Phần trên giữ nguyên)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mã ĐH: ${order.id.substring(0, 8)}...',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(dFormatter.format(order.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Divider(height: 20),
              Text(
                '$firstItemName${order.orderItems.length > 1 ? ' và ${order.orderItems.length - 1} sản phẩm khác...' : ''}',
                style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text('Số lượng: $totalItems',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatter.format(order.totalPrice),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  Text(statusText, // <-- Dùng statusText mới
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: statusColor)), // <-- Dùng statusColor mới
                ],
              ),

              // --- Cập nhật logic hiển thị và onPressed ---
              // Chỉ hiển thị nút khi trạng thái là 'delivered'
              if (order.status == 'delivered') ...[
                const Divider(height: 24, thickness: 1),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Gọi controller
                      controller.confirmOrderReceived(order.id);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green.shade700),
                      foregroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Đã nhận được hàng'),
                  ),
                ),
              ]
              // --- Kết thúc cập nhật ---
            ],
          ),
        ),
      ),
    );
  }
}