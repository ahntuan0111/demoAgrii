class Address {
  String street; // Số nhà, đường
  String ward; // Xã, Phường
  String district; // Huyện, Quận
  String province; // Tỉnh, Thành phố

  Address({
    required this.street,
    required this.ward,
    required this.district,
    required this.province,
  });

  // Method to format the address for display
  @override
  String toString() {
    // Return empty string if all fields are empty to avoid weird commas
    if (street.isEmpty && ward.isEmpty && district.isEmpty && province.isEmpty) {
      return "Chưa có địa chỉ";
    }
    // Join non-empty parts with ", "
    return [street, ward, district, province].where((s) => s.isNotEmpty).join(', ');
  }

// Optional: Add toJson/fromJson for API calls
}