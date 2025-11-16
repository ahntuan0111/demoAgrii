import 'dart:convert';
import 'cart_item_model.dart'; // (Đảm bảo bạn có file này)
import 'geolocation_model.dart'; // (Import file vừa sửa ở trên)

// --- HÀM HELPER (Giữ nguyên) ---
List<ManagerOrder> managerOrderFromJson(String str) => List<ManagerOrder>.from(
    json.decode(str).map((x) => ManagerOrder.fromJson(x)));

// --- MODEL CHÍNH (Đã sửa) ---
class ManagerOrder {
  final String id;
  final String status;
  final String shippingAddress;
  final double totalPrice;
  final double commission;
  final double amountPayableToStore;
  final double? distance; // <-- Đã là nullable (an toàn)
  final String customerName;
  final String storeName;
  final String customerPhone;
  final GeoLocation storeLocation;
  final GeoLocation shippingLocation; // <-- Sẽ dùng GeoLocation.fromJson đã sửa
  final List<CartItem> orderItems;

  ManagerOrder({
    required this.id,
    required this.status,
    required this.shippingAddress,
    required this.totalPrice,
    required this.commission,
    required this.amountPayableToStore,
    this.distance,
    required this.customerName,
    required this.storeName,
    required this.customerPhone,
    required this.storeLocation,
    required this.shippingLocation,
    required this.orderItems,
  });

  factory ManagerOrder.fromJson(Map<String, dynamic> json) {
    return ManagerOrder(
      id: json["_id"],
      status: json["status"],

      // Đọc "address" từ bên trong object "shippingAddress"
      shippingAddress: json["shippingAddress"] != null
          ? json["shippingAddress"]["address"] ?? "N/A"
          : "N/A",

      totalPrice: (json["totalPrice"] ?? 0).toDouble(),
      commission: (json["commission"] ?? 0).toDouble(),
      amountPayableToStore: (json["amountPayableToStore"] ?? 0).toDouble(),

      // Đọc "distance" an toàn (vì BE không gửi)
      distance: (json["distance"])?.toDouble(),

      customerName: json["customerName"] ?? "N/A",
      storeName: json["storeName"] ?? "N/A",
      customerPhone: json["customerPhone"] ?? "N/A",

      // Parse các object con
      // Các hàm fromJson này giờ đã an toàn
      storeLocation: GeoLocation.fromJson(json["storeLocation"] ?? {}),
      shippingLocation: GeoLocation.fromJson(json["shippingLocation"] ?? {}),
      orderItems: List<CartItem>.from(
          (json["orderItems"] ?? []).map((x) => CartItem.fromJson(x))),
    );
  }
}