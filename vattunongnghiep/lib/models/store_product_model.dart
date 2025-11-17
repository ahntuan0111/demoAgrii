// models/store_product_model.dart
import 'dart:convert';
import 'package:agri_flutter/models/product_model.dart'; // Import model gốc

List<StoreProduct> storeProductListFromJson(String str) =>
    List<StoreProduct>.from(json.decode(str).map((x) => StoreProduct.fromJson(x)));

/// Đại diện cho một sản phẩm CÓ TRONG KHO của VTNN
class StoreProduct {
  final String id; // ID của bản ghi Tồn kho (Inventory ID)
  final String storeId;
  final double storePrice; // Giá bán mà VTNN này quyết định
  final int storeQuantity; // Số lượng VTNN này có
  final String status;
  final Product product; // Thông tin sản phẩm gốc (tên, ảnh, mô tả...)

  StoreProduct({
    required this.id,
    required this.storeId,
    required this.storePrice,
    required this.storeQuantity,
    required this.status,
    required this.product,
  });

  /// Hàm "dịch" JSON trả về từ API /api/v1/inventory/customer-store
  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: json["_id"],
      storeId: json["store"],
      storePrice: (json["price"] ?? 0).toDouble(), // Lấy giá của VTNN
      storeQuantity: (json["quantity"] ?? 0).toInt(),
      status: json["status"],
      // "product" là một object lồng bên trong
      product: Product.fromJson(json["product"]),
    );
  }
}