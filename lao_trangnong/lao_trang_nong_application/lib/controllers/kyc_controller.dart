// controllers/kyc_controller.dart (ĐÃ SỬA LỖI)
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart'; // Cần để lấy User ID

class KycController extends GetxController {
  // 1. Inject các service
  final StorageService _storageService = Get.find<StorageService>();
  final UserService _userService = Get.find<UserService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // <-- Đã có
  final ImagePicker _picker = ImagePicker();
  final GetStorage _storage = GetStorage();

  // 3. State cho UI (Giữ nguyên)
  final isLoading = false.obs;
  final idFrontImage = Rxn<File>();
  final idBackImage = Rxn<File>();
  final selfieImage = Rxn<File>();

  // --- CÁC HÀM XỬ LÝ ẢNH ---
  // (Các hàm _pickImageFromGallery, _takePhoto, handleIdUpload, handleSelfieUpload giữ nguyên)

  Future<XFile?> _pickImageFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể mở bộ sưu tập: $e");
      return null;
    }
  }

  Future<XFile?> _takePhoto() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể mở camera: $e");
      return null;
    }
  }

  Future<void> handleIdUpload() async {
    await Get.defaultDialog(
        title: "Chọn ảnh CMND/CCCD",
        middleText: "Bạn muốn tải lên cả 2 mặt.",
        content: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.image_search),
              title: const Text("Chọn mặt trước (từ Thư viện)"),
              onTap: () async {
                Get.back(); // Đóng dialog
                final image = await _pickImageFromGallery();
                if (image != null) idFrontImage.value = File(image.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_search),
              title: const Text("Chọn mặt sau (từ Thư viện)"),
              onTap: () async {
                Get.back(); // Đóng dialog
                final image = await _pickImageFromGallery();
                if (image != null) idBackImage.value = File(image.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Chụp ảnh (bằng Camera)"),
              onTap: () {
                Get.back();
                Get.snackbar("Thông báo", "Vui lòng chụp mặt trước, sau đó chụp mặt sau.");
              },
            ),
          ],
        ));
  }

  Future<void> handleSelfieUpload() async {
    final image = await _takePhoto(); // Luôn luôn là camera
    if (image != null) selfieImage.value = File(image.path);
  }

  // --- CÁC HÀM XỬ LÝ NÚT BẤM ---

  void skip() {
    Get.offAllNamed(AppRoutes.accountSetup);
  }

  Future<void> submitKyc() async {
    // 1. Kiểm tra (Giữ nguyên)
    if (idFrontImage.value == null ||
        idBackImage.value == null ||
        selfieImage.value == null) {
      Get.snackbar("Thiếu ảnh", "Vui lòng tải lên đủ 3 ảnh để xác minh.");
      return;
    }

    isLoading(true);
    try {
      // --- 2. ✅ SỬA LỖI LOGIC ID TẠI ĐÂY ---
      // Lấy User ID từ FIREBASE AUTH (thay vì GetStorage)
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception("Không tìm thấy phiên đăng nhập Firebase. Vui lòng đăng nhập lại.");
      }
      // Đây là ID mà Firebase Rules có thể đọc được (request.auth.uid)
      final String userId = user.uid;
      // ------------------------------------

      // 3. Tải 3 ảnh lên Firebase Storage (sử dụng userId đã sửa)
      Get.snackbar("Thông báo", "Đang tải ảnh lên, vui lòng chờ...",
          showProgressIndicator: true, duration: const Duration(seconds: 10));

      final [frontUrl, backUrl, selfieUrl] = await Future.wait([
        _storageService.uploadFile(
            idFrontImage.value!, 'kyc/$userId/id_front.jpg'),
        _storageService.uploadFile(
            idBackImage.value!, 'kyc/$userId/id_back.jpg'),
        _storageService.uploadFile(
            selfieImage.value!, 'kyc/$userId/selfie.jpg'),
      ]);

      // 4. Gọi BE (Node.js) với 3 URL đã tải lên (Giữ nguyên)
      await _userService.submitKyc(frontUrl, backUrl, selfieUrl);

      // 5. Thành công (Giữ nguyên)
      Get.snackbar(
          "Thành công", "Đã gửi thông tin KYC. Vui lòng chờ Admin duyệt.");
      Get.offAllNamed(AppRoutes.accountSetup);

    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }
}