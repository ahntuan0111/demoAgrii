// screens/create_purchase_order_screen.dart (ĐÃ CẬP NHẬT menuMaxHeight)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/create_purchase_order_controller.dart';
import '../models/product_model.dart';
import '../models/variant_model.dart';

class CreatePurchaseOrderScreen extends GetView<CreatePurchaseOrderController> {
  const CreatePurchaseOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn đặt hàng mới'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- THẺ THÔNG TIN ĐƠN HÀNG ---
            _buildOrderInfoCard(currencyFormatter),

            // --- FORM THÊM SẢN PHẨM ---
            const SizedBox(height: 24),
            _buildProductAddForm(),

            const SizedBox(height: 24),
            const Text(
              "Sản phẩm đã chọn",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),

            // --- DANH SÁCH SẢN PHẨM ĐÃ THÊM ---
            _buildAddedItemsList(currencyFormatter),
          ],
        ),
      ),
      // --- NÚT TẠO ĐƠN HÀNG ---
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  // --- WIDGETS CON ---

  Widget _buildOrderInfoCard(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mã đơn hàng'),
              Text('PO-AGRII-${DateTime.now().day}...', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ngày tạo'),
              Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng sản phẩm:'),
              Obx(() => Text('${controller.orderItems.length} loại', style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng giá trị:'),
              Obx(() => Text(formatter.format(controller.totalAmount.value),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductAddForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Dropdown Sản phẩm
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return DropdownButtonFormField<Product>(
            value: controller.selectedProduct.value,
            hint: const Text('Chọn sản phẩm'),
            decoration: _inputDecoration(),

            // --- ✅ THÊM DÒNG NÀY ĐỂ GIỚI HẠN CHIỀU CAO ---
            menuMaxHeight: 300.0, // Giới hạn chiều cao (khoảng 4-5 item)
            // ------------------------------------------

            items: controller.masterProductList.map((Product product) {
              return DropdownMenuItem<Product>(
                value: product,
                child: Text(product.name),
              );
            }).toList(),
            onChanged: controller.onProductSelected,
          );
        }),
        const SizedBox(height: 12),

        // 2. Dropdown Đóng gói (Variant)
        Obx(() {
          // Chỉ hiển thị khi đã chọn sản phẩm
          if (controller.selectedProduct.value == null) {
            return const SizedBox.shrink();
          }
          return DropdownButtonFormField<Variant>(
            value: controller.selectedVariant.value,
            hint: const Text('Chọn đóng gói'),
            decoration: _inputDecoration(),

            // --- ✅ THÊM DÒNG NÀY ĐỂ GIỚI HẠN CHIỀU CAO ---
            menuMaxHeight: 300.0, // Giới hạn chiều cao
            // ------------------------------------------

            items: controller.selectedProduct.value!.variants.map((Variant variant) {
              return DropdownMenuItem<Variant>(
                value: variant,
                child: Text('${variant.name} (${variant.price}đ)'),
              );
            }).toList(),
            onChanged: controller.onVariantSelected,
          );
        }),
        const SizedBox(height: 12),

        // 3. Số lượng
        TextField(
          controller: controller.quantityController,
          decoration: _inputDecoration(hint: 'Số lượng'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // 4. Nút Thêm
        ElevatedButton.icon(
          onPressed: controller.addProductToOrder,
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Thêm sản phẩm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAddedItemsList(NumberFormat formatter) {
    return Obx(() {
      if (controller.orderItems.isEmpty) {
        return const Center(
            child: Text('Chưa có sản phẩm nào được thêm.',
                style: TextStyle(color: Colors.grey)));
      }
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.orderItems.length,
        itemBuilder: (context, index) {
          final item = controller.orderItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text(
                  'Đóng gói: ${item['variantName']} (SL: ${item['quantity']})'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => controller.removeProductFromOrder(index),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Obx(() => ElevatedButton.icon(
        onPressed: controller.isSubmitting.value ? null : controller.submitPurchaseOrder,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
            controller.isSubmitting.value ? 'Đang tạo...' : 'Tạo đơn đặt hàng',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      )),
    );
  }

  // Helper cho Input Decoration
  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.grey[100],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}