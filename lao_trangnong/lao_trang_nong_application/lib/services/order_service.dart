import 'dart:convert';
import 'dart:io';
// --- ✅ THÊM IMPORT NÀY ---
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../models/manager_order_model.dart';

class OrderService extends GetxService {
  final String _baseUrl = Platform.isAndroid
      ? 'http://192.168.0.144:5000/api/v1' // <-- ⚠️ THAY IP LAN CỦA BẠN
      : 'http://localhost:5000/api/v1';

  final GetStorage _storage = GetStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = _storage.read('apiToken');
    if (token == null) {
      developer.log('LỖI: Không tìm thấy apiToken trong storage', name: 'OrderService');
      throw Exception('Người dùng chưa đăng nhập.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- 1. LẤY DANH SÁCH ĐƠN HÀNG (ĐÃ CẬP NHẬT LOG) ---
  Future<List<ManagerOrder>> getManagerOrders() async {
    developer.log('--- OrderService (Manager): Đang gọi API getManagerOrders ---', name: 'OrderService');

    http.Response? response; // Khai báo ngoài để catch có thể dùng

    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('$_baseUrl/orders/manager');

      developer.log('URL: $uri', name: 'OrderService');
      developer.log('Token (cuối): ...${headers["Authorization"]?.substring((headers["Authorization"]?.length ?? 4) - 4)}', name: 'OrderService');

      response = await http.get(uri, headers: headers);

      // --- LOG QUAN TRỌNG NHẤT ---
      developer.log('Response Status Code: ${response.statusCode}', name: 'OrderService');
      developer.log('Response Body: ${response.body}', name: 'OrderService');
      // -------------------------

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<ManagerOrder> orders = managerOrderFromJson(response.body);
        developer.log('--- OrderService (Manager): Lấy và parse ${orders.length} đơn hàng THÀNH CÔNG ---', name: 'OrderService');
        return orders;
      } else {
        // Lỗi 4xx, 5xx
        developer.log('--- OrderService (Manager): Lấy đơn hàng THẤT BẠI (Lỗi Server) ---', name: 'OrderService');
        throw Exception(body['message'] ?? 'Lấy đơn hàng thất bại');
      }
    }
    on FormatException catch (e) {
      // Lỗi nếu jsonDecode(response.body) thất bại (thường là 500 trả về HTML)
      developer.log('LỖI (FormatException - Lỗi parse JSON): $e', error: e, name: 'OrderService');
      developer.log('Body (RAW) gây lỗi: ${response?.body ?? "Không có response"}', name: 'OrderService');
      throw Exception('Server trả về dữ liệu không phải JSON. Mã lỗi: ${response?.statusCode}');
    }
    catch (e) {
      developer.log('LỖI (Chung) [getManagerOrders]: $e', error: e, name: 'OrderService');
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  // --- 2. HÀM CHO NÚT "NHẬN ĐƠN" (ĐÃ CẬP NHẬT LOG) ---
  Future<void> acceptDelivery(String orderId) async {
    developer.log('--- OrderService (Manager): Đang gọi API acceptDelivery ---', name: 'OrderService');
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/orders/$orderId/accept-delivery');
    developer.log('URL: $uri', name: 'OrderService');

    try {
      final response = await http.put(uri, headers: headers);

      developer.log('Response Status Code: ${response.statusCode}', name: 'OrderService');
      developer.log('Response Body: ${response.body}', name: 'OrderService');

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        developer.log('LỖI (acceptDelivery): ${body['message']}', name: 'OrderService');
        throw Exception(body['message'] ?? 'Nhận đơn thất bại');
      }
      developer.log('--- OrderService (Manager): Nhận đơn THÀNH CÔNG ---', name: 'OrderService');
    } catch (e) {
      developer.log('LỖI (Chung) [acceptDelivery]: $e', error: e, name: 'OrderService');
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  // --- 3. HÀM XÁC NHẬN GIAO HÀNG (ĐÃ CẬP NHẬT LOG) ---
  Future<void> confirmDeliveryByManager(String orderId, String deliveryPhotoUrl) async {
    developer.log('--- OrderService (Manager): Đang gọi API confirmDeliveryByManager ---', name: 'OrderService');
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/orders/$orderId/deliver');
    developer.log('URL: $uri', name: 'OrderService');

    try {
      final response = await http.put(
          uri,
          headers: headers,
          body: jsonEncode({
            'deliveryPhotoUrl': deliveryPhotoUrl,
          })
      );

      developer.log('Response Status Code: ${response.statusCode}', name: 'OrderService');
      developer.log('Response Body: ${response.body}', name: 'OrderService');

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        developer.log('LỖI (confirmDelivery): ${body['message']}', name: 'OrderService');
        throw Exception(body['message'] ?? 'Xác nhận giao hàng thất bại');
      }
      developer.log('--- OrderService (Manager): Xác nhận giao hàng THÀNH CÔNG ---', name: 'OrderService');
    } catch (e) {
      developer.log('LỖI (Chung) [confirmDelivery]: $e', error: e, name: 'OrderService');
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  // --- 4. HÀM BÁO CÁO (ĐÃ CẬP NHẬT LOG) ---
  Future<void> createReport({
    required String orderId,
    required String issueType,
    required String description,
    String? imageUrl,
  }) async {
    developer.log('--- OrderService (Manager): Đang gọi API createReport ---', name: 'OrderService');
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/reports');
    final payload = {
      'orderId': orderId,
      'issueType': issueType,
      'description': description,
      'imageUrl': imageUrl,
    };
    developer.log('URL: $uri', name: 'OrderService');
    developer.log('Payload: ${jsonEncode(payload)}', name: 'OrderService');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      developer.log('Response Status Code: ${response.statusCode}', name: 'OrderService');
      developer.log('Response Body: ${response.body}', name: 'OrderService');

      final body = jsonDecode(response.body);
      if (response.statusCode != 201) {
        developer.log('LỖI (createReport): ${body['message']}', name: 'OrderService');
        throw Exception(body['message'] ?? 'Gửi báo cáo thất bại');
      }

      developer.log("--- OrderService (Manager): Gửi báo cáo THÀNH CÔNG! ---");
    } catch (e) {
      developer.log('LỖI (Chung) [createReport]: $e', error: e, name: 'OrderService');
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }
}