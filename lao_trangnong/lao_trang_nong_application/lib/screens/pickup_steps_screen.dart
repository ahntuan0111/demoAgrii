// screens/pickup_steps_screen.dart (ĐÃ SỬA LỖI TRÀN OVERFLOW)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pickup_steps_controller.dart';
// (Import AppColors nếu có)

class PickupStepsScreen extends GetView<PickupStepsController> {
  const PickupStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // (Giả sử AppColors)
    const Color kAppGreen = Color(0xFF1B5E20); // (Màu xanh đậm)
    const Color kAppGrey = Color(0xFFF4F6F5);

    return Scaffold(
      backgroundColor: kAppGrey, // Màu nền xám nhạt
      appBar: AppBar(
        backgroundColor: kAppGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Lấy hàng: DH-${controller.order.id.substring(0, 8)}...',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. THANH STEPPER ---
          _buildStepper(kAppGreen),

          // --- ✅ SỬA LỖI OVERFLOW TẠI ĐÂY ---
          // 2. NỘI DUNG (Card)
          Expanded(
            // Bọc 3 Card trong SingleChildScrollView
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStoreCard(kAppGreen),
                  const SizedBox(height: 16),
                  _buildProductsCard(kAppGreen),
                  const SizedBox(height: 16),
                  _buildFarmerInfoCard(),
                ],
              ),
            ),
          ),
          // --- KẾT THÚC SỬA LỖI ---

          // --- 3. NÚT BẤM CHÍNH ---
          _buildBottomButton(kAppGreen),
        ],
      ),
    );
  }

  // --- WIDGETS CON ---

  // 1. Stepper
  Widget _buildStepper(Color kAppGreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white, // (Màu nền trắng)
      child: Obx(() => Row(
        children: [
          _buildStepCircle('1', 'Đến VTNN', controller.currentStep.value >= 0, kAppGreen),
          _buildStepLine(controller.currentStep.value >= 1, kAppGreen),
          _buildStepCircle('2', 'Nộp tiền', controller.currentStep.value >= 1, kAppGreen),
          _buildStepLine(controller.currentStep.value >= 2, kAppGreen),
          _buildStepCircle('3', 'Lấy hàng đi giao', controller.currentStep.value >= 2, kAppGreen),
        ],
      )),
    );
  }

  Widget _buildStepCircle(String number, String label, bool isActive, Color kAppGreen) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? kAppGreen : Colors.grey[300],
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? Colors.black : Colors.grey))
      ],
    );
  }

  Widget _buildStepLine(bool isActive, Color kAppGreen) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? kAppGreen : Colors.grey[300],
      ),
    );
  }

  // 2. Card VTNN
  Widget _buildStoreCard(Color kAppGreen) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Điểm Lấy hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(controller.order.storeName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kAppGreen)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: controller.openDirectionsToStore,
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Chỉ đường'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.grey[300]!),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 3. Card Sản phẩm
  Widget _buildProductsCard(Color kAppGreen) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            // Danh sách
            ...controller.order.orderItems.map((item) =>
                _buildItemRow(item.name, item.variantName, item.quantity)
            ),
            const Divider(height: 20),
            // Chi tiết tiền
            _buildPriceRow('Giá chiết khấu', controller.currencyFormatter.format(controller.order.amountPayableToStore), Colors.orange.shade700),
            _buildPriceRow('Giá nhà nông trả', controller.currencyFormatter.format(controller.order.totalPrice)),
            _buildPriceRow('TN (10%)', '+${controller.currencyFormatter.format(controller.order.commission)}', kAppGreen),
            _buildPriceRow('LN Trực thuộc (5%)', '+130.000VNĐ (Fake)', kAppGreen),
          ],
        ),
      ),
    );
  }

  // 4. Card Thông tin nông dân
  Widget _buildFarmerInfoCard() {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin nông dân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(controller.order.shippingAddress, style: const TextStyle(fontSize: 15))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.call_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(controller.order.customerPhone, style: const TextStyle(fontSize: 15))),
                OutlinedButton(onPressed: controller.callCustomer, child: const Text('Gọi')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Nút bấm dưới cùng
  Widget _buildBottomButton(Color kAppGreen) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Obx(() {
        // Thay đổi text của nút dựa trên Step
        String buttonText = 'Đã đến VTNN';
        if (controller.currentStep.value == 1) buttonText = 'Xác nhận đã thanh toán';
        if (controller.currentStep.value == 2) buttonText = 'Bắt đầu giao hàng';

        return ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.handleMainButtonAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: controller.isLoading.value
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
              : Text(buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        );
      }),
    );
  }

  // Helper cho danh sách item
  Widget _buildItemRow(String name, String variant, int quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('$name ($variant) (x$quantity)', style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  // Helper cho dòng giá tiền
  Widget _buildPriceRow(String label, String value, [Color? color]) {
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
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}