import 'dart:convert';
import 'dart:io' show Platform, SocketException;
import 'dart:async' show TimeoutException;

import 'package:agri_flutter/models/chat_response_model.dart';
import 'package:agri_flutter/models/csv_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Backend URL - automatically adjusts for Android emulator
  static String get baseUrl {
    // For Android emulator, use 10.0.2.2 to access host machine's localhost
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    // For web, iOS, and other platforms
    return 'http://localhost:3000';
  }

  /// Health check - verify backend is running
  static Future<bool> checkHealth() async {
    try {
      print('Health check URL: $baseUrl');
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  /// Send chat message and get AI response
  static Future<ChatResponse> sendChat(
    String prompt, {
    Map<String, dynamic>? location,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat');
      print('Sending request to: $url');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt, 'location': location ?? {}}),
          )
          .timeout(
            const Duration(seconds: 60), // Tăng timeout lên 60 giây
            onTimeout: () {
              throw Exception('Timeout: Server không phản hồi sau 60 giây');
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          print('Parsed data: $data');
          return ChatResponse.fromJson(data);
        } catch (parseError) {
          print('Error parsing response: $parseError');
          throw Exception('Failed to parse response: $parseError');
        }
      } else {
        // Try to parse error response
        try {
          final error = jsonDecode(utf8.decode(response.bodyBytes));
          throw Exception(
            'Server error ${response.statusCode}: ${error['message'] ?? 'Unknown error'}',
          );
        } catch (e) {
          // If we can't parse the error response, throw a generic one
          throw Exception(
            'Server error ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
      }
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception(
        'Không thể kết nối Backend tại $baseUrl. Vui lòng kiểm tra server đang chạy.',
      );
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
        'Không thể kết nối mạng. Vui lòng kiểm tra kết nối internet.',
      );
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception(
        'Timeout: Server không phản hồi. Vui lòng kiểm tra server.',
      );
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// Extract keywords only
  static Future<Map<String, dynamic>> extractKeywords(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/keywords'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to extract keywords');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Search data based on prompt
  static Future<Map<String, dynamic>> searchData(String prompt) async {
    try {
      final url = Uri.parse('$baseUrl/chat/search');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to search data');
      }
    } catch (e) {
      throw Exception('Error searching data: $e');
    }
  }

  /// Search data by keywords
  static Future<Map<String, dynamic>> searchByKeywords(
    Map<String, dynamic> keywords,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/chat/search-by-keywords');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'keywords': keywords}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to search by keywords');
      }
    } catch (e) {
      throw Exception('Error searching by keywords: $e');
    }
  }

  /// Analyze plant disease from image
  static Future<Map<String, dynamic>> analyzePlantImage(
    String base64Image,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/chat/image');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image': base64Image}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['message'] ?? 'Failed to analyze plant image');
      }
    } catch (e) {
      throw Exception('Error analyzing plant image: $e');
    }
  }

  /// Send file for processing
  static Future<ChatResponse> processFile(
    String fileName,
    String base64Content,
    String fileType, {
    String? prompt, // Add optional prompt parameter
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat/file');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fileName': fileName,
              'fileContent': base64Content,
              'fileType': fileType,
              'prompt': prompt, // Include prompt if provided
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return ChatResponse.fromJson(data);
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['message'] ?? 'Failed to process file');
      }
    } catch (e) {
      throw Exception('Error processing file: $e');
    }
  }

  /// Save suggestion data
  static Future<Map<String, dynamic>> saveSuggestion(
    CsvResult suggestion,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/chat/save-suggestion');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'crop': suggestion.crop,
              'disease': suggestion.disease,
              'product': suggestion.product,
              'location': suggestion.location,
              'farmer_role': suggestion.farmerRole,
              'action': suggestion.action,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to save suggestion');
      }
    } catch (e) {
      throw Exception('Error saving suggestion: $e');
    }
  }

  /// Get all suggestions
  static Future<Map<String, dynamic>> getAllSuggestions() async {
    try {
      final url = Uri.parse('$baseUrl/chat/get-suggestions');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to get suggestions');
      }
    } catch (e) {
      throw Exception('Error getting suggestions: $e');
    }
  }

  /// Get all farmers
  static Future<Map<String, dynamic>> getAllFarmers() async {
    try {
      final url = Uri.parse('$baseUrl/chat/farmers');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to get farmers');
      }
    } catch (e) {
      throw Exception('Error getting farmers: $e');
    }
  }

  /// Get all stores
  static Future<Map<String, dynamic>> getAllStores() async {
    try {
      final url = Uri.parse('$baseUrl/chat/stores');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to get stores');
      }
    } catch (e) {
      throw Exception('Error getting stores: $e');
    }
  }

  /// Create a new product with keywords
  static Future<Map<String, dynamic>> createProductWithKeywords(
    String name,
    String crop,
    String disease,
    String action,
    List<String> keywords,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/chat/create-product');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'ten_sp': name,
              'cay_trong': crop,
              'benh_lien_quan': disease,
              'action': action,
              'keywords': keywords,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  /// Search products by keywords
  static Future<Map<String, dynamic>> searchProductsByKeywords(
    List<String> keywords, {
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat/search-products-by-keywords');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'keywords': keywords, 'limit': limit}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to search products by keywords');
      }
    } catch (e) {
      throw Exception('Error searching products by keywords: $e');
    }
  }

  /// Find similar products by keywords
  static Future<Map<String, dynamic>> findSimilarProductsByKeywords(
    List<String> keywords, {
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat/find-similar-products');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'keywords': keywords, 'limit': limit}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to find similar products by keywords');
      }
    } catch (e) {
      throw Exception('Error finding similar products by keywords: $e');
    }
  }

  /// Process voice data and convert to text
  static Future<Map<String, dynamic>> processVoice(String base64Voice) async {
    try {
      final url = Uri.parse('$baseUrl/chat/voice');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'voice': base64Voice}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['message'] ?? 'Failed to process voice');
      }
    } catch (e) {
      throw Exception('Error processing voice: $e');
    }
  }
}
