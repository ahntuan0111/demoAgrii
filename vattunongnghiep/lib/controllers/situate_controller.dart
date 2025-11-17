// controllers/situate_controller.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:agri_flutter/services/location_service.dart';
import 'package:agri_flutter/services/user_service.dart'; // <-- 1. IMPORT
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../shared/widgets/custom_snackbar.dart';
import '../routes/app_routes.dart';
import 'package:flutter_map/flutter_map.dart';

class SituateController extends GetxController {
  final currentPosition = Rxn<LatLng>();
  MapController? mapController;

  // 2. INJECT USER SERVICE
  final UserService _userService = Get.find<UserService>();

  // 3. THÊM TRẠNG THÁI LOADING
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    determinePosition();
  }

  void setMapController(MapController controller) {
    mapController = controller;
  }

  Future<void> determinePosition() async {
    // (Hàm này giữ nguyên logic lấy vị trí và di chuyển bản đồ)
    try {
      final pos = await LocationService.getCurrentPosition();
      currentPosition.value = pos;
      if (mapController != null && pos != null) {
        mapController?.move(pos, 15.0);
      }
    } on LocationException catch (e) {
      showCustomSnackbar('Lỗi Vị trí', e.message, isError: true);
    } catch (e) {
      showCustomSnackbar('Lỗi', e.toString(), isError: true);
    }
  }

  void onMapMoved(LatLng newCenter) {
    currentPosition.value = newCenter;
  }

  // --- 4. VIẾT LẠI HOÀN TOÀN HÀM NÀY ---
  Future<void> onConfirmLocation() async {
    final pos = currentPosition.value;
    if (pos == null) {
      showCustomSnackbar('Thông báo', 'Chưa xác định được vị trí', isError: true);
      return;
    }

    try {
      isLoading(true); // Bật loading

      // GỌI API ĐỂ LƯU VỊ TRÍ LÊN BE
      await _userService.updateUserLocation(pos);

      // Nếu thành công:
      showCustomSnackbar(
        'Xác nhận',
        'Đã lưu vị trí của bạn!', // Thông báo mới
      );
      // Đi đến màn hình chính
      Get.toNamed(AppRoutes.selectPartner);

    } catch (e) {
      // Nếu lỗi API (vd: mất mạng, lỗi server)
      showCustomSnackbar(
        'Lỗi',
        e.toString().replaceFirst("Exception: ", ""),
        isError: true,
      );
    } finally {
      isLoading(false); // Tắt loading
    }
  }
}