// screens/checkout_screen.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/checkout_controller.dart'; // Adjust import path

// 1. CHUYỂN SANG GETVIEW<CheckoutController>
class CheckOutScreen extends GetView<CheckoutController> {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. KHÔNG CẦN initState/Get.put()
    //    'controller' đã có sẵn từ GetView (do Binding cung cấp)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Kiểm tra',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
            // ĐỊA CHỈ GIAO HÀNG
            const Text(
              'Địa chỉ giao hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 3. Thay 'checkOutController' thành 'controller'
            _buildInfoTile(
              title: controller.selectedAddress,
              onTap: controller.showAddressInputDialog,
            ),
            const Divider(height: 24),

            // THỜI GIAN NHẬN HÀNG
            const Text(
              'Thời gian nhận hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoTile(
              title: controller.selectedTime,
              onTap: () {
                Get.snackbar(
                    "Thông báo", "Chức năng chọn thời gian đang phát triển.");
              },
            ),
            const SizedBox(height: 24),

            // PHƯƠNG THỨC THANH TOÁN
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() => _PaymentMethodOption(
              title: 'Thanh toán khi nhận hàng',
              value: PaymentMethod.cod,
              groupValue: controller.selectedPaymentMethod.value,
              onChanged: (method) =>
                  controller.selectPaymentMethod(method!),
            )),
            const SizedBox(height: 8),
            Obx(() => _PaymentMethodOption(
              title: 'Thanh toán online',
              value: PaymentMethod.online,
              groupValue: controller.selectedPaymentMethod.value,
              onChanged: (method) =>
                  controller.selectPaymentMethod(method!),
            )),
            const SizedBox(height: 24),

            // TÓM TẮT ĐƠN HÀNG
            const Text(
              'Tóm tắt đơn hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // 4. BỌC CÁC GIÁ TRỊ TÓM TẮT TRONG OBX
            Obx(() => _buildSummaryRow(
                'Giá niêm yết', controller.subtotal.value, controller)),
            Obx(() => _buildSummaryRow(
                'Tiền ship', controller.shippingFee.value, controller)),
            Obx(() => _buildSummaryRow(
                'Phụ phí (thuế VAT)', controller.vatFee.value, controller)),
            const Divider(height: 16),
            Obx(() => _buildSummaryRow(
                'Giá tổng', controller.total.value, controller,
                isTotal: true)),
            const SizedBox(height: 24),

            // TÙY CHỌN THAY THẾ
            Obx(() => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Nếu hết hàng, hãy cho phép sản phẩm tương tự có giá bằng hoặc thấp hơn',
                style: TextStyle(fontSize: 14),
              ),
              value: controller.allowSubstitution.value,
              onChanged: controller.toggleSubstitution,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.green,
            )),
          ],
        ),
      ),
      bottomNavigationBar: _buildPlaceOrderButton(controller),
    );
  }

  /// Widget: hiển thị ô thông tin địa chỉ hoặc thời gian
  Widget _buildInfoTile(
      {required RxString title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Flexible(
              child: Text(
                title.value,
                style: const TextStyle(fontSize: 16),
              ),
            )),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Widget: hiển thị lựa chọn phương thức thanh toán
  Widget _PaymentMethodOption({
    required String title,
    required PaymentMethod value,
    required PaymentMethod groupValue,
    required ValueChanged<PaymentMethod?> onChanged,
  }) {
    bool isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            Radio<PaymentMethod>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: hiển thị dòng tóm tắt giá trị
  Widget _buildSummaryRow(
      String label, double value, CheckoutController controller,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(
            controller.currencyFormatter.format(value),
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget: nút đặt hàng (Thêm Obx để xử lý loading)
  Widget _buildPlaceOrderButton(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(top: 8.0),
      color: Colors.white,
      // 5. BỌC NÚT BẤM TRONG OBX
      child: Obx(() => ElevatedButton(
        // Vô hiệu hóa nút khi đang loading
        onPressed:
        controller.isLoading.value ? null : controller.placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF17CF17),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        // Hiển thị vòng xoay hoặc text
        child: controller.isLoading.value
            ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.white))
            : const Text(
          'Đặt hàng',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      )),
    );
  }
}