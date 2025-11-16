// screens/purchase_order_detail_screen.dart (ĐÃ FIX TOÀN BỘ LỖI)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/purchase_order_detail_controller.dart';
import '../models/purchase_order_item_model.dart';

class PurchaseOrderDetailScreen extends GetView<PurchaseOrderDetailController> {
  const PurchaseOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kAppGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.9),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- DRAG BAR & CLOSE BUTTON ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Chi tiết đơn đặt hàng',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // --- SCROLL CONTENT ---
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderInfo(kAppGreen),
                      const Divider(height: 24),
                      _buildProductList(),
                    ],
                  ),
                ),
              ),

              // --- BOTTOM BUTTON ---
              _buildBottomButton(kAppGreen),
            ],
          ),
        ),
      ),
    );
  }

  // ================================
  // HEADER INFO
  // ================================
  Widget _buildHeaderInfo(Color kAppGreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAppGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _headerRow('Mã đơn hàng', controller.po.shortPoNumber),
          const SizedBox(height: 12),

          _headerRow('Nhà cung cấp', 'Agrii Vietnam',
              valueColor: kAppGreen, isBold: true),
          const SizedBox(height: 12),

          _headerRow(
            'Ngày tạo',
            controller.dateFormatter.format(controller.po.createdAt),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trạng thái', style: TextStyle(color: Colors.grey)),
              Obx(
                    () => Text(
                  controller.statusText.value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: controller.isButtonEnabled.value
                        ? kAppGreen
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  // ================================
  // PRODUCT LIST
  // ================================
  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sản phẩm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...controller.po.items.map(_buildItemCard).toList(),
      ],
    );
  }

  // ================================
  // PRODUCT CARD
  // ================================
  Widget _buildItemCard(PurchaseOrderItem item) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(item.variantName, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 20),

            _buildPriceRow('Tồn kho:', '... Bao', Colors.blue.shade700),
            _buildPriceRow('Sau nhập:', '... Bao', Colors.green.shade700),

            // --- FIXED: correct named param ---
            _buildPriceRow(
              'Số lượng nhận:',
              '${item.quantity} Bao',
              Colors.black,
              isBold: true,
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: _inputDecoration(hint: 'Chủng loại'),
              controller: TextEditingController(text: item.variantName),
              readOnly: true,
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: _inputDecoration(hint: 'Hạn sử dụng'),
              controller: TextEditingController(text: 'dd/mm/yyyy'),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // BOTTOM BUTTON
  // ================================
  Widget _buildBottomButton(Color kAppGreen) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Obx(
            () => ElevatedButton.icon(
          onPressed: (controller.isLoading.value ||
              !controller.isButtonEnabled.value)
              ? null
              : controller.confirmReception,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: Text(
            controller.isLoading.value
                ? 'Đang xác nhận...'
                : 'Xác nhận đã nhận hàng',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppGreen,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  // ================================
  // PRICE ROW (ALREADY FIXED)
  // ================================
  Widget _buildPriceRow(
      String label,
      String value,
      Color? color, {
        bool isBold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // INPUT DECORATION
  // ================================
  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
