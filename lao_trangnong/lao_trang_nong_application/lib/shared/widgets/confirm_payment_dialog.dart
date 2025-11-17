// screens/widgets/confirm_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import '../../controllers/pickup_steps_controller.dart';

class ConfirmPaymentDialog extends GetView<PickupStepsController> {
  ConfirmPaymentDialog({super.key});

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color kAppGreen = Color(0xFF1B5E20);
    const Color kAppRed = Color(0xFFD32F2F);
    const Color kAppBlue = Color(0xFF1976D2);
    const Color kAppGreyLight = Color(0xFFF0F0F0);

    // Set giá trị hiển thị ban đầu
    if (controller.amountPaid.value == null) {
      _amountController.text = controller.order.amountPayableToStore.toStringAsFixed(0);
      // Cập nhật luôn vào controller để nếu user không sửa gì thì vẫn có giá trị
      controller.amountPaid.value = controller.order.amountPayableToStore;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close), // Đổi thành nút đóng cho tiện
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              const Text(
                'Nộp tiền tại VTNN',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 1. SỐ TIỀN CẦN NỘP (INFO)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kAppGreyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Số tiền cần nộp (COD)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      controller.currencyFormatter.format(controller.order.amountPayableToStore),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kAppGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. INPUT SỐ TIỀN THỰC TẾ
              const Text('Số tiền thực nộp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập số tiền...',
                  suffixText: '₫',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) {
                  // Parse double an toàn
                  controller.amountPaid.value = double.tryParse(value) ?? 0;
                  controller.paymentErrorMessage.value = null;
                },
              ),
              const SizedBox(height: 24),

              // 3. ẢNH BIÊN NHẬN
              Row(
                children: [
                  const Text('Ảnh biên nhận/Giao dịch', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(' *', style: TextStyle(color: kAppRed, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),

              GestureDetector(
                // --- ✅ SỬA LỖI: BẬT LẠI ONTAP ---
                onTap: () => controller.pickReceiptImage(),
                // -------------------------------

                child: dotted.DottedBorder(
                  borderType: dotted.BorderType.RRect,
                  radius: const Radius.circular(12),
                  padding: const EdgeInsets.all(6), // Padding nhỏ cho border
                  color: controller.receiptPhotoUrl.value != null ? kAppGreen : Colors.grey,
                  dashPattern: const [6, 6],
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: controller.receiptPhotoUrl.value != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        controller.receiptPhotoUrl.value!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            Text("Lỗi tải ảnh", style: TextStyle(color: Colors.red))
                          ],
                        ),
                        loadingBuilder: (c, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 40, color: kAppGreen),
                        const SizedBox(height: 8),
                        Text('Chạm để chụp ảnh', style: TextStyle(color: kAppGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),

              // Hiển thị lỗi
              if (controller.paymentErrorMessage.value != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    controller.paymentErrorMessage.value!,
                    style: TextStyle(color: kAppRed, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 24),

              // 4. LƯU Ý
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 20, color: kAppBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vui lòng nộp đúng số tiền và chụp rõ biên lai/màn hình chuyển khoản để VTNN đối soát.',
                        style: TextStyle(fontSize: 13, color: kAppBlue.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isPaymentConfirming.value
                      ? null
                      : () {
                    controller.processPaymentConfirmation(
                      controller.amountPaid.value ?? 0,
                      controller.receiptPhotoUrl.value,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isPaymentConfirming.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Xác nhận đã nộp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}