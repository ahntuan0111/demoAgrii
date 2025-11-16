// models/product_model.dart (ĐÃ CẬP NHẬT HOÀN CHỈNH)
import 'dart:convert';

import 'package:vattunongnghiep_app/models/product_detail_model.dart';
import 'package:vattunongnghiep_app/models/variant_model.dart';

List<Product> productListFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

Product productFromJson(String str) => Product.fromJson(json.decode(str));

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final double price; // Đây là giá "hiển thị" (thường là giá thấp nhất)
  final String category;
  final String brand;
  final String status;
  final String? videoUrl;
  final List<Variant> variants; // <-- 1. THAY ĐỔI LỚN

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.price, // Giá hiển thị
    required this.category,
    required this.brand,
    required this.status,
    this.videoUrl,
    required this.variants, // <-- 2. THÊM VÀO CONSTRUCTOR
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    name: json["name"],
    description: json["description"],
    images: List<String>.from(json["images"].map((x) => x)),
    price: json["price"].toDouble(), // Giá hiển thị
    category: json["category"],
    brand: json["brand"],
    status: json["status"],
    videoUrl: json["videoUrl"],
    // 3. ĐỌC MẢNG 'variants'
    variants: json["variants"] == null
        ? []
        : List<Variant>.from(
        json["variants"].map((x) => Variant.fromJson(x))),
  );

  // --- 4. (PHẦN BỊ THIẾU) HÀM CẦU NỐI (BRIDGE) ---
  // Chuyển đổi Product (từ BE) sang ProductDetail (mà màn hình Detail đang dùng)
  ProductDetail toProductDetail() {
    // Tách description và safetyInfo
    String desc = description;
    String safety = "Thông tin an toàn không có sẵn.";
    if (description.contains("\n\nThông tin an toàn:")) {
      var parts = description.split("\n\nThông tin an toàn:");
      desc = parts[0];
      safety = parts[1].trim();
    }

    // Lấy danh sách tên package từ variants
    List<String> packageNames = variants.map((v) => v.name).toList();

    return ProductDetail(
      // Dùng ảnh đầu tiên trong danh sách
      image: images.isNotEmpty ? images[0] : 'assets/images/placeholder.png',
      title: name,
      subtitle: brand,
      description: desc,
      // 'originalPrice' không có trong BE, ta tạm fake
      originalPrice: price + 5000,
      // Dùng giá 'price' (giá hiển thị chung) từ BE
      price: price,
      safetyInfo: safety,
      // Dùng danh sách tên package (Gói 25kg, 50kg...) từ variants
      packageOptions: packageNames,
      // 'discountText' không có trong BE, ta tạm fake
      discountText: "Giảm 10%",
      // Dùng videoUrl thật từ BE (có thể null)
      videoUrl: videoUrl,
    );
  }
}