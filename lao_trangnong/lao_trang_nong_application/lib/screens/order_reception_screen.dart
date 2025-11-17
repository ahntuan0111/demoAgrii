import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/order_reception_controller.dart';
import '../models/manager_order_model.dart';

class OrderReceptionScreen extends GetView<OrderReceptionController> {
  const OrderReceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildOnlineToggle(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              }
              return RefreshIndicator(
                onRefresh: controller.fetchOrders,
                color: Colors.green,
                child: (controller.orderList.isEmpty)
                    ? const Center(
                    child: Text("Không có đơn hàng nào.",
                        style: TextStyle(fontSize: 16, color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.orderList.length,
                  itemBuilder: (context, index) {
                    final order = controller.orderList[index];
                    return _buildOrderCard(order, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.green.shade800,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text('Tiếp nhận đơn hàng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }

  Widget _buildOnlineToggle() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isOnline.value
                      ? 'Bạn đang online - Sẵn sàng nhận đơn'
                      : 'Bạn đang offline',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: controller.isOnline.value
                          ? Colors.green.shade700
                          : Colors.grey.shade700),
                ),
                Text(
                  controller.isOnline.value
                      ? 'Đơn được hiển thị theo thời gian mới nhất'
                      : 'Bật để xem các đơn hàng mới',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                )
              ],
            ),
          ),
          Switch(
            value: controller.isOnline.value,
            onChanged: controller.toggleOnlineStatus,
            activeColor: Colors.green,
          )
        ],
      )),
    );
  }

  // --- ✅ HÀM BUILD CARD ĐÃ ĐƯỢC SỬA LOGIC ---
  Widget _buildOrderCard(ManagerOrder order, OrderReceptionController controller) {

    // 1. Xác định trạng thái nút bấm (Resume flow logic)
    String buttonText = 'Xem chi tiết';
    Color buttonColor = Colors.grey;
    bool isButtonEnabled = true;

    switch (order.status) {
      case 'ready_for_pickup':
        buttonText = 'Nhận đơn';
        buttonColor = Colors.green.shade700;
        break;
      case 'awaiting_payment':
        buttonText = 'Tiếp tục lấy hàng'; // Trạng thái đang đi lấy
        buttonColor = Colors.orange.shade700;
        break;
      case 'out_for_delivery':
        buttonText = 'Tiếp tục giao hàng'; // Trạng thái đang đi giao
        buttonColor = Colors.blue.shade700;
        break;
      case 'delivered':
      case 'completed':
        buttonText = 'Đã giao thành công';
        buttonColor = Colors.grey;
        isButtonEnabled = false; // Đơn đã xong, không bấm được nữa
        break;
      default:
        buttonText = 'Trạng thái: ${order.status}';
        isButtonEnabled = false;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng 1: ID và Khoảng cách
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DH-${order.id.substring(0, 8)}...',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                // Sửa lỗi null distance
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.distanceFormatter.format(order.distance ?? 0.0)} km',
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => controller.viewDetail(order),
              child: const Text('Chạm để xem chi tiết',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const Divider(height: 24),

            // Các dòng thông tin
            _buildInfoRow(Icons.location_on_outlined, 'Giao hàng', order.shippingAddress),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.receipt_long_outlined, 'Tiền hàng',
                controller.currencyFormatter.format(order.totalPrice)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.attach_money_outlined, 'COD',
                controller.currencyFormatter.format(order.amountPayableToStore),
                valueColor: Colors.orange.shade700),
            const SizedBox(height: 20),

            // Dòng Nút bấm
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.viewDetail(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Chi tiết'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    // Gọi hàm điều hướng thông minh
                    onPressed: isButtonEnabled
                        ? () => controller.handleOrderAction(order)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                        buttonText,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isButtonEnabled ? Colors.white : Colors.black54
                        )
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// --- POPUP DIALOG ---
class AcceptOrderDialog extends StatelessWidget {
  final ManagerOrder order;
  final OrderReceptionController controller = Get.find<OrderReceptionController>();

  AcceptOrderDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Chi tiết đơn hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Mã đơn: DH-${order.id.substring(0, 8)}...',
                style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),

            // Danh sách hàng
            const Text('Danh sách hàng', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Column(
                  children: order.orderItems.map((item) =>
                      _buildItemRow(item.name, item.variantName, item.quantity)
                  ).toList(),
                ),
              ),
            ),
            const Divider(height: 24),

            // Chi tiết tiền & Khoảng cách (Đã sửa lỗi null)
            _buildPriceRow('Khoảng cách',
                '${controller.distanceFormatter.format(order.distance ?? 0.0)} km'),
            _buildPriceRow('Thu COD (Nông dân)',
                controller.currencyFormatter.format(order.totalPrice)),
            _buildPriceRow('Trả cho VTNN',
                controller.currencyFormatter.format(order.amountPayableToStore),
                isCod: true),
            const SizedBox(height: 24),

            // Nút bấm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.acceptOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Nhận đơn',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Bỏ qua'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.callCustomer(order.customerPhone),
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: const Text('Gọi khách'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String name, String variant, int quantity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$quantity x $name ($variant)'),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isCod = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCod ? Colors.orange.shade700 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}