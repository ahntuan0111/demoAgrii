// models/purchase_order_model.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'dart:convert';

import 'package:vattunongnghiep_app/models/purchase_order_item_model.dart';

List<PurchaseOrder> purchaseOrderListFromJson(String str) =>
    List<PurchaseOrder>.from(
        json.decode(str).map((x) => PurchaseOrder.fromJson(x)));

class PurchaseOrder {
  final String id;
  final String storeId;
  final String poNumber;
  final List<PurchaseOrderItem> items; // <-- 2. SỬA KIỂU DỮ LIỆU
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  PurchaseOrder({
    required this.id,
    required this.storeId,
    required this.poNumber,
    required this.items, // <-- Sửa
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  // Đếm tổng số sản phẩm
  int get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  // Rút gọn ID (VD: PO-AGRII-20251112-001)
  String get shortPoNumber {
    try {
      // Giả sử poNumber là "PO-AGRII-20251112-001"
      var parts = poNumber.split('-');
      if (parts.length == 3) {
        return "PO-${parts[2]}"; // Trả về "PO-001"
      }
      return poNumber;
    } catch (e) {
      return id; // Dự phòng
    }
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json["_id"],
      storeId: json["store"],
      poNumber: json["poNumber"],
      // --- 3. SỬA HÀM MAP ---
      items: List<PurchaseOrderItem>.from(
          (json["items"] ?? []).map((x) => PurchaseOrderItem.fromJson(x))),
      // --------------------
      totalAmount: (json["totalAmount"] ?? 0).toDouble(),
      status: json["status"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}