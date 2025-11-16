class GeoLocation {
  final String type;
  final double longitude;
  final double latitude;

  GeoLocation({
    required this.type,
    required this.longitude,
    required this.latitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    // Lấy list coordinates một cách an toàn
    final List<dynamic> coords = json["coordinates"] ?? [];

    // --- ✅ SỬA LỖI TẠI ĐÂY ---
    // Khởi tạo tọa độ mặc định
    double lon = 0.0;
    double lat = 0.0;

    // Chỉ đọc [0] và [1] NẾU mảng có đủ 2 phần tử
    if (coords.length >= 2) {
      lon = (coords[0] ?? 0.0).toDouble();
      lat = (coords[1] ?? 0.0).toDouble();
    }
    // ------------------------

    return GeoLocation(
      type: json["type"] ?? "Point",
      longitude: lon,
      latitude: lat,
    );
  }
}