import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../models/vtnn_order_model.dart';

class VtnnOrderService extends GetxService {
  // final String _baseUrl = Platform.isAndroid
  //     ? 'http://192.168.0.144:5000/api/v1' // <-- ⚠️ THAY IP LAN CỦA BẠN
  //     : 'http://localhost:5000/api/v1';

  final String _baseUrl = 'http://103.186.100.42:5000/api/v1';

  final GetStorage _storage = GetStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = _storage.read('apiToken');
    if (token == null) throw Exception('Người dùng chưa đăng nhập.');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Lấy TẤT CẢ đơn hàng được gán cho VTNN
  Future<List<VtnnOrder>> getStoreOrders() async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/orders/store'); // API của BE

    debugPrint("VtnnOrderService: Đang lấy danh sách đơn hàng...");

    try {
      final response = await http.get(uri, headers: headers);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint("VtnnOrderService: Lấy đơn hàng thành công.");
        return vtnnOrderListFromJson(response.body);
      } else {
        throw Exception(body['message'] ?? 'Lấy đơn hàng thất bại');
      }
    } catch (e) {
      debugPrint("VtnnOrderService: Lỗi: ${e.toString()}");
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  // --- ✅ HÀM MỚI ĐƯỢC THÊM VÀO ĐỂ SỬA LỖI ---
  /// (VTNN) Cập nhật trạng thái của một đơn hàng
  Future<VtnnOrder> updateOrderStatus(String orderId, String newStatus) async {
    final headers = await _getAuthHeaders();
    // API này dành riêng cho VTNN cập nhật, theo gợi ý của bạn
    final uri = Uri.parse('$_baseUrl/orders/$orderId/status/store');

    debugPrint(
        "VtnnOrderService: Đang cập nhật trạng thái cho $orderId -> $newStatus");

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({'status': newStatus}), // Gửi trạng thái mới
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint("VtnnOrderService: Cập nhật thành công.");
        // Trả về order đã được cập nhật (theo logic của controller)
        return VtnnOrder.fromJson(body);
      } else {
        debugPrint(
            "VtnnOrderService: Cập nhật thất bại (${response.statusCode}): ${response.body}");
        throw Exception(body['message'] ?? 'Cập nhật trạng thái thất bại');
      }
    } catch (e) {
      debugPrint("VtnnOrderService: Lỗi (updateOrderStatus): ${e.toString()}");
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }
}