import 'dart:convert';
import 'cart_item_model.dart'; // (Tái sử dụng)

List<VtnnOrder> vtnnOrderListFromJson(String str) =>
    List<VtnnOrder>.from(json.decode(str).map((x) => VtnnOrder.fromJson(x)));

class VtnnOrder {
  final String id;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final List<CartItem> orderItems;
  final String customerName;
  final String customerPhone; // <-- ✅ 1. ĐÃ THÊM THUỘC TÍNH
  final String managerName;
  final String managerRole; // 'laonohg' hoặc 'trangnong'

  VtnnOrder({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.orderItems,
    required this.customerName,
    required this.customerPhone, // <-- ✅ 2. THÊM VÀO CONSTRUCTOR
    required this.managerName,
    required this.managerRole,
  });

  // Đếm tổng số sản phẩm
  int get totalItemCount =>
      orderItems.fold(0, (sum, item) => sum + item.quantity);

  // Rút gọn ID
  String get shortId {
    try {
      return "ORD-${id.substring(id.length - 6)}".toUpperCase();
    } catch (e) {
      return id;
    }
  }

  // Lấy chữ viết tắt (LN/TN)
  String get managerRoleAbbreviation {
    if (managerRole == 'laonong') return 'LN';
    if (managerRole == 'trangnong') return 'TN';
    return 'QL';
  }

  factory VtnnOrder.fromJson(Map<String, dynamic> json) {
    return VtnnOrder(
      id: json["_id"],
      status: json["status"],
      totalPrice: (json["totalPrice"] ?? 0).toDouble(),
      createdAt: DateTime.parse(json["createdAt"]),
      orderItems: List<CartItem>.from(
          (json["orderItems"] ?? []).map((x) => CartItem.fromJson(x))),
      // Đọc từ 'user' (Nông dân)
      customerName: json["user"] != null ? json["user"]["name"] : "N/A",
      // --- ✅ 3. SỬA LỖI TẠI ĐÂY ---
      customerPhone: json["user"] != null ? json["user"]["phoneNumber"] : "N/A",
      // -------------------------
      // Đọc từ 'manager' (Lão/Tráng Nông)
      managerName: json["manager"] != null ? json["manager"]["name"] : "Chưa gán",
      managerRole: json["manager"] != null ? json["manager"]["role"] : "",
    );
  }
}