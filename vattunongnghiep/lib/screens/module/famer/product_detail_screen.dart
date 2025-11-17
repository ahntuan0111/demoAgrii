// screens/product_detail_screen.dart (ĐÃ CẬP NHẬT HOÀN CHỈNH)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// 1. IMPORT CÁC FILE CẦN THIẾT
import '../../../models/product_model.dart';
import '../../../models/variant_model.dart';
import '../../../shared/widgets/review_section.dart';
import '../../../controllers/cart_controller.dart'; // <-- 1. IMPORT CART CONTROLLER

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // 2. TÌM CART CONTROLLER (ĐÃ ĐƯỢC ĐĂNG KÝ TRONG MAIN.DART)
  final CartController cartController = Get.find<CartController>();

  late Variant selectedVariant;
  int _quantity = 1;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();

    // 4. KHỞI TẠO STATE
    // Mặc định chọn biến thể đầu tiên
    if (widget.product.variants.isNotEmpty) {
      selectedVariant = widget.product.variants.first;
    } else {
      // Xử lý trường hợp SP không có biến thể (lỗi data)
      selectedVariant = Variant(
          name: "Mặc định", price: widget.product.price, quantity: 0);
    }

    // Logic khởi tạo Youtube (giữ nguyên)
    final videoId = _getYoutubeVideoId(widget.product.videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  // 5. CẬP NHẬT HÀM SỐ LƯỢNG
  void _incrementQuantity() {
    // Kiểm tra với số lượng tồn kho của BIẾN THỂ ĐANG CHỌN
    if (_quantity < selectedVariant.quantity) {
      setState(() {
        _quantity++;
      });
    } else {
      Get.snackbar("Thông báo",
          "Đã đạt số lượng tối đa trong kho (${selectedVariant.quantity})");
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    // Tách description và safetyInfo (Logic này nên ở trong View)
    String desc = widget.product.description;
    String safety = "Thông tin an toàn không có sẵn.";
    if (widget.product.description.contains("\n\nThông tin an toàn:")) {
      var parts =
      widget.product.description.split("\n\nThông tin an toàn:");
      desc = parts[0];
      safety = parts[1].trim();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(widget.product.brand, // Dùng brand
            style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            // Image (Dùng Image.network)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.product.images.isNotEmpty
                      ? widget.product.images[0]
                      : '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title and Description
            Text('${widget.product.name} (${widget.product.brand})',
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 16),

            // --- 6. CẬP NHẬT HOÀN TOÀN 'Package Options' ---
            if (widget.product.variants.isNotEmpty)
              Wrap(
                // Dùng Wrap thay Row để tự xuống dòng
                spacing: 8.0, // Khoảng cách ngang
                runSpacing: 4.0, // Khoảng cách dọc
                children: widget.product.variants.map((variant) {
                  bool isSelected = selectedVariant.name == variant.name;
                  return ChoiceChip(
                    label: Text(variant.name), // Hiển thị tên biến thể
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedVariant = variant; // Cập nhật biến thể
                        _quantity = 1; // Reset số lượng về 1 khi đổi biến thể
                      });
                    },
                    selectedColor: Colors.green[100],
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.green[800] : Colors.black,
                        fontWeight: FontWeight.w500),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // --- 7. CẬP NHẬT 'Price Details' ---
            const Divider(),
            // Giá gốc (Original Price) - Ta sẽ dùng giá hiển thị (thấp nhất) của BE
            _buildPriceRow('Giá niêm yết', widget.product.price,
                isStrikethrough: true),
            // Giá sau ưu đãi (Discounted Price) - Ta sẽ dùng giá của BIẾN THỂ
            _buildPriceRow('Giá sản phẩm', selectedVariant.price,
                isBold: true),
            const Divider(),
            const SizedBox(height: 16),

            // ... (Phần Youtube player giữ nguyên) ...
            if (_youtubeController != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.green,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.green,
                    handleColor: Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Hướng dẫn sử dụng an toàn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(safety,
                style: const TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 24),

            // --- 8. CẬP NHẬT 'Quantity Selector' ---
            _buildQuantitySelector(),
            const SizedBox(height: 24),

            // Add to Cart Button (Cập nhật onPressed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // --- 3. CẬP NHẬT LOGIC ONPRESSED ---
                onPressed: () {
                  // GỌI HÀM CỦA CART CONTROLLER
                  cartController.addToCart(
                    widget.product,
                    selectedVariant,
                    _quantity,
                  );
                },
                // ---------------------------------
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17CF17),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Thêm vào giỏ hàng',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),

            const Divider(),
            ReviewSection(),
          ],
        ),
      ),
    );
  }

  // --- 9. TẠO WIDGET MỚI CHO BỘ CHỌN SỐ LƯỢNG ---
  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Số lượng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black54),
                onPressed: _decrementQuantity,
                splashRadius: 20,
              ),
              Text(
                _quantity.toString(),
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: _incrementQuantity,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // (Hàm _buildPriceRow và _getYoutubeVideoId giữ nguyên)
  Widget _buildPriceRow(String label, double? price,
      {bool isStrikethrough = false,
        bool isBold = false,
        bool isDiscount = false}) {
    final currencyFormatter =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: isDiscount
                    ? Colors.red
                    : (isBold ? Colors.black : Colors.grey),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          if (price != null)
            Text(currencyFormatter.format(price),
                style: TextStyle(
                  decoration: isStrikethrough
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                )),
        ],
      ),
    );
  }

  String? _getYoutubeVideoId(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.contains("youtu.be/")) {
      return url.split("youtu.be/").last.split("?").first;
    }
    if (url.contains("youtube.com/watch?v=")) {
      return url.split("watch?v=").last.split("&").first;
    }
    return null;
  }
}