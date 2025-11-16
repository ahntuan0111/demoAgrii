// services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // Cho debugPrint

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Tải 1 file (File) lên 1 đường dẫn (path) trên Firebase Storage
  /// và trả về Download URL (String)
  Future<String> uploadFile(File file, String path) async {
    try {
      debugPrint("StorageService: Bắt đầu tải file lên $path...");
      final ref = _storage.ref(path);
      final uploadTask = ref.putFile(file);

      // Chờ tải lên hoàn tất
      final snapshot = await uploadTask;

      // Lấy URL để tải về
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint("StorageService: Tải file thành công. URL: $downloadUrl");
      return downloadUrl;

    } catch (e) {
      debugPrint("StorageService: Lỗi khi tải file: $e");
      throw Exception('Lỗi tải ảnh lên: $e');
    }
  }
}