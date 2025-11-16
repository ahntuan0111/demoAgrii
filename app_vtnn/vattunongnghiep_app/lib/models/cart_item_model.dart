
class CartItem {
  final String id; // Đây là _id của item TRONG GIỎ HÀNG
  final String productId; // Đây là _id của SẢN PHẨM
  final String image;
  final String name;
  final String variantName; // (description cũ của bạn)
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.image,
    required this.name,
    required this.variantName,
    required this.price,
    required this.quantity,
  });

  // --- THÊM HÀM FACTORY NÀY VÀO ---
  // Hàm này "dịch" JSON từ API (Node.js) sang object CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      // MongoDB trả về "_id", chúng ta gán nó vào "id"
      id: json["_id"],

      // productId có thể là một String hoặc một Object (tùy vào cách populate)
      // Chúng ta sẽ xử lý cả hai
      productId: (json["productId"] is Map)
          ? json["productId"]["_id"]
          : json["productId"],

      image: json["image"],
      name: json["name"],
      variantName: json["variantName"],
      price: json["price"].toDouble(),
      quantity: json["quantity"],
    );
  }
// ------------------------------------
}