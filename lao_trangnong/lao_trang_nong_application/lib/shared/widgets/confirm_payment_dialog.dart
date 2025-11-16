// screens/widgets/confirm_payment_dialog.dart (ĐÃ SỬA LỖI)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// dùng alias để tránh xung đột tên và để truy cập BorderType, DottedBorder rõ ràng
import 'package:dotted_border/dotted_border.dart' as dotted;
import '../../controllers/pickup_steps_controller.dart';

class ConfirmPaymentDialog extends GetView<PickupStepsController> {
  ConfirmPaymentDialog({super.key});

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // (Giả sử AppColors)
    const Color kAppGreen = Color(0xFF1B5E20); // (Màu xanh đậm)
    const Color kAppRed = Color(0xFFD32F2F);
    // --- 2. THÊM HẰNG SỐ MÀU BỊ THIẾU ---
    const Color kAppBlue = Color(0xFF1976D2);
    // ------------------------------------
    const Color kAppGreyLight = Color(0xFFF0F0F0);

    // Gán giá trị mặc định khi dialog mở (số tiền cần nộp)
    _amountController.text = controller.order.amountPayableToStore.toString();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Obx(() => SingleChildScrollView( // Bọc để tránh overflow khi keyboard mở
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nộp tiền tại VTNN',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // --- 1. SỐ TIỀN CẦN NỘP ---
              const Text('Số tiền cần nộp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: kAppGreyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currencyFormatter.format(controller.order.amountPayableToStore),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kAppGreen),
                    ),
                    const Text('(Đã trừ chiết khấu 10%)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. SỐ TIỀN ĐÃ NỘP ---
              const Text('Số tiền đã nộp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập số tiền...',
                  suffixText: '₫',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: kAppGreyLight,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                onChanged: (value) {
                  controller.amountPaid.value = double.tryParse(value);
                  controller.paymentErrorMessage.value = null; // Xóa lỗi khi người dùng nhập
                },
              ),
              const SizedBox(height: 24),

              // --- 3. ẢNH BIÊN NHẬN ---
              Row(
                children: [
                  const Text('Ảnh biên nhận', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(' *', style: TextStyle(color: kAppRed, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
//                onTap: controller.pickReceiptImage,
                child: dotted.DottedBorder(
                  // sử dụng alias dotted và enum dotted.BorderType
                  borderType: dotted.BorderType.RRect,
                  radius: const Radius.circular(12),
                  padding: const EdgeInsets.all(12),
                  color: controller.receiptPhotoUrl.value != null ? kAppGreen : Colors.grey,
                  dashPattern: const [6, 6],
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: controller.receiptPhotoUrl.value != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // Hiển thị ảnh từ URL
                      child: Image.network(
                        controller.receiptPhotoUrl.value!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                      ),
                    )
                        : Column( // bỏ const vì dùng biến màu không phải const
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 40, color: kAppGreen),
                        const SizedBox(height: 8),
                        Text('Chụp ảnh biên nhận', style: TextStyle(fontSize: 15, color: kAppGreen)),
                        const Text('Bắt buộc phải có ảnh', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              // Hiển thị lỗi nếu có
              // (Sử dụng Obx để đảm bảo nó build lại khi lỗi thay đổi)
              Obx(() {
                if (controller.paymentErrorMessage.value != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      controller.paymentErrorMessage.value!,
                      style: TextStyle(color: kAppRed, fontSize: 13),
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // Không có lỗi, không hiển thị gì
                }
              }),
              const SizedBox(height: 24),

              // --- 4. LƯU Ý ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kAppBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lưu ý', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kAppBlue)),
                    const SizedBox(height: 8),
                    _buildBulletPoint('Chụp rõ ràng toàn bộ thông tin trên biên nhận', kAppBlue),
                    _buildBulletPoint('Đảm bảo ảnh không bị mờ hoặc thiếu thông tin', kAppBlue),
                    _buildBulletPoint('Nếu ảnh không hợp lệ, bạn sẽ được yêu cầu chụp lại', kAppBlue),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- NÚT XÁC NHẬN ---
              ElevatedButton(
                onPressed: controller.isPaymentConfirming.value
                    ? null
                    : () {
                  // Gọi hàm xử lý xác nhận từ controller
                  controller.processPaymentConfirmation(
                    controller.amountPaid.value ?? 0,
                    controller.receiptPhotoUrl.value,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isPaymentConfirming.value
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Xác nhận đã nộp',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      )),
    );
  }

  // Helper cho các bullet point
  Widget _buildBulletPoint(String text, Color kAppBlue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: kAppBlue)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}
