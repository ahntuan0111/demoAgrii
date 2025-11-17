class GeoLocation {
  final String type;
  final double longitude;
  final double latitude;

  GeoLocation({
    required this.type,
    required this.longitude,
    required this.latitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
    type: json["type"],
    // BE trả về [longitude, latitude]
    longitude: json["coordinates"][0].toDouble(),
    latitude: json["coordinates"][1].toDouble(),
  );
}