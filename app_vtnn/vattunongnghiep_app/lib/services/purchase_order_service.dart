// services/purchase_order_service.dart (ĐÃ THÊM LOG CHI TIẾT)
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show Platform;
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // Cho debugPrint

import '../models/purchase_order_model.dart';

class PurchaseOrderService extends GetxService {
  // final String _baseUrl = Platform.isAndroid
  //     ? 'http://192.168.0.144:5000/api/v1' // <-- ⚠️ THAY IP LAN CỦA BẠN
  //     : 'http://localhost:5000/api/v1';

  final String _baseUrl = 'http://103.186.100.42:5000/api/v1';

  final GetStorage _storage = GetStorage();

  // --- Hàm helper lấy token ---
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = _storage.read('apiToken');
    if (token == null) {
      debugPrint("--- PurchaseOrderService: Lỗi: Không tìm thấy apiToken.");
      throw Exception('Người dùng chưa đăng nhập.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- LẤY DANH SÁCH ĐƠN NHẬP HÀNG CỦA VTNN ---
  Future<List<PurchaseOrder>> getMyPurchaseOrders() async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/purchase-orders/my-pos'); // API của BE

    debugPrint("--- PurchaseOrderService (getMyPurchaseOrders): Đang gọi API...");
    debugPrint("URL: $uri");
    debugPrint("Token: ${headers['Authorization']?.substring(0, 20)}...");

    try {
      final response = await http.get(uri, headers: headers);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint("--- PurchaseOrderService (getMyPurchaseOrders): Phản hồi Thành Công ---");
        debugPrint("Status Code: ${response.statusCode}");
        return purchaseOrderListFromJson(response.body);
      } else {
        // --- ✅ LOG LỖI 4xx, 5xx ---
        debugPrint("--- PurchaseOrderService (getMyPurchaseOrders): Phản hồi Thất Bại ---");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        // -------------------------
        throw Exception(body['message'] ?? 'Lấy đơn hàng thất bại');
      }
    } catch (e) {
      // --- ✅ LOG LỖI KẾT NỐI (VD: FORMATEXCEPTION) ---
      debugPrint("--- PurchaseOrderService (getMyPurchaseOrders): Lỗi Catch ---");
      debugPrint("Lỗi: ${e.toString()}");
      // ---------------------------------
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  // --- TẠO MỚI ĐƠN ĐẶT HÀNG ---
  Future<void> createPurchaseOrder(List<Map<String, dynamic>> items) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/purchase-orders'); // POST /

    debugPrint("--- PurchaseOrderService (createPurchaseOrder): Đang gọi API...");
    debugPrint("URL: $uri");
    debugPrint("Body: ${jsonEncode({'items': items})}");

    try {
      final response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode({'items': items}) // Gửi mảng items
      );

      if (response.statusCode != 201) {
        // --- ✅ LOG LỖI 4xx, 5xx ---
        debugPrint("--- PurchaseOrderService (createPurchaseOrder): Phản hồi Thất Bại ---");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        // -------------------------
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Tạo đơn đặt hàng thất bại');
      }

      debugPrint("--- PurchaseOrderService (createPurchaseOrder): Phản hồi Thành Công ---");
      // (Không cần trả về gì, chỉ cần thành công)

    } catch (e) {
      // --- ✅ LOG LỖI KẾT NỐI (VD: FORMATEXCEPTION) ---
      debugPrint("--- PurchaseOrderService (createPurchaseOrder): Lỗi Catch ---");
      debugPrint("Lỗi: ${e.toString()}");
      // ---------------------------------
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  // --- ✅ THÊM HÀM MỚI NÀY VÀO ---
  // (Gọi khi VTNN nhấn "Xác nhận đã nhận hàng")
  Future<void> receivePurchaseOrder(String poId) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/purchase-orders/$poId/receive'); // PUT /:id/receive

    debugPrint("PurchaseOrderService: Đang xác nhận nhận hàng (PO)...");
    debugPrint("URL: $uri");

    try {
      final response = await http.put(uri, headers: headers); // Dùng PUT

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        debugPrint("PurchaseOrderService: Lỗi: ${response.body}");
        throw Exception(body['message'] ?? 'Xác nhận nhận hàng thất bại');
      }

      debugPrint("PurchaseOrderService: Xác nhận thành công.");
    } catch (e) {
      debugPrint("PurchaseOrderService: Lỗi Catch: ${e.toString()}");
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

}