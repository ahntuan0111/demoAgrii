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
