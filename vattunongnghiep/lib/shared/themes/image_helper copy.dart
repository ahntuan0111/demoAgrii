import 'package:flutter/material.dart';

class ImageHelper {
  // Disease images mapping
  static final Map<String, String> _diseaseImages = {
    'rầy nâu': 'assets/images/disease_ray_nau.jpg',
    'vàng lá': 'assets/images/disease_vang_la.jpg',
    'đạo ôn': 'assets/images/disease_dao_on.jpg',
    'bạc lá': 'assets/images/disease_bac_la.jpg',
    'chết chồi': 'assets/images/disease_chet_choi.jpg',
    'rệp sáp': 'assets/images/disease_rep_sap.jpg',
    'thối gốc': 'assets/images/disease_thoi_goc.jpg',
    'cháy lá': 'assets/images/disease_chay_la.jpg',
    'thối nải': 'assets/images/disease_thoi_nai.jpg',
    'rạn vỏ trái': 'assets/images/disease_ran_vo_trai.jpg',
    'bọ trĩ': 'assets/images/disease_bo_tri.jpg',
    'chổi rồng': 'assets/images/disease_choi_rong.jpg',
    'chậm lớn': 'assets/images/disease_cham_lon.jpg',
    'chết búp': 'assets/images/disease_chet_bup.jpg',
    'thối trái': 'assets/images/disease_thoi_trai.jpg',
    'mốc sương': 'assets/images/disease_moc_suong.jpg',
  };

  // Product images mapping
  static final Map<String, String> _productImages = {
    'phân npk': 'assets/images/product_phan_npk.jpg',
    'thuốc trừ sâu': 'assets/images/product_thuoc_tru_sau.jpg',
    'dầu neem': 'assets/images/product_dau_neem.jpg',
    'phân ure': 'assets/images/product_phan_ure.jpg',
    'phân kali': 'assets/images/product_phan_kali.jpg',
    'thuốc trừ nấm': 'assets/images/product_thuoc_tru_nam.jpg',
    'phân lân': 'assets/images/product_phan_lan.jpg',
    'phân hữu cơ': 'assets/images/product_phan_huu_co.jpg',
    'phân vi sinh': 'assets/images/product_phan_vi_sinh.jpg',
  };

  // Crop images mapping
  static final Map<String, String> _cropImages = {
    'lúa': 'assets/images/crop_lua.jpg',
    'dừa': 'assets/images/crop_dua.jpg',
    'thơm': 'assets/images/crop_thom.jpg',
    'dứa': 'assets/images/crop_dua.jpg',
    'sầu riêng': 'assets/images/crop_sau_rieng.jpg',
    'bưởi': 'assets/images/crop_buoi.jpg',
    'cà chua': 'assets/images/crop_ca_chua.jpg',
    'rau cải': 'assets/images/crop_rau_cai.jpg',
    'ngô': 'assets/images/crop_ngo.jpg',
    'bắp cải': 'assets/images/crop_bap_cai.jpg',
    'ớt': 'assets/images/crop_ot.jpg',
    'cà tím': 'assets/images/crop_ca_tim.jpg',
    'dưa leo': 'assets/images/crop_dua_leo.jpg',
  };

  // Farmer specialty images mapping
  static final Map<String, String> _farmerSpecialtyImages = {
    'lúa': 'assets/images/farmer_lua.jpg',
    'dừa': 'assets/images/farmer_dua.jpg',
    // Using existing images as fallback for missing ones
    'thơm': 'assets/images/farmer_dua.jpg',
    'dứa': 'assets/images/farmer_dua.jpg',
    'sầu riêng': 'assets/images/farmer_lua.jpg', // Using lúa image as fallback
    'bưởi': 'assets/images/farmer_lua.jpg', // Using lúa image as fallback
  };

  /// Get disease image based on disease name
  static String getDiseaseImage(String diseaseName) {
    // Normalize the disease name for matching
    final normalizedDisease = diseaseName.toLowerCase().trim();

    // Try exact match first
    if (_diseaseImages.containsKey(normalizedDisease)) {
      return _diseaseImages[normalizedDisease]!;
    }

    // Try partial match
    for (final entry in _diseaseImages.entries) {
      if (normalizedDisease.contains(entry.key) ||
          entry.key.contains(normalizedDisease)) {
        return entry.value;
      }
    }

    // Return default placeholder if no match found
    return 'assets/images/disease_placeholder.png';
  }

  /// Get product image based on product name
  static String getProductImage(String productName) {
    // Normalize the product name for matching
    final normalizedProduct = productName.toLowerCase().trim();

    // Try exact match first
    if (_productImages.containsKey(normalizedProduct)) {
      return _productImages[normalizedProduct]!;
    }

    // Try partial match
    for (final entry in _productImages.entries) {
      if (normalizedProduct.contains(entry.key) ||
          entry.key.contains(normalizedProduct)) {
        return entry.value;
      }
    }

    // Return default placeholder if no match found
    return 'assets/images/product_placeholder.png';
  }

  /// Get crop image based on crop name
  static String getCropImage(String cropName) {
    // Normalize the crop name for matching
    final normalizedCrop = cropName.toLowerCase().trim();

    // Try exact match first
    if (_cropImages.containsKey(normalizedCrop)) {
      return _cropImages[normalizedCrop]!;
    }

    // Try partial match
    for (final entry in _cropImages.entries) {
      if (normalizedCrop.contains(entry.key) ||
          entry.key.contains(normalizedCrop)) {
        return entry.value;
      }
    }

    // Return default placeholder if no match found
    return 'assets/images/product_placeholder.png';
  }

  /// Get farmer image based on specialty
  static String getFarmerImage(String specialty) {
    // Normalize the specialty for matching
    final normalizedSpecialty = specialty.toLowerCase().trim();

    // Try exact match first
    if (_farmerSpecialtyImages.containsKey(normalizedSpecialty)) {
      return _farmerSpecialtyImages[normalizedSpecialty]!;
    }

    // Try partial match
    for (final entry in _farmerSpecialtyImages.entries) {
      if (normalizedSpecialty.contains(entry.key) ||
          entry.key.contains(normalizedSpecialty)) {
        return entry.value;
      }
    }

    // Return default placeholder if no match found
    return 'assets/images/farmer_placeholder.png';
  }

  /// Get image widget with error handling
  static Widget buildImageWidget({
    required String imagePath,
    required double width,
    required double height,
    BorderRadius? borderRadius,
    BoxFit fit = BoxFit.cover,
    IconData placeholderIcon = Icons.image_not_supported,
    Color? placeholderColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Icon(
                placeholderIcon,
                size: width * 0.5,
                color: placeholderColor ?? Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}
