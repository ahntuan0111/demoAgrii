import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

// THÊM IMPORT NÀY ĐỂ LOG ĐẸP HƠN
import 'dart:developer' as developer;

import '../models/order_model.dart'; // Đảm bảo bạn đã import model

class OrderService extends GetxService {
  final String _baseUrl = 'http://103.186.100.42:5000/api/v1';

  final GetStorage _storage = GetStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = _storage.read('apiToken');
    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- HÀM CREATE ORDER (ĐÃ CẬP NHẬT LOG) ---
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/orders');

    // --- LOG 1: DỮ LIỆU GỬI ĐI ---
    String jsonData = "Không thể encode JSON";
    try {
      jsonData = jsonEncode(orderData);
    } catch (e) {
      developer.log('LỖI NGHIÊM TRỌNG: Không thể encode orderData thành JSON',
          error: e, name: 'OrderService');
      throw Exception('Lỗi dữ liệu giỏ hàng (JSON encode): ${e.toString()}');
    }

    developer.log('--- OrderService: Đang tạo đơn hàng ---',
        name: 'OrderService');
    developer.log('URL: $uri', name: 'OrderService');
    developer.log('Body gửi đi: $jsonData', name: 'OrderService');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonData, // Gửi dữ liệu đã encode
      );

      // --- LOG 2: PHẢN HỒI TỪ SERVER ---
      developer.log('Response Status Code: ${response.statusCode}',
          name: 'OrderService');
      developer.log('Response Body: ${response.body}',
          name: 'OrderService'); // Log TOÀN BỘ body

      // Thử decode JSON (có thể thất bại nếu server trả về HTML/text)
      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Thành công
        developer.log('--- OrderService: Tạo đơn hàng THÀNH CÔNG ---',
            name: 'OrderService');
        return body;
      } else {
        // Lỗi từ server (400, 500...)
        developer.log(
            '--- OrderService: Tạo đơn hàng THẤT BẠI (Lỗi Server) ---',
            name: 'OrderService');
        // Dùng 'message' hoặc toàn bộ body nếu không có 'message'
        throw Exception(
            body['message'] ?? 'Tạo đơn hàng thất bại: ${response.body}');
      }
    } on http.ClientException catch (e) {
      // Lỗi kết nối mạng, client
      developer.log('LỖI (http.ClientException): $e',
          error: e, name: 'OrderService');
      throw Exception('Lỗi kết nối (Client): ${e.message}');
    } on SocketException catch (e) {
      // Lỗi không có mạng, không tìm thấy host
      developer.log('LỖI (SocketException): $e',
          error: e, name: 'OrderService');
      throw Exception(
          'Không có kết nối mạng hoặc không tìm thấy server: ${e.message}');
    } on FormatException catch (e) {
      // Lỗi jsonDecode (thường là server trả về HTML/text thay vì JSON)
      developer.log('LỖI (FormatException): $e', error: e, name: 'OrderService');
      throw Exception(
          'Server trả về dữ liệu không phải JSON. Hãy kiểm tra Response Body ở log.');
    } catch (e) {
      // Bắt các lỗi còn lại (ví dụ: Exception ta tự ném ở 'else')
      developer.log('LỖI (Chung): $e', error: e, name: 'OrderService');
      // Ném lại lỗi đó
      rethrow;
    }
  }

  // --- HÀM GET MY ORDERS (Giữ nguyên) ---
  Future<List<Order>> getMyOrders() async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/orders/myorders');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return orderListFromJson(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Lấy lịch sử đơn hàng thất bại');
      }
    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }
// --- ✅ HÀM MỚI ĐƯỢC THÊM VÀO ---
  /// (Customer) Xác nhận đã nhận hàng
  /// Gọi API: PUT /api/v1/orders/:id/complete
  Future<Order> completeOrderByCustomer(String orderId) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/orders/$orderId/complete');

    developer.log('--- OrderService: Đang xác nhận nhận hàng (complete) ---', name: 'OrderService');
    developer.log('URL: $uri', name: 'OrderService');

    try {
      final response = await http.put(uri, headers: headers);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('--- OrderService: Xác nhận THÀNH CÔNG ---', name: 'OrderService');
        // Trả về đơn hàng đã cập nhật
        return Order.fromJson(body);
      } else {
        developer.log('--- OrderService: Xác nhận THẤT BẠI ---', name: 'OrderService');
        throw Exception(body['message'] ?? 'Xác nhận thất bại');
      }
    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }
}