import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/vtnn_order_detail_controller.dart';
import '../models/vtnn_order_model.dart';

class VtnnOrderDetailScreen extends GetView<VtnnOrderDetailController> {
  const VtnnOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kAppGreen = Color(0xFF1B5E20);
    const Color kAppBackground = Color(0xFFF4F6F5);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: controller.closeScreen,
          ),
        ],
      ),
      body: Obx(() {
        final order = controller.order.value;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerCard(order),
                    const SizedBox(height: 24),
                    const Text(
                      'Danh sách sản phẩm',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildProductList(order),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(order, kAppGreen),
          ],
        );
      }),
    );
  }

  // --- WIDGETS CON ---

  Widget _buildCustomerCard(VtnnOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khách hàng',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  order.customerPhone,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Badge trạng thái (Sẽ tự cập nhật theo controller)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: controller.getStatusColor(order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.getStatusText(order.status),
              style: TextStyle(
                color: controller.getStatusColor(order.status),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(VtnnOrder order) {
    // (Hàm này giữ nguyên, không thay đổi)
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.orderItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = order.orderItems[index];
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
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.variantName,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đơn giá: ${controller.currencyFormatter.format(item.price)}',
                      style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${item.quantity}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(width: 4),
              const Text(
                'Kg', // (Đơn vị này nên có trong model)
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar(VtnnOrder order, Color kAppGreen) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          // Tổng cộng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                controller.currencyFormatter.format(order.totalPrice),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kAppGreen),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- ✅ CÁC NÚT BẤM ĐỘNG (ĐÃ CẬP NHẬT 1-1) ---
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Dùng 'switch' để hiển thị nút cho từng trạng thái
            switch (order.status) {
            // --- Trạng thái 1 ---
              case 'pending_vtnn_prep':
                return Column(
                  children: [
                    _buildPrimaryButton(
                      text: "Xác nhận xử lý đơn",
                      icon: Icons.play_circle_outline,
                      onPressed: controller.confirmProcessing, // <-- Hàm mới
                      color: kAppGreen,
                    ),
                    const SizedBox(height: 8),
                    _buildSecondaryButton(
                      text: "Báo thiếu hàng",
                      icon: Icons.warning_amber_rounded,
                      onPressed: controller.reportStockIssue,
                    ),
                  ],
                );

            // --- Trạng thái 2 ---
              case 'preparing':
                return Column(
                  children: [
                    _buildPrimaryButton(
                      text: "Xác nhận đã chuẩn bị",
                      icon: Icons.check_circle_outline,
                      onPressed: controller.confirmPreparation, // <-- Hàm cũ
                      color: kAppGreen,
                    ),
                    const SizedBox(height: 8),
                    _buildSecondaryButton(
                      text: "Báo thiếu hàng",
                      icon: Icons.warning_amber_rounded,
                      onPressed: controller.reportStockIssue,
                    ),
                  ],
                );

            // --- Trạng thái 3 ---
              case 'ready_for_pickup':
                return Column(
                  children: [
                    _buildPrimaryButton(
                      text: "Xác nhận Lão Nông đã đến",
                      icon: Icons.person_pin_circle_outlined,
                      onPressed: controller.confirmManagerArrival, // <-- Hàm mới
                      color: kAppGreen,
                    ),
                    const SizedBox(height: 8),
                    _buildSecondaryButton(
                      text: "Báo thiếu hàng",
                      icon: Icons.warning_amber_rounded,
                      onPressed: controller.reportStockIssue,
                    ),
                  ],
                );

            // --- Trạng thái 4 ---
              case 'awaiting_payment':
                return Column(
                  children: [
                    _buildPrimaryButton(
                      text: "Xác nhận thu tiền thành công",
                      icon: Icons.paid_outlined,
                      onPressed: controller.confirmPayment, // <-- Hàm cũ
                      color: kAppGreen,
                    ),
                    const SizedBox(height: 8),
                    _buildSecondaryButton(
                      text: "Báo thiếu hàng",
                      icon: Icons.warning_amber_rounded,
                      onPressed: controller.reportStockIssue,
                    ),
                  ],
                );

            // --- Trạng thái 5 ---
              case 'out_for_delivery':
              case 'delivered':
              case 'completed':
                return _buildPrimaryButton(
                  text: "Đã hoàn tất",
                  icon: Icons.check_circle,
                  onPressed: null, // Disabled
                  color: kAppGreen,
                );

            // --- Trạng thái 6 ---
              case 'cancelled':
                return _buildPrimaryButton(
                  text: "Đã huỷ",
                  icon: Icons.cancel,
                  onPressed: null, // Disabled
                  color: Colors.red,
                );

              default:
                return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  // (Các hàm _buildPrimaryButton và _buildSecondaryButton giữ nguyên)
  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(text),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 18, color: Colors.red),
        label: Text(text, style: const TextStyle(color: Colors.red)),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          side: const BorderSide(color: Colors.red),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}