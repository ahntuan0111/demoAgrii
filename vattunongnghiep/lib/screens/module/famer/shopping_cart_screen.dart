// screens/cart_screen.dart (ĐÃ CẬP NHẬT LOGIC HIỂN THỊ)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/cart_controller.dart';
import '../../../models/cart_item_model.dart';
import '../../../routes/app_routes.dart';

// 1. CHUYỂN SANG GETVIEW<CartController>
class ShoppingCartScreen extends GetView<CartController> {
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. KHÔNG CẦN initState/dispose/Get.put()
    //    'controller' đã có sẵn

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
          'Giỏ hàng của tôi',
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
      body: Obx(() {
        // --- 3. CHỈ KIỂM TRA LOADING Ở ĐÂY ---
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        // --- 4. LUÔN HIỂN THỊ LAYOUT CHÍNH ---
        // (Không kiểm tra cartItems.isEmpty ở đây nữa)
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- 5. KIỂM TRA EMPTY/LIST Ở TRONG NÀY ---
              Obx(() {
                if (controller.cartItems.isEmpty) {
                  // NẾU RỖNG: Hiển thị Text
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0), // Thêm padding
                      child: Text(
                        "Giỏ hàng của bạn đang trống.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                } else {
                  // NẾU CÓ HÀNG: Hiển thị ListView
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.cartItems.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.cartItems[index];
                      return _CartItemCard(item: item, controller: controller);
                    },
                  );
                }
              }),
              // ----------------------------------------

              const SizedBox(height: 24),
              // KHUYẾN MÃI (Luôn hiển thị)
              _PromoCard(),
              const SizedBox(height: 24),
              // ĐỊA CHỈ GIAO HÀNG (Luôn hiển thị)
              const Text('Địa chỉ giao hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  prefixIcon:
                  Icon(Icons.home_outlined, color: Colors.grey[600]),
                  hintText: 'Nhập địa chỉ của bạn',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Giao hàng không tiếp xúc'),
                    Obx(
                          () => Switch(
                        value: controller.isContactlessDelivery.value,
                        onChanged: controller.toggleContactlessDelivery,
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // TỔNG KẾT (Luôn hiển thị)
              _buildTotalSection(controller),
            ],
          ),
        );
      }),
      // NÚT THANH TOÁN (Logic này đã đúng, tự ẩn khi giỏ hàng rỗng)
      bottomNavigationBar: _buildCheckoutButton(controller),
    );
  }

  Widget _buildTotalSection(CartController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Obx(
                    () => Text(
                  // (Hàm calculateTotals() trong controller sẽ trả về 0 nếu giỏ rỗng)
                  controller.currencyFormatter.format(controller.total.value),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
                () => Text(
              '- Khuyến mãi ${controller.currencyFormatter.format(controller.discount.value)} đã được áp dụng',
              style: const TextStyle(color: Colors.green, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(CartController controller) {
    return Obx(() => controller.cartItems.isEmpty
        ? const SizedBox.shrink() // Tự động ẩn nếu giỏ hàng rỗng
        : Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          Get.toNamed(AppRoutes.checkout);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF17CF17),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Thanh toán',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    ));
  }
}

// Widget cho thẻ khuyến mãi (Giữ nguyên)
class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Khuyến mãi có sẵn',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Giảm 500.000đ cho đơn hàng đầu tiên',
                    style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Sử dụng mã: FIRST500',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/images/promo_gift.png'),
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Widget cho mỗi sản phẩm trong giỏ hàng (Giữ nguyên)
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController controller;

  const _CartItemCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network( // <-- Đã sửa lỗi Image.asset
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.variantName, // <-- Đã sửa lỗi description
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(controller.currencyFormatter.format(item.price),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // (Phần nút +/- giữ nguyên)
          Row(
            children: [
              _buildQuantityButton(
                  Icons.remove, () => controller.decrementQuantity(item)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(item.quantity.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              _buildQuantityButton(
                  Icons.add, () => controller.incrementQuantity(item)),
            ],
          ),
        ],
      ),
    );
  }

  // (Hàm _buildQuantityButton giữ nguyên)
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }
}