// services/user_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart' show GetStorage;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../models/nearest_partner_model.dart'; // Import LatLng

class UserService extends GetxService {
  final String _baseUrl = kIsWeb
      ? 'http://localhost:5000/api/v1'  // Web dùng localhost
      : (Platform.isAndroid
      ? 'http://192.168.0.144:5000/api/v1' // Android Device dùng IP LAN
      : 'http://localhost:5000/api/v1');

  final GetStorage _storage = GetStorage();

  // --- Hàm helper lấy token (giống các service khác) ---
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

  // --- HÀM MỚI ĐỂ GỌI API PUT /users/me/location ---
  Future<void> updateUserLocation(LatLng position) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/users/me/location'); // <-- API MỚI

    try {
      final response = await http.put( // <-- Dùng http.PUT
        uri,
        headers: headers,
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      // Xử lý phản hồi
      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Cập nhật vị trí thất bại');
      }
      // Nếu thành công (200 OK)
      debugPrint("Cập nhật vị trí lên BE thành công!");

    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  /// Lấy danh sách Quản lý (Lão/Tráng Nông) gần nhất
  Future<List<NearestPartner>> getNearestManagers() async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/users/nearest-managers');
    try {
      final response = await http.get(uri, headers: headers);
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return nearestPartnerFromJson(response.body);
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  /// Lấy danh sách Cửa hàng (VTNN) gần nhất
  Future<List<NearestPartner>> getNearestStores() async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/users/nearest-stores');
    try {
      final response = await http.get(uri, headers: headers);
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return nearestPartnerFromJson(response.body);
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  /// (Customer) Chọn một Quản lý (Lão/Tráng Nông)
  Future<void> selectManager(String managerId) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/users/me/select-manager');
    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({'managerId': managerId}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(body['message']);
      }
      debugPrint("Chọn Quản lý thành công!");
    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  /// (Customer) Chọn một Cửa hàng (VTNN)
  Future<void> selectStore(String storeId) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/users/me/select-store');
    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({'storeId': storeId}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(body['message']);
      }
      debugPrint("Chọn Cửa hàng thành công!");
    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

}