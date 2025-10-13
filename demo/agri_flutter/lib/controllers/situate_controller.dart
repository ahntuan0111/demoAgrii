import 'package:agri_flutter/services/location_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../shared/widgets/custom_snackbar.dart';
import '../routes/app_routes.dart';


class SituateController extends GetxController {
  final currentPosition = Rxn<LatLng>();

  @override
  void onInit() {
    super.onInit();
    determinePosition();
  }

  Future<void> determinePosition() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) currentPosition.value = pos;
  }

  void onMapMoved(LatLng newCenter) {
    currentPosition.value = newCenter;
  }

  void onConfirmLocation() {
    final pos = currentPosition.value;
    if (pos == null) {
      showCustomSnackbar('Thông báo', 'Chưa xác định được vị trí');
      return;
    }
    showCustomSnackbar(
      'Xác nhận',
      'Vị trí: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
    );
    Get.toNamed(AppRoutes.roleSelect);
  }
}
