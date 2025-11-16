// services/auth_service.dart (DÀNH CHO APP VTNN)
import 'dart:convert';
import 'dart:io'; // Dùng để kiểm tra nền tảng
import 'package:flutter/foundation.dart'; // <-- 1. IMPORT ĐỂ DÙNG DEBUGPRINT
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class AuthService extends GetxService {
  final String _baseUrl = Platform.isAndroid
      ? 'http://192.168.0.144:5000/api/v1' // <-- ⚠️ Đảm bảo IP LAN của bạn đúng
      : 'http://localhost:5000/api/v1';

  final _headers = {'Content-Type': 'application/json'};

  /// [API Đăng ký] - Gọi POST /api/v1/auth/register/store
  Future<Map<String, dynamic>> register(
      String fullName, String username, String password, String phoneNumber) async {

    // --- ✅ 1. SỬA ĐƯỜNG DẪN API ---
    final url = Uri.parse('$_baseUrl/auth/register/store');
    // ----------------------------

    final body = jsonEncode({
      'fullName': fullName, // (Đây sẽ là Tên Cửa Hàng)
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
    });

    debugPrint("--- AuthService (VTNN): Gọi API Đăng Ký ---");
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
      debugPrint("--- AuthService (VTNN): Lỗi Đăng Ký (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  /// [API Đăng nhập] - Gọi POST /api/v1/auth/login
  /// (HÀM NÀY GIỮ NGUYÊN - DÙNG CHUNG)
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    debugPrint("--- AuthService (VTNN): Gọi API Đăng Nhập ---");
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
      debugPrint("--- AuthService (VTNN): Lỗi Đăng Nhập (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  /// [API Đăng nhập/Đăng ký bằng SĐT] - Gọi POST /api/v1/auth/phone/store
  Future<Map<String, dynamic>> loginOrRegisterWithPhoneToken(
      String firebaseToken) async {

    // --- ✅ 2. SỬA ĐƯỜNG DẪN API ---
    final url = Uri.parse('$_baseUrl/auth/phone/store');
    // ----------------------------

    // (BE của VTNN không cần 'reportsTo', nên chỉ cần 'token')
    final body = jsonEncode({'token': firebaseToken});

    debugPrint("--- AuthService (VTNN): Gọi API Xác thực SĐT ---");
    debugPrint("URL: $url");

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint("--- AuthService (VTNN): Lỗi Xác thực SĐT (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  /// Hàm xử lý response chung (Giữ nguyên)
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("--- AuthService: Phản hồi Thành Công ---");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      return body;
    } else {
      debugPrint("--- AuthService: Phản hồi Thất Bại ---");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      throw Exception(body['message'] ?? 'Đã xảy ra lỗi không xác định');
    }
  }
}