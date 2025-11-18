import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/chat_response_model.dart'; // dùng CsvResult từ đây

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

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return ChatResponse.fromJson(data);
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['message'] ?? 'Failed to get AI response');
      }
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception(
        'Không thể kết nối Backend tại $baseUrl. Vui lòng kiểm tra server đang chạy.',
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

  /// Send image data for plant disease analysis
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
        throw Exception('Failed to analyze plant image');
      }
    } catch (e) {
      throw Exception('Error analyzing plant image: $e');
    }
  }

  /// Send voice data for processing
  static Future<Map<String, dynamic>> processVoice(String voiceData) async {
    try {
      final url = Uri.parse('$baseUrl/chat/voice');
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'voice': voiceData}),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to process voice data');
      }
    } catch (e) {
      throw Exception('Error processing voice data: $e');
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
}

/// Chat Response Model
class ChatResponse {
  final String answer;
  final Map<String, dynamic> keywords;
  final List<CsvResult> csvResults;
  final String modelUsed;
  final int totalFound;
  final bool showSuggestions;

  ChatResponse({
    required this.answer,
    required this.keywords,
    required this.csvResults,
    required this.modelUsed,
    required this.totalFound,
    this.showSuggestions = false,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answer: json['answer'] ?? '',
      keywords: json['keywords'] ?? {},
      csvResults:
      (json['csvResults'] as List?)
          ?.map((item) => CsvResult.fromJson(item))
          .toList() ??
          [],
      modelUsed: json['modelUsed'] ?? 'unknown',
      totalFound: json['totalFound'] ?? 0,
      showSuggestions: json['showSuggestions'] ?? false,
    );
  }
}

/// CSV Result Model
class CsvResult {
  final String crop;
  final String disease;
  final String product;
  final String location;
  final String farmerRole;
  final String action;

  CsvResult({
    required this.crop,
    required this.disease,
    required this.product,
    required this.location,
    required this.farmerRole,
    required this.action,
  });

  factory CsvResult.fromJson(Map<String, dynamic> json) {
    return CsvResult(
      crop: json['crop'] ?? '',
      disease: json['disease'] ?? '',
      product: json['product'] ?? '',
      location: json['location'] ?? '',
      farmerRole: json['farmer_role'] ?? '',
      action: json['action'] ?? '',
    );
  }

  // Convert CsvResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'disease': disease,
      'product': product,
      'location': location,
      'farmer_role': farmerRole,
      'action': action,
    };
  }
}
