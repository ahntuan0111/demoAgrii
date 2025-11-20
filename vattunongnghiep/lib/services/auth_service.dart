import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class AuthService extends GetxService {
  // URL Server của bạn
  final String _baseUrl = 'http://103.186.100.42:5000/api/v1';

  final _headers = {'Content-Type': 'application/json'};

  /// [API Đăng ký] - Thêm timeout 15 giây
  Future<Map<String, dynamic>> register(
      String fullName, String username, String password, String phoneNumber) async {

    final url = Uri.parse('$_baseUrl/auth/register');
    final body = jsonEncode({
      'fullName': fullName,
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
    });

    debugPrint("--- AuthService: Gọi API Đăng Ký ---");
    debugPrint("URL: $url");

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      ).timeout(const Duration(seconds: 15)); // <--- QUAN TRỌNG: Tự ngắt sau 15s

      return _handleResponse(response);
    } catch (e) {
      debugPrint("--- AuthService: Lỗi Đăng Ký ---");
      debugPrint("Lỗi: $e");
      // Ném lỗi ra để Controller bắt được và tắt loading
      throw Exception('Lỗi kết nối: Không thể gọi đến server ($e)');
    }
  }

  /// [API Đăng nhập]
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// [API Đăng nhập/Đăng ký bằng SĐT]
  Future<Map<String, dynamic>> loginOrRegisterWithPhoneToken(String firebaseToken) async {
    final url = Uri.parse('$_baseUrl/auth/phone');
    final body = jsonEncode({'token': firebaseToken});

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Hàm xử lý response chung
  Map<String, dynamic> _handleResponse(http.Response response) {
    // Log chi tiết để debug
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Lỗi không xác định (${response.statusCode})');
    }
  }
}