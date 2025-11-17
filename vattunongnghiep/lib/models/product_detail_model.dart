
class ProductDetail {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final double price;
  final double? originalPrice;
  final String? discountText;
  final List<String> packageOptions;
  final String safetyInfo;
  final String? availabilityInfo;
  final String? videoUrl;

  ProductDetail({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountText,
    this.packageOptions = const [],
    required this.safetyInfo,
    this.availabilityInfo,
    this.videoUrl,
  });
}