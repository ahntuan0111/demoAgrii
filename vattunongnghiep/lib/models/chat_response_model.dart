import 'package:agri_flutter/models/csv_model.dart';

/// Chat Response Model
class ChatResponse {
  final String answer;
  final Map<String, dynamic> keywords;
  final List<CsvResult> csvResults;
  final String modelUsed;
  final int totalFound;
  final bool showSuggestions;
  final Map<String, dynamic>? suggestions; // Add this line

  ChatResponse({
    required this.answer,
    required this.keywords,
    required this.csvResults,
    required this.modelUsed,
    required this.totalFound,
    this.showSuggestions = false,
    this.suggestions, // Add this line
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
      showSuggestions: (json['showSuggestions'] is bool)
          ? (json['showSuggestions'] as bool)
          : (json['showSuggestions'] == true ||
                (json['showSuggestions'] is String &&
                    json['showSuggestions'].toString().toLowerCase() ==
                        'true') ||
                false),
      suggestions: json['suggestions'] != null
          ? Map<String, dynamic>.from(json['suggestions'] as Map)
          : null, // Add this line
    );
  }
}
