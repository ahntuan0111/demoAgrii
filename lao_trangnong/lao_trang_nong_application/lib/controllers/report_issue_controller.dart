// controllers/report_issue_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/order_service.dart';
import '../services/storage_service.dart';

class ReportIssueController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  late final String orderId; // ID đơn hàng được truyền vào

  final isLoading = false.obs;

  // Form
  final formKey = GlobalKey<FormState>();
  final issueTypeController = TextEditingController();
  final descriptionController = TextEditingController();
  final reportImage = Rxn<File>();
  final reportImageUrl = Rxn<String>();

  // Dữ liệu giả cho Dropdown "Loại sự cố"
  final issueTypes = [
    'Hàng hư hỏng',
    'Sai sản phẩm',
    'Thiếu hàng',
    'Khách hàng không nhận',
    'Sự cố vận chuyển',
    'Khác',
  ].obs;
  final selectedIssueType = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    // Lấy Order ID từ arguments (được gửi từ DeliveryController)
    orderId = Get.arguments as String;
  }

  @override
  void onClose() {
    issueTypeController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Xử lý chọn loại sự cố
  void selectIssueType(String? newValue) {
    if (newValue != null) {
      selectedIssueType.value = newValue;
    }
  }

  /// Xử lý chụp/chọn ảnh
  Future<void> pickReportImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        reportImage.value = File(image.path);
        // Tải ảnh lên ngay lập tức
        uploadImage(File(image.path));
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể chọn ảnh: $e");
    }
  }

  /// Tải ảnh lên Storage
  Future<void> uploadImage(File imageFile) async {
    try {
      Get.snackbar("Thông báo", "Đang tải ảnh minh chứng...", showProgressIndicator: true);
      final url = await _storageService.uploadFile(
        imageFile,
        'reports/$orderId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      reportImageUrl.value = url; // Lưu lại URL
    } catch (e) {
      Get.snackbar("Lỗi", "Tải ảnh lên thất bại: $e");
    }
  }

  /// Gửi báo cáo (nút chính)
  Future<void> submitReport() async {
    if (isLoading.value) return;

    // 1. Validate
    if (selectedIssueType.value == null) {
      Get.snackbar("Lỗi", "Vui lòng chọn loại sự cố.");
      return;
    }
    if (descriptionController.text.isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng nhập mô tả chi tiết.");
      return;
    }

    isLoading(true);
    try {
      // 2. Gọi Service
      await _orderService.createReport(
        orderId: orderId,
        issueType: selectedIssueType.value!,
        description: descriptionController.text.trim(),
        imageUrl: reportImageUrl.value, // (Có thể null)
      );

      // 3. Thành công
      Get.snackbar("Thành công", "Đã gửi báo cáo sự cố thành công.");
      Get.back(); // Quay lại màn hình Giao hàng

    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }
}