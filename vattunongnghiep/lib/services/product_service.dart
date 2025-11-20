// services/product_service.dart (BẢN CHỈNH SỬA CHO APP NÔNG DÂN)
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:agri_flutter/models/product_model.dart';
import 'package:agri_flutter/models/store_product_model.dart'; // <-- 1. IMPORT MODEL MỚI
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ProductService extends GetxService {
  final String _baseUrl = 'http://103.186.100.42:5000/api/v1';

  final GetStorage _storage = GetStorage();

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

  // --- ✅ 2. HÀM NÀY ĐÃ ĐƯỢC VIẾT LẠI HOÀN TOÀN ---
  /// Lấy danh sách sản phẩm TỪ KHO CỦA VTNN MÀ CUSTOMER ĐÃ CHỌN
  Future<List<StoreProduct>> getStoreProducts() async {
    final headers = await _getAuthHeaders();

    // API BE này tự động tìm VTNN (preferredStore) của user
    final uri = Uri.parse('$_baseUrl/inventory/customer-store');

    debugPrint("--- ProductService (Customer): Đang gọi API getStoreProducts ---");
    debugPrint("URL: $uri");

    try {
      final response = await http.get(uri, headers: headers);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint("--- ProductService (Customer): Lấy kho VTNN thành công ---");
        // API trả về [ { _id, store, product: {...}, price, quantity }, ... ]
        // Dùng model mới để parse
        return storeProductListFromJson(response.body);
      } else {
        debugPrint("--- ProductService (Customer): Lỗi: ${response.body} ---");
        throw Exception(body['message'] ?? 'Lấy sản phẩm thất bại');
      }
    } catch (e) {
      debugPrint("--- ProductService (Customer): Lỗi Catch: ${e.toString()} ---");
      throw Exception('Không thể kết nối đến server: ${e.toString()}');
    }
  }
  // ------------------------------------------

  // (Hàm getProductById và getBrands giữ nguyên,
  //  vì chúng vẫn gọi API /products... để lấy thông tin chung)

  // (Tùy chọn) Hàm lấy chi tiết 1 sản phẩm GỐC
  Future<Product> getProductById(String id) async {
    final token = _storage.read('apiToken');
    if (token == null) throw Exception('Người dùng chưa đăng nhập.');

    final uri = Uri.parse('$_baseUrl/products/$id');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Không tìm thấy sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  // (Tùy chọn) Lấy danh sách brand GỐC
  Future<List<String>> getBrands(String category) async {
    final token = _storage.read('apiToken');
    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập.');
    }

    final queryParams = {'category': category};
    final uri = Uri.parse('$_baseUrl/products/brands')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> brandListJson = jsonDecode(response.body);
        return brandListJson.map((brand) => brand.toString()).toList();
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Lấy brands thất bại');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: ${e.toString()}');
    }
  }
}