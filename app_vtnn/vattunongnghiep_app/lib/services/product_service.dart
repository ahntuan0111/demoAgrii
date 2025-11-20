import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // <-- 1. IMPORT ĐỂ DÙNG DEBUGPRINT
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../models/product_model.dart';

class ProductService extends GetxService {
  // final String _baseUrl = Platform.isAndroid
  //     ? 'http://192.168.0.144:5000/api/v1' // <-- ⚠️ ĐẢM BẢO IP NÀY ĐÚNG
  //     : 'http://localhost:5000/api/v1';

  final String _baseUrl = 'http://103.186.100.42:5000/api/v1';

  final GetStorage _storage = GetStorage();

  // Hàm chính để lấy sản phẩm với bộ lọc
  Future<List<Product>> getProducts(
      {required String category, String? brand, double? minPrice, double? maxPrice}) async {

    // 1. Lấy token đã lưu
    final token = _storage.read('apiToken');
    if (token == null) {
      debugPrint("--- ProductService(getProducts): Lỗi: Không tìm thấy apiToken.");
      throw Exception('Người dùng chưa đăng nhập. Không tìm thấy token.');
    }

    // 2. Xây dựng URL (Giữ nguyên)
    final queryParams = <String, String>{ 'category': category, };
    if (brand != null && brand != 'All') { queryParams['brand'] = brand; }
    if (minPrice != null) { queryParams['minPrice'] = minPrice.toString(); }
    if (maxPrice != null) { queryParams['maxPrice'] = maxPrice.toString(); }
    final uri = Uri.parse('$_baseUrl/products').replace(queryParameters: queryParams);

    // --- ✅ 2. THÊM LOG REQUEST ---
    debugPrint("--- ProductService: Đang gọi API getProducts ---");
    debugPrint("URL: $uri");
    debugPrint("Token: Bearer ${token.substring(0, 10)}...");
    // -----------------------------

    try {
      // 3. Gọi API với Header Authorization
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 4. Xử lý response
      if (response.statusCode == 200) {
        // --- ✅ 3. THÊM LOG SUCCESS ---
        debugPrint("--- ProductService: Phản hồi Thành Công (getProducts) ---");
        debugPrint("Status Code: ${response.statusCode}");
        // -----------------------------
        final data = jsonDecode(response.body);
        final List<dynamic> productListJson = data['products'];
        return productListJson.map((json) => Product.fromJson(json)).toList();
      } else {
        // --- ✅ 4. THÊM LOG LỖI API (4xx, 5xx) ---
        debugPrint("--- ProductService: Phản hồi Thất Bại (getProducts) ---");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        // -----------------------------
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Lấy sản phẩm thất bại');
      }
    } catch (e) {
      // --- ✅ 5. THÊM LOG LỖI KẾT NỐI (NETWORK) ---
      debugPrint("--- ProductService: Lỗi getProducts (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      // -----------------------------
      throw Exception('Không thể kết nối đến server: ${e.toString()}');
    }
  }

  // (Tùy chọn) Hàm lấy chi tiết 1 sản phẩm
  Future<Product> getProductById(String id) async {
    final token = _storage.read('apiToken');
    if (token == null) {
      debugPrint("--- ProductService(getProductById): Lỗi: Không tìm thấy apiToken.");
      throw Exception('Người dùng chưa đăng nhập.');
    }

    final uri = Uri.parse('$_baseUrl/products/$id');
    debugPrint("--- ProductService: Đang gọi API getProductById ---");
    debugPrint("URL: $uri");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("--- ProductService: Phản hồi Thành Công (getProductById) ---");
        return Product.fromJson(jsonDecode(response.body));
      } else {
        debugPrint("--- ProductService: Phản hồi Thất Bại (getProductById) ---");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Không tìm thấy sản phẩm');
      }
    } catch (e) {
      debugPrint("--- ProductService: Lỗi getProductById (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  // Hàm lấy danh sách Brands (cho filter)
  Future<List<String>> getBrands(String category) async {
    final token = _storage.read('apiToken');
    if (token == null) {
      debugPrint("--- ProductService(getBrands): Lỗi: Không tìm thấy apiToken.");
      throw Exception('Người dùng chưa đăng nhập.');
    }

    final queryParams = {'category': category};
    final uri = Uri.parse('$_baseUrl/products/brands')
        .replace(queryParameters: queryParams);

    debugPrint("--- ProductService: Đang gọi API getBrands ---");
    debugPrint("URL: $uri");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("--- ProductService: Phản hồi Thành Công (getBrands) ---");
        final List<dynamic> brandListJson = jsonDecode(response.body);
        return brandListJson.map((brand) => brand.toString()).toList();
      } else {
        debugPrint("--- ProductService: Phản hồi Thất Bại (getBrands) ---");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Lấy brands thất bại');
      }
    } catch (e) {
      debugPrint("--- ProductService: Lỗi getBrands (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      throw Exception('Không thể kết nối đến server: ${e.toString()}');
    }
  }
}