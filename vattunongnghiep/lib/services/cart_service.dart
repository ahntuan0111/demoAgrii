// services/cart_service.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart' show GetStorage;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart'; // Cần để lấy Product/Variant
import '../models/variant_model.dart'; // Cần để lấy Product/Variant

class CartService extends GetxService {
  final String _baseUrl = 'http://103.186.100.42:5000/api/v1';

  final GetStorage _storage = GetStorage();

  // --- HÀM HELPER: LẤY TOKEN VÀ TẠO HEADER ---
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = _storage.read('apiToken');
    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập. Không tìm thấy token.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- HÀM HELPER: XỬ LÝ RESPONSE TỪ API ---
  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return body; // Trả về dữ liệu (thường là object Cart)
    } else {
      // Ném lỗi với message từ server
      throw Exception(body['message'] ?? 'Đã xảy ra lỗi không xác định');
    }
  }

  // --- HÀM MỚI: Dùng bởi CartController.addToCart() ---
  // Trả về danh sách CartItem mới sau khi thêm
  Future<List<CartItem>> addItem(Product product, Variant variant, int quantity) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/cart');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'productId': product.id,
        'variantName': variant.name,
        'quantity': quantity,
      }),
    );

    // API trả về object Cart đầy đủ, chúng ta trích xuất 'items'
    final data = _handleResponse(response);
    final List<dynamic> itemsJson = data['items'];
    return itemsJson.map((json) => CartItem.fromJson(json)).toList();
  }


  // --- THAY THẾ HÀM GIẢ LẬP: getCartItems() ---
  Future<List<CartItem>> getCartItems() async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/cart');

    final response = await http.get(uri, headers: headers);

    // API trả về object Cart đầy đủ, chúng ta trích xuất 'items'
    final data = _handleResponse(response);
    final List<dynamic> itemsJson = data['items'];
    return itemsJson.map((json) => CartItem.fromJson(json)).toList();
  }

  // --- THAY THẾ HÀM GIẢ LẬP: updateItemQuantity() ---
  // Trả về danh sách CartItem mới sau khi cập nhật
  Future<List<CartItem>> updateItemQuantity(String cartItemId, int newQuantity) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/cart/$cartItemId');

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'newQuantity': newQuantity,
      }),
    );

    final data = _handleResponse(response);
    final List<dynamic> itemsJson = data['items'];
    return itemsJson.map((json) => CartItem.fromJson(json)).toList();
  }

  // --- THAY THẾ HÀM GIẢ LẬP: removeItem() ---
  // Trả về danh sách CartItem mới sau khi xóa
  Future<List<CartItem>> removeItem(String cartItemId) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/cart/$cartItemId');

    final response = await http.delete(uri, headers: headers);

    final data = _handleResponse(response);
    final List<dynamic> itemsJson = data['items'];
    return itemsJson.map((json) => CartItem.fromJson(json)).toList();
  }
}