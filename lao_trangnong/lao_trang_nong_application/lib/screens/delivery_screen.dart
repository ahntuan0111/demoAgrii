// screens/delivery_screen.dart (ĐÃ NÂNG CẤP LÊN 4 BƯỚC)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dotted_border/dotted_border.dart';
import '../controllers/delivery_controller.dart';
import '../models/manager_order_model.dart';
// (Import AppColors nếu có)
// import 'package:agri_flutter/shared/themes/app_colors.dart';

class DeliveryScreen extends GetView<DeliveryController> {
  const DeliveryScreen({super.key});

  Color get kAppGreen => Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    // (Giả sử AppColors)
    const Color kAppGreen = Color(0xFF1B5E20);
    const Color kAppGrey = Color(0xFFF4F6F5);
    const Color kAppRed = Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: kAppGrey,
      appBar: AppBar(
        backgroundColor: kAppGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Giao hàng & POD: DH-${controller.order.id.substring(0, 8)}...',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. THANH STEPPER ---
          _buildStepper(kAppGreen),

          // --- 2. NỘI DUNG (Map + Card) ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapArea(), // Bản đồ
                  _buildContentArea(kAppGreen, kAppRed), // Cards
                ],
              ),
            ),
          ),

          // --- 3. NÚT BẤM CHÍNH ---
          _buildBottomButton(kAppGreen, kAppRed),
        ],
      ),
    );
  }

  // --- WIDGETS CON ---

  // 1. Stepper (CẬP NHẬT THÀNH 4 BƯỚC)
  Widget _buildStepper(Color kAppGreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Obx(() => Row(
        children: [
          _buildStepCircle('1', 'Đang giao', controller.currentStep.value >= 0, kAppGreen),
          _buildStepLine(controller.currentStep.value >= 1, kAppGreen),
          _buildStepCircle('2', 'Đã đến', controller.currentStep.value >= 1, kAppGreen),
          _buildStepLine(controller.currentStep.value >= 2, kAppGreen),
          _buildStepCircle('3', 'Gửi POD', controller.currentStep.value >= 2, kAppGreen),
          _buildStepLine(controller.currentStep.value >= 3, kAppGreen),
          _buildStepCircle('4', 'Xác nhận', controller.currentStep.value >= 3, kAppGreen),
        ],
      )),
    );
  }

  Widget _buildStepCircle(String number, String label, bool isActive, Color kAppGreen) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? kAppGreen : Colors.grey[300],
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? Colors.black : Colors.grey))
      ],
    );
  }

  Widget _buildStepLine(bool isActive, Color kAppGreen) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? kAppGreen : Colors.grey[300],
      ),
    );
  }

  // 2. Bản đồ (Giữ nguyên)
  Widget _buildMapArea() {
    return SizedBox(
      height: 300, // Chiều cao cố định cho map
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }
        return FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: controller.customerLocation.value ?? const LatLng(10.76, 106.66),
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
                if (controller.customerLocation.value != null)
                  Marker(
                    point: controller.customerLocation.value!,
                    child: const Icon(Icons.home, color: Colors.red, size: 40),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }

  // 3. Nội dung (Card)
  Widget _buildContentArea(Color kAppGreen, Color kAppRed) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDestinationCard(), // Card Điểm Giao Hàng
          const SizedBox(height: 16),
          _buildProductsCard(kAppGreen), // Card Sản phẩm
          const SizedBox(height: 16),

          // --- ✅ CẬP NHẬT LOGIC HIỂN THỊ (THEO 4 BƯỚC) ---
          Obx(() {
            // Hiển thị ở Bước 2 (Chụp POD)
            if (controller.currentStep.value == 2) {
              return _buildPodSection(kAppGreen, kAppRed); // <-- Widget POD
            } else {
              return const SizedBox.shrink(); // Ẩn
            }
          }),
          Obx(() {
            // Hiển thị ở Bước 3 (Xác nhận COD)
            if (controller.currentStep.value == 3) {
              return _buildNoteSection(); // <-- Widget Ghi chú
            } else {
              return const SizedBox.shrink(); // Ẩn
            }
          }),
          // ------------------------------------------
        ],
      ),
    );
  }

  // 3.1 Card Điểm Giao Hàng (Giữ nguyên)
  Widget _buildDestinationCard() {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Điểm Giao hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
                'Nhà anh ${controller.order.customerName}, ${controller.order.shippingAddress}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.openDirectionsToCustomer,
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Chỉ đường'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.callCustomer,
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Gọi khách'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 3.2 Card Sản phẩm (Giữ nguyên)
  Widget _buildProductsCard(Color kAppGreen) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ...controller.order.orderItems.map((item) =>
                _buildItemRow(item.name, item.variantName, item.quantity)
            ),
            const Divider(height: 20),
            _buildPriceRow('Giá chiết khấu', controller.currencyFormatter.format(controller.order.amountPayableToStore), Colors.orange.shade700),
            _buildPriceRow('Giá nhà nông trả', controller.currencyFormatter.format(controller.order.totalPrice)),
            _buildPriceRow('TN (10%)', '+${controller.currencyFormatter.format(controller.order.commission)}', kAppGreen),
            _buildPriceRow('LN Trực thuộc (5%)', '+130.000VNĐ (Fake)', kAppGreen),
          ],
        ),
      ),
    );
  }

  // 4. Widget POD (Giữ nguyên)
  Widget _buildPodSection(Color kAppGreen, Color kAppRed) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Bước 3: Xác nhận giao hàng (POD)', // Sửa Text
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const Divider(height: 20),
            const Text('Chụp ảnh giao hàng', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),

            Obx(() {
              // Nếu đã chụp ảnh
              if (controller.podImage.value != null) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      controller.podImage.value!,
                      width: 50, height: 50, fit: BoxFit.cover,
                    ),
                  ),
                  title: const Text('Đã chụp ảnh POD'),
                  trailing: Icon(Icons.check_circle, color: kAppGreen),
                  tileColor: Colors.green[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: controller.pickPodImage, // Cho phép chụp lại
                );
              }
              // Nếu đang ở bước 2 (chưa chụp)
              return DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                color: kAppGreen,
                dashPattern: const [6, 6],
                child: InkWell(
                  onTap: controller.pickPodImage,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 30, color: kAppGreen),
                        const SizedBox(height: 8),
                        Text('Chụp ảnh giao hàng', style: TextStyle(fontSize: 15, color: kAppGreen)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 5. Widget Ghi chú (Giữ nguyên)
  Widget _buildNoteSection() {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 16), // Thêm khoảng cách
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ghi chú (không bắt buộc)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: controller.noteController,
              decoration: InputDecoration(
                hintText: 'VD: Đã giao cho anh Tuấn...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kAppGreen)
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // Nút bấm dưới cùng
  Widget _buildBottomButton(Color kAppGreen, Color kAppRed) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Obx(() {
        // --- ✅ CẬP NHẬT TEXT NÚT BẤM (THEO 4 BƯỚC) ---
        String buttonText = 'Bước 1: Đã đến nơi giao';
        if (controller.currentStep.value == 1) buttonText = 'Bước 2: Gửi xác nhận về hệ thống';
        if (controller.currentStep.value == 2) buttonText = 'Bước 3: Xác nhận đã giao (POD)';
        if (controller.currentStep.value == 3) buttonText = 'Bước 4: Xác nhận thu COD';
        // ------------------------------------

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: (controller.isLoading.value || controller.isConfirming.value)
                  ? null
                  : controller.handleMainButtonAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAppGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: (controller.isLoading.value || controller.isConfirming.value)
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                  : Text(buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            ),
            // Nút Báo sự cố
            if (controller.currentStep.value < 3) // Ẩn ở bước cuối
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: controller.reportIssue,
                  child: Text(
                    'Báo sự cố',
                    style: TextStyle(color: kAppRed, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // Helper cho danh sách item
  Widget _buildItemRow(String name, String variant, int quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200], // (Màu nền khác 1 chút)
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('$name ($variant) (x$quantity)', style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  // Helper cho dòng giá tiền
  Widget _buildPriceRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}