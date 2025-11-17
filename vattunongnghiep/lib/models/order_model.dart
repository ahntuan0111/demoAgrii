import 'dart:convert';
import 'package:agri_flutter/models/cart_item_model.dart'; // (Giả sử bạn đã có)

// --- Helpers ---
List<Order> orderListFromJson(String str) =>
    List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

class Order {
  final String id;
  final List<CartItem> orderItems;
  final String shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double vatFee;
  final double totalPrice;
  final String status; // <-- TRƯỜNG QUAN TRỌNG
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderItems,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.vatFee,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["_id"],
    // (Giả sử API trả về 'orderItems', nếu không, dùng 'items')
    orderItems: List<CartItem>.from(
        (json["orderItems"] ?? json["items"] ?? [])
            .map((x) => CartItem.fromJson(x))),

    // (Giả sử API trả về 'shippingAddress' là String,
    // nếu là Object, dùng: json["shippingAddress"]["address"])
    shippingAddress: json["shippingAddress"] is String
        ? json["shippingAddress"]
        : (json["shippingAddress"]?["address"] ?? "N/A"),

    paymentMethod: json["paymentMethod"],
    subtotal: (json["subtotal"] ?? 0).toDouble(),
    shippingFee: (json["shippingFee"] ?? 0).toDouble(),
    vatFee: (json["vatFee"] ?? 0).toDouble(),
    totalPrice: (json["totalPrice"] ?? 0).toDouble(),
    status: json["status"], // <-- Gán status
    createdAt: DateTime.parse(json["createdAt"]),
  );
}