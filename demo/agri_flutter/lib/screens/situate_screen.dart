import 'package:agri_flutter/routes/app_routes.dart';
import 'package:agri_flutter/shared/widgets/custom_snackbar.dart';
import 'package:agri_flutter/shared/widgets/situate_confirm_button.dart';
import 'package:agri_flutter/shared/widgets/situate_searchbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../controllers/situate_controller.dart';


class SituateScreen extends StatelessWidget {
  const SituateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SituateController>();
    final mapController = MapController();

    controller.determinePosition();

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Đặt vị trí',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Image.asset(
            'assets/images/logo.png',
            height: 30,
          ),
        ),
      ],
      ),
      body: Obx(() {
        final pos = controller.currentPosition.value;

        return Column(
          children: [
            const SituateSearchBox(),
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: pos ?? const LatLng(10.762622, 106.660172),
                  initialZoom: 14,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      controller.currentPosition.value = position.center;
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  if (pos != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pos,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_pin,
                              color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SituateConfirmButton(onConfirm: () {
              if (pos == null) {
                showCustomSnackbar('Thông báo', 'Chưa xác định được vị trí');
                return;
              }

              showCustomSnackbar(
                'Xác nhận',
                'Vị trí: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
              );
              Get.toNamed(AppRoutes.roleSelect);
            }),
          ],
        );
      }),
    );
  }
}
