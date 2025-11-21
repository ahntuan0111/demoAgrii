/// Add this new class for suggestion data
class SuggestionData {
  final List<dynamic> products;
  final List<dynamic> stores;
  final List<dynamic> farmers;
  final List<dynamic> callCenter;

  SuggestionData({
    required this.products,
    required this.stores,
    required this.farmers,
    required this.callCenter,
  });

  factory SuggestionData.fromJson(Map<String, dynamic> json) {
    return SuggestionData(
      products: json['products'] as List<dynamic>? ?? [],
      stores: json['stores'] as List<dynamic>? ?? [],
      farmers: json['farmers'] as List<dynamic>? ?? [],
      callCenter: json['call_center'] as List<dynamic>? ?? [],
    );
  }
}
