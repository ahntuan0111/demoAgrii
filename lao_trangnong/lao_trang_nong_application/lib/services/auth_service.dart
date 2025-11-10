import 'dart:convert';
import 'dart:io'; // Dùng để kiểm tra nền tảng
import 'package:flutter/foundation.dart'; // <-- 1. IMPORT ĐỂ DÙNG DEBUGPRINT
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class AuthService extends GetxService {
  final String _baseUrl = Platform.isAndroid
      ? 'http://192.168.0.144:5000/api/v1' // Port 5000 của Node.js
      : 'http://localhost:5000/api/v1';

  final _headers = {'Content-Type': 'application/json'};

  /// [API Đăng ký] - Gọi POST /api/v1/auth/register
  Future<Map<String, dynamic>> register(
      String fullName, String username, String password, String phoneNumber) async {

    final url = Uri.parse('$_baseUrl/auth/register');
    final body = jsonEncode({
      'fullName': fullName,
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
    });

    // --- 2. THÊM LOG ---
    debugPrint("--- AuthService: Gọi API Đăng Ký ---");
    debugPrint("URL: $url");
    debugPrint("Request Body: $body");
    // --------------------

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );
      // 3. Giao cho _handleResponse xử lý log
      return _handleResponse(response);
    } catch (e) {
      // 4. THÊM LOG LỖI MẠNG/KẾT NỐI
      debugPrint("--- AuthService: Lỗi Đăng Ký (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  /// [API Đăng nhập] - Gọi POST /api/v1/auth/login
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    debugPrint("--- AuthService: Gọi API Đăng Nhập ---");
    debugPrint("URL: $url");
    debugPrint("Request Body: $body");

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint("--- AuthService: Lỗi Đăng Nhập (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  /// [API Đăng nhập/Đăng ký bằng SĐT] - Gọi POST /api/v1/auth/phone
  Future<Map<String, dynamic>> loginOrRegisterWithPhoneToken(
      String firebaseToken) async {
    final url = Uri.parse('$_baseUrl/auth/phone');
    final body = jsonEncode({'token': firebaseToken});

    debugPrint("--- AuthService: Gọi API Xác thực SĐT ---");
    debugPrint("URL: $url");
    // (Không nên log 'body' ở đây vì nó chứa token nhạy cảm)

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint("--- AuthService: Lỗi Xác thực SĐT (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  /// Hàm xử lý response chung (ĐÃ THÊM LOG CHI TIẾT)
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // --- LOG THÀNH CÔNG ---
      debugPrint("--- AuthService: Phản hồi Thành Công ---");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      // ----------------------
      return body;
    } else {
      // --- LOG THẤT BẠI (4xx, 5xx) ---
      debugPrint("--- AuthService: Phản hồi Thất Bại ---");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      // ---------------------------
      throw Exception(body['message'] ?? 'Đã xảy ra lỗi không xác định');
    }
  }
}