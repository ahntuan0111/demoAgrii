import '../services/chatbox_ai_service.dart';

class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? keywords;
  final int? csvResultsCount;
  final List<CsvResult>? csvResults; // Store actual CSV results
  final Map<String, dynamic>? fileInfo; // New field for file information
  final bool showSuggestions; // New field for showing suggestions button

  Message({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.keywords,
    this.csvResultsCount,
    this.csvResults,
    this.fileInfo, // Add fileInfo parameter
    this.showSuggestions = false, // Add showSuggestions parameter
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'keywords': keywords,
      'csvResultsCount': csvResultsCount,
      'csvResults': csvResults?.map((result) => result.toJson()).toList(),
      'fileInfo': fileInfo, // Add fileInfo to JSON
      'showSuggestions': showSuggestions, // Add showSuggestions to JSON
    };
  }

  // Create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      keywords: json['keywords'] != null
          ? Map<String, dynamic>.from(json['keywords'] as Map)
          : null,
      csvResultsCount: json['csvResultsCount'] as int?,
      csvResults: json['csvResults'] != null
          ? (json['csvResults'] as List)
          .map((item) => CsvResult.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
      fileInfo: json['fileInfo'] != null
          ? Map<String, dynamic>.from(json['fileInfo'] as Map)
          : null, // Add fileInfo from JSON
      showSuggestions:
      json['showSuggestions'] as bool? ??
          false, // Add showSuggestions from JSON
    );
  }
}
