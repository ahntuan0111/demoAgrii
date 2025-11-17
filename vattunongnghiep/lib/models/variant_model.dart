class Variant {
  final String name; // Ví dụ: "Gói 25 kg"
  final double price; // Ví dụ: 120000
  final int quantity; // Ví dụ: 100

  Variant({
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Hàm để parse JSON (đọc từ mảng 'variants' của Product)
  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
    name: json["name"],
    price: json["price"].toDouble(),
    quantity: json["quantity"],
  );
}