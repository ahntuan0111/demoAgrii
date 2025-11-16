import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/pickup_map_controller.dart';
import '../models/manager_order_model.dart';
// (Import AppColors nếu có)
// import 'package:agri_flutter/shared/themes/app_colors.dart';

class PickupMapScreen extends GetView<PickupMapController> {
  const PickupMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Lấy hàng: DH-${controller.order.id.substring(0, 8)}...',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. BẢN ĐỒ ---
          Expanded(
            flex: 2, // Map chiếm 2/3
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              }
              return FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.storeLocation.value ?? const LatLng(10.76, 106.66),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      if (controller.managerLocation.value != null)
                        Marker(
                          point: controller.managerLocation.value!,
                          child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                        ),
                      if (controller.storeLocation.value != null)
                        Marker(
                          point: controller.storeLocation.value!,
                          child: const Icon(Icons.storefront, color: Colors.red, size: 40),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),

          // --- 2. THÔNG TIN VTNN ---
          Expanded(
            flex: 1, // Card chiếm 1/3
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: -5)
                  ]
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Hãy chọn VTNN để lấy hàng',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildStoreCard(controller.order), // Thẻ VTNN
                    const SizedBox(height: 24),
                    _buildWarning(), // Cảnh báo
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Xác nhận chọn VTNN',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Thẻ thông tin VTNN (Giống trong ảnh)
  Widget _buildStoreCard(ManagerOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.storeName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.check_circle, color: Colors.green)
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [

              // --- ✅ SỬA LỖI TẠI ĐÂY ---
              // Thêm '?? 0.0' để xử lý giá trị distance bị null
              Text('${controller.distanceFormatter.format(order.distance ?? 0.0)} km',
                  style: const TextStyle(color: Colors.black54)),
              // --- KẾT THÚC SỬA LỖI ---

              const SizedBox(width: 12),
              const Icon(Icons.watch_later_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('06:00 - 22:00', // (Dữ liệu giả)
                  style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Còn hàng',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: controller.openDirections,
                icon: const Icon(Icons.directions_outlined),
                label: const Text('Chỉ đường'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // Cảnh báo
  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lưu ý: Thanh toán cho VTNN trước khi nhận hàng và bắt đầu giao.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}