class ChatResponse {
  final String answer;
  final Map<String, dynamic> keywords;
  final List<CsvResult> csvResults;
  final String modelUsed;
  final int totalFound;

  ChatResponse({
    required this.answer,
    required this.keywords,
    required this.csvResults,
    required this.modelUsed,
    required this.totalFound,
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
