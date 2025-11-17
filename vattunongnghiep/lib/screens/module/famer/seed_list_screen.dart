// screens/seed_list_screen.dart (ĐÃ CẬP NHẬT ĐÚNG MODEL)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // <-- 1. IMPORT (Cần cho format tiền)

import '../../../controllers/seed_list_controller.dart';
import '../../../models/store_product_model.dart'; // <-- 2. SỬA MODEL
import '../../../routes/app_routes.dart';

class SeedListScreen extends GetView<SeedListController> {
  const SeedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. THÊM CURRENCY FORMATTER
    final currencyFormatter =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FCF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Các loại hạt giống',
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
          // Bộ lọc thương hiệu + Chip loại (Giữ nguyên)
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: controller.selectedBrand.value,
                      underline: const SizedBox.shrink(),
                      icon: Icon(Icons.arrow_drop_down,
                          color: Colors.green[800]),
                      style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500),
                      onChanged: (String? newValue) {
                        controller.changeBrand(newValue);
                      },
                      items: controller.brands
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                              value == 'Tất cả' ? 'Tất cả thương hiệu' : value),
                        );
                      }).toList(),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Chip(
                  label: const Text('Loại : hạt giống'),
                  backgroundColor: Colors.green[100],
                  labelStyle: TextStyle(color: Colors.green[800]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide.none,
                  ),
                ),
              ],
            ),
          ),

          // 4. CẬP NHẬT DANH SÁCH (BỌC TRONG OBX)
          Expanded(
            child: Obx(() {
              // (Loading/Empty states giữ nguyên)
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.green));
              }
              if (controller.productList.isEmpty) {
                return const Center(child: Text("Không tìm thấy sản phẩm nào."));
              }

              // 5. DANH SÁCH KHI CÓ DỮ LIỆU
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.productList.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  // SỬA: Dùng model 'StoreProduct'
                  final storeProduct = controller.productList[index];
                  return GestureDetector(
                    onTap: () {
                      // Gửi 'Product' (Sản phẩm gốc) đến màn hình chi tiết
                      Get.toNamed(AppRoutes.productDetail,
                          arguments: storeProduct.product);
                    },
                    // Truyền 'StoreProduct' vào _SeedListItem
                    child: _SeedListItem(
                        storeProduct: storeProduct,
                        formatter: currencyFormatter),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// 6. CẬP NHẬT _SeedListItem
class _SeedListItem extends StatelessWidget {
  final StoreProduct storeProduct; // <-- Đổi sang StoreProduct
  final NumberFormat formatter;
  const _SeedListItem({required this.storeProduct, required this.formatter});

  @override
  Widget build(BuildContext context) {
    // Lấy product gốc ra
    final product = storeProduct.product;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name, // <-- Dùng product.name
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0E1B0E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.description.split("\n\n")[0], // Tách mô tả
                style:
                const TextStyle(fontSize: 14, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Chip(
                // SỬA: Dùng giá của VTNN (storePrice)
                label: Text(formatter.format(storeProduct.storePrice)),
                backgroundColor: Colors.green[100],
                labelStyle: TextStyle(
                    color: Colors.green[800], fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide.none,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.images.isNotEmpty ? product.images[0] : '',
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 110,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ),
      ],
    );
  }
}