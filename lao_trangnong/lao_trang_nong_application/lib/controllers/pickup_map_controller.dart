// controllers/pickup_map_controller.dart (ĐÃ SỬA LỖI)
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // <-- 1. IMPORT

import '../models/manager_order_model.dart';
import '../routes/app_routes.dart';
import '../services/location_service.dart';

class PickupMapController extends GetxController {
  final MapController mapController = MapController();
  late final ManagerOrder order;

  final isLoading = false.obs;
  final managerLocation = Rxn<LatLng>(); // Vị trí hiện tại của Lão Nông
  final storeLocation = Rxn<LatLng>(); // Vị trí VTNN

  // --- ✅ 2. THÊM BIẾN BỊ THIẾU VÀO ĐÂY ---
  final distanceFormatter = NumberFormat("###.0#", "vi_VN");
  // ------------------------------------

  @override
  void onInit() {
    super.onInit();
    order = Get.arguments as ManagerOrder;
    storeLocation.value = LatLng(
      order.storeLocation.latitude,
      order.storeLocation.longitude,
    );
    getManagerCurrentLocation();
  }

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
    if (managerLocation.value != null && storeLocation.value != null) {
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(managerLocation.value!, storeLocation.value!),
          padding: const EdgeInsets.all(50.0),
        ),
      );
    }
  }

  // Mở Google Maps
  void openDirections() async {
    final lat = order.storeLocation.latitude;
    final lon = order.storeLocation.longitude;
    final String googleMapsUrl = 'https.google.com/maps/search/?api=1&query=$lat,$lon';
    final Uri launchUri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Lỗi", "Không thể mở Google Maps.");
    }
  }

  // Nút "Xác nhận chọn VTNN"
  void confirmSelection() {
    // Điều hướng đến Màn hình 2 (Stepper) và truyền 'order' đi
    Get.toNamed(AppRoutes.pickupSteps, arguments: order);
  }
}