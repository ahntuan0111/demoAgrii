// models/purchase_order_item_model.dart
import 'dart:convert';

class PurchaseOrderItem {
  final String product; // Đây là 'productId'
  final String name;
  final String variantName;
  final String image;
  final int quantity;
  final double price;

  PurchaseOrderItem({
    required this.product,
    required this.name,
    required this.variantName,
    required this.image,
    required this.quantity,
    required this.price,
  });

  // Factory để parse mảng 'items' từ BE (PurchaseOrder)
  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      product: json["product"] as String,
      name: json["name"] as String,
      variantName: json["variantName"] as String,
      image: json["image"] as String,
      quantity: (json["quantity"] ?? 0) as int,
      price: (json["price"] ?? 0).toDouble(),
    );
  }
}