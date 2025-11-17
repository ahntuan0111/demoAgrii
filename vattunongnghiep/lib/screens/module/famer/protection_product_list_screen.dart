// screens/protection_product_list_screen.dart (ĐÃ CẬP NHẬT)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // <-- 1. Import intl để format tiền

import '../../../controllers/protection_product_list_controller.dart';
import '../../../models/store_product_model.dart'; // <-- 2. SỬA MODEL
import '../../../routes/app_routes.dart';

// 3. CHUYỂN SANG GETVIEW
class ProtectionProductListScreen extends GetView<ProtectionProductListController> {
  const ProtectionProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. KHÔNG CẦN Get.put() (đã có trong binding)
    final currencyFormatter =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FCF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Bảo vệ mùa màng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.eco, color: Colors.green),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // 5. CHỈ GIỮ LẠI FILTER BRAND
                Obx(() => _FilterDropdown(
                  value: controller.selectedBrand.value,
                  items: controller.brands,
                  onChanged: controller.updateBrand,
                  prefix: 'Brand: ', // Thêm prefix cho rõ
                )),
                const SizedBox(width: 8),
                Chip(
                  label: const Text('Loại : Bảo vệ'),
                  backgroundColor: Colors.green[100],
                  labelStyle: TextStyle(color: Colors.green[800]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                ),
              ],
            ),
          ),
          // Product list
          Expanded(
            child: Obx(() {
              // 6. THÊM TRẠNG THÁI LOADING
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.green));
              }
              // 7. THÊM TRẠNG THÁI RỖNG
              if (controller.productList.isEmpty) {
                return const Center(
                    child: Text("Không tìm thấy sản phẩm phù hợp."));
              }

              // --- 8. CẬP NHẬT LISTVIEW ---
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: controller.productList.length,
                itemBuilder: (context, index) {
                  // SỬA: Dùng 'StoreProduct'
                  final storeProduct = controller.productList[index];

                  return ListTile(
                    onTap: () {
                      // Gửi 'Product' (Sản phẩm gốc) đến màn hình chi tiết
                      Get.toNamed(AppRoutes.productDetail,
                          arguments: storeProduct.product);
                    },
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(
                          // Lấy ảnh từ 'product' (lồng bên trong)
                          storeProduct.product.images.isNotEmpty
                              ? storeProduct.product.images[0]
                              : '',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image),
                        ),
                      ),
                    ),
                    title: Text(
                        storeProduct.product.name, // Lấy tên từ 'product'
                        style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(
                      // Lấy brand/status từ 'product'
                      '${storeProduct.product.brand} · ${storeProduct.product
                          .status == 'active' ? "Còn hàng" : "Hết hàng"}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      // SỬA: Lấy giá bán của VTNN
                      currencyFormatter.format(storeProduct.storePrice),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                },
              );
              // -----------------------------
            }),
          ),
        ],
      ),
    );
  }
}

// Custom Dropdown Widget (tái sử dụng - Giữ nguyên)
class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? prefix;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              '${prefix ?? ''}$item', // Thêm prefix vào text
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }
}