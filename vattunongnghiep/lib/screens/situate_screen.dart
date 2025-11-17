// screens/situate_screen.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:agri_flutter/shared/widgets/custom_snackbar.dart';
import 'package:agri_flutter/shared/widgets/situate_confirm_button.dart';
import 'package:agri_flutter/shared/widgets/situate_searchbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../controllers/situate_controller.dart';

class SituateScreen extends GetView<SituateController> {
  const SituateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Tạo MapController
    final mapController = MapController();

    // 2. Gửi MapController LÊN cho SituateController
    controller.setMapController(mapController);

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
                  initialCenter: const LatLng(10.762622, 106.660172),
                  initialZoom: 14,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      controller.onMapMoved(position.center);
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

            // --- 3. CẬP NHẬT Ở ĐÂY ---
            // Bọc nút bấm trong Obx để xử lý loading
            Obx(() {
              if (controller.isLoading.value) {
                // Hiển thị vòng xoay khi đang lưu vị trí
                return Container(
                  color: Colors.black87, // Thêm màu nền cho nhất quán
                  padding: const EdgeInsets.all(20.0),
                  child: const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                );
              } else {
                // Hiển thị nút bấm
                return SituateConfirmButton(
                  onConfirm: controller.onConfirmLocation,
                );
              }
            }),
            // -----------------------

          ],
        );
      }),
    );
  }
}