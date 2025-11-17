import 'dart:convert';

import 'geolocation_model.dart';


// Hàm helper để parse danh sách JSON
List<NearestPartner> nearestPartnerFromJson(String str) =>
    List<NearestPartner>.from(
        json.decode(str).map((x) => NearestPartner.fromJson(x)));

class NearestPartner {
  final String id;
  final String name;
  final GeoLocation location;
  final double distance; // Khoảng cách (đã tính bằng km)
  final String? role; // Sẽ là 'laonong' hoặc 'trangnong' (nếu là manager)
  final String? phoneNumber; // Sẽ có nếu là 'vtnn'

  NearestPartner({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    this.role,
    this.phoneNumber,
  });

  factory NearestPartner.fromJson(Map<String, dynamic> json) =>
      NearestPartner(
        id: json["_id"],
        name: json["name"],
        location: GeoLocation.fromJson(json["location"]),
        distance: json["distance"].toDouble(),
        role: json["role"], // Sẽ là null nếu là VTNN
        phoneNumber: json["phoneNumber"], // Sẽ là null nếu là Manager
      );
}