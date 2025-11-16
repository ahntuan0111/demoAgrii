// services/user_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart' show GetStorage;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart'; // Import LatLng

class UserService extends GetxService {
  final String _baseUrl = Platform.isAndroid
      ? 'http://192.168.0.144:5000/api/v1'
      : 'http://localhost:5000/api/v1';

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

  Future<void> submitKyc(String frontUrl, String backUrl, String selfieUrl) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/users/me/kyc'); // <-- API BE đã tạo

    debugPrint("UserService: Đang gửi KYC lên BE...");

    try {
      final response = await http.put( // Dùng http.PUT
        uri,
        headers: headers,
        body: jsonEncode({
          'nationalIdFrontUrl': frontUrl,
          'nationalIdBackUrl': backUrl,
          'selfieUrl': selfieUrl,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Gửi KYC thất bại');
      }

      debugPrint("UserService: Gửi KYC thành công!");
      // Trả về (không cần, vì controller đã xử lý)

    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }

  Future<void> updateManagerProfile({
    required String operatingArea,
    required List<String> mainCrops,
    required String address,
  }) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/users/me/manager-profile'); // <-- API BE đã tạo

    debugPrint("UserService: Đang cập nhật hồ sơ Manager...");

    try {
      final response = await http.put( // Dùng http.PUT
        uri,
        headers: headers,
        body: jsonEncode({
          'operatingArea': operatingArea,
          'mainCrops': mainCrops,
          'address': address,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Cập nhật hồ sơ thất bại');
      }

      debugPrint("UserService: Cập nhật hồ sơ thành công!");
      // (Lưu lại user mới nếu cần)
      // final GetStorage _storage = GetStorage();
      // await _storage.write('user', body['user']);

    } catch (e) {
      throw Exception('Không thể kết nối: ${e.toString()}');
    }
  }
}