// controllers/delivery_controller.dart (ĐÃ NÂNG CẤP)
import 'dart:io'; // <-- 1. IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/manager_order_model.dart';
import '../services/location_service.dart';
import '../services/order_service.dart';
import '../routes/app_routes.dart';
// --- ✅ 2. IMPORT CÁC SERVICE CẦN THIẾT ---
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
// ------------------------------------

class DeliveryController extends GetxController {
  // --- 3. INJECT CÁC SERVICE ---
  final OrderService _orderService = Get.find<OrderService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();
  // --------------------------

  final MapController mapController = MapController();
  late final ManagerOrder order;

  final isLoading = false.obs;
  final isConfirming = false.obs; // Loading chung
  final managerLocation = Rxn<LatLng>();
  final customerLocation = Rxn<LatLng>();

  // State cho Stepper
  final currentStep = 0.obs; // 0 = Đang giao, 1 = Đã giao, 2 = Xác nhận COD

  // --- 4. THÊM STATE CHO POD VÀ GHI CHÚ ---
  final podImage = Rxn<File>(); // File ảnh POD đã chụp
  final podImageUrl = Rxn<String>(); // URL ảnh POD (sau khi upload)
  final noteController = TextEditingController();
  final isConfirmingPOD = false.obs; // Loading riêng cho nút "Xác nhận POD"
  // ------------------------------------

  final currencyFormatter =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void onInit() {
    super.onInit();
    order = Get.arguments as ManagerOrder;
    customerLocation.value = LatLng(
      order.shippingLocation.latitude,
      order.shippingLocation.longitude,
    );
    getManagerCurrentLocation();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  // (Các hàm getManagerCurrentLocation, _fitBounds, openDirectionsToCustomer giữ nguyên)
  Future<void> getManagerCurrentLocation() async {
    try {
      isLoading(true);
      final pos = await LocationService.getCurrentPosition();
      managerLocation.value = pos;
      _fitBounds();
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  void _fitBounds() {
    if (managerLocation.value != null && customerLocation.value != null) {
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(managerLocation.value!, customerLocation.value!),
          padding: const EdgeInsets.all(50.0),
        ),
      );
    }
  }

  void openDirectionsToCustomer() async {
    final lat = order.shippingLocation.latitude;
    final lon = order.shippingLocation.longitude;
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    final Uri launchUri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Lỗi", "Không thể mở Google Maps.");
    }
  }

  Future<void> callCustomer() async {
    final Uri launchUri = Uri(scheme: 'tel', path: order.customerPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar("Lỗi", "Không thể gọi ${order.customerPhone}");
    }
  }

  Future<void> handleMainButtonAction() async {
    isConfirming(true); // Bật loading
    try {
      switch (currentStep.value) {
        case 0: // Bước 0: Nhấn "ĐÃ ĐẾN NƠI GIAO"
          await _confirmArrivalAtCustomer();
          break;
        case 1: // Bước 1: Nhấn "GỬI XÁC NHẬN VỀ HỆ THỐNG"
          await _sendConfirmationToSystem();
          break;
        case 2: // Bước 2: Nhấn "XÁC NHẬN ĐÃ GIAO (POD)"
          await _confirmDeliveryPOD();
          break;
        case 3: // Bước 3: Nhấn "XÁC NHẬN THU COD"
          await _confirmCOD();
          break;
      }
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isConfirming(false); // Tắt loading
    }
  }

  // (Step 0)
  Future<void> _confirmArrivalAtCustomer() async {
    // (Giả lập)
    await Future.delayed(const Duration(milliseconds: 500));
    currentStep.value = 1; // Chuyển sang Bước 1 (Gửi xác nhận)
  }

  // (Step 1) Lão Nông nhấn "Gửi xác nhận về hệ thống"
  Future<void> _sendConfirmationToSystem() async {
    // (Giả lập gọi API)
    await Future.delayed(const Duration(seconds: 1));
    // (API này có thể dùng để báo cho Admin/VTNN biết là Lão Nông đã giao hàng
    //  nhưng chưa chụp POD)
    Get.snackbar("Thành công", "Đã gửi xác nhận. Vui lòng chụp ảnh POD.");
    currentStep.value = 2; // Chuyển sang Bước 2 (Chụp POD)
  }

  // (Step 2) Lão Nông xác nhận đã giao (chụp POD)
  Future<void> _confirmDeliveryPOD() async {
    if (podImage.value == null) {
      Get.snackbar("Lỗi", "Vui lòng chụp ảnh giao hàng (POD).");
      throw Exception("Bỏ qua finally"); // Ngăn tắt loading
    }

    Get.snackbar("Thông báo", "Đang tải ảnh POD lên...", showProgressIndicator: true);
    final String podUrl = await _storageService.uploadFile(
        podImage.value!,
        'pod/${order.id}/${DateTime.now().millisecondsSinceEpoch}.jpg'
    );
    podImageUrl.value = podUrl;

    // Gọi API BE (để lưu URL vào Order)
    await _orderService.confirmDeliveryByManager(order.id, podUrl);

    Get.snackbar("Thành công", "Đã xác nhận giao hàng. Vui lòng xác nhận COD.");
    currentStep.value = 3; // Chuyển sang bước 3 (Xác nhận COD)
  }

  // (Step 3) Lão Nông nhấn "Xác nhận COD"
  Future<void> _confirmCOD() async {
    Get.snackbar("Hoàn tất", "Đã xác nhận COD. Quay về trang chủ.");
    Get.offAllNamed(AppRoutes.bottomNavigation);
  }

  // --- CÁC HÀM PHỤ ---
  Future<void> pickPodImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (image != null) {
        podImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar("Lỗi Camera", e.toString().replaceFirst("Exception: ", ""));
    }
  }

  void reportIssue() {
    // Điều hướng đến màn hình Báo sự cố
    // và gửi ID của đơn hàng này
    Get.toNamed(AppRoutes.reportIssue, arguments: order.id);
  }
}