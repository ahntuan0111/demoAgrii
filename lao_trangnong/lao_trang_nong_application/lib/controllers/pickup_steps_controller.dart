// controllers/pickup_steps_controller.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/manager_order_model.dart';
import '../routes/app_routes.dart';
import '../services/order_service.dart';
import '../services/storage_service.dart'; // Đảm bảo bạn đã có service này
import '../shared/widgets/confirm_payment_dialog.dart';

class PickupStepsController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();

  // Lưu ý: Nếu chưa viết StorageService, hãy tạm comment dòng này và hàm upload
  final StorageService _storageService = Get.find<StorageService>();

  final ImagePicker _picker = ImagePicker();

  late final ManagerOrder order;

  final isLoading = false.obs;
  final currentStep = 0.obs;

  // --- STATE CHO POPUP ---
  final amountPaid = Rxn<double>();
  final receiptPhotoUrl = Rxn<String>();
  final isPaymentConfirming = false.obs;
  final paymentErrorMessage = Rxn<String>();

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void onInit() {
    super.onInit();
    order = Get.arguments as ManagerOrder;
  }

  // ... (Các hàm openDirectionsToStore, callCustomer giữ nguyên) ...
  void openDirectionsToStore() async {
    // (Code cũ của bạn)
  }
  void callCustomer() async {
    // (Code cũ của bạn)
  }

  Future<void> handleMainButtonAction() async {
    switch (currentStep.value) {
      case 0:
        await _confirmArrivalAtStore();
        break;
      case 1:
        _showConfirmPaymentDialog();
        break;
      case 2:
        await _startDelivery();
        break;
    }
  }

  Future<void> _confirmArrivalAtStore() async {
    isLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    currentStep.value = 1;
    isLoading(false);
  }

  void _showConfirmPaymentDialog() {
    // 1. Reset dữ liệu form
    amountPaid.value = order.amountPayableToStore; // Gợi ý số tiền mặc định
    receiptPhotoUrl.value = null;
    paymentErrorMessage.value = null;

    Get.dialog(
      ConfirmPaymentDialog(),
      barrierDismissible: false,
    );
  }

  // --- XỬ LÝ XÁC NHẬN THANH TOÁN ---
  Future<void> processPaymentConfirmation(double amount, String? photoUrl) async {
    isPaymentConfirming(true);
    paymentErrorMessage.value = null;

    // 1. Kiểm tra số tiền
    if (amount <= 0) {
      paymentErrorMessage.value = "Vui lòng nhập số tiền đã nộp.";
      isPaymentConfirming(false);
      return;
    }

    // 2. Kiểm tra số tiền có đủ không
    if (amount < order.amountPayableToStore) {
      paymentErrorMessage.value = "Số tiền nộp chưa đủ (Phải >= ${currencyFormatter.format(order.amountPayableToStore)}).";
      isPaymentConfirming(false);
      return;
    }

    // 3. --- ✅ BẬT LẠI KIỂM TRA ẢNH (BẮT BUỘC) ---
    if (photoUrl == null || photoUrl.isEmpty) {
      paymentErrorMessage.value = "Vui lòng chụp ảnh biên nhận làm bằng chứng.";
      isPaymentConfirming(false);
      return;
    }
    // ---------------------------------------------

    try {
      // 4. Gọi API (Giả lập hoặc thật)
      // await _orderService.confirmPaymentToStore(order.id, amount, photoUrl);

      await Future.delayed(const Duration(seconds: 1)); // Giả lập delay API

      Get.back(); // Đóng popup
      Get.snackbar("Thành công", "Đã xác nhận thanh toán với VTNN.");

      currentStep.value = 2; // Chuyển sang bước 3

    } catch (e) {
      paymentErrorMessage.value = e.toString().replaceFirst("Exception: ", "");
    } finally {
      isPaymentConfirming(false);
    }
  }

  // --- CHỤP ẢNH ---
  Future<void> pickReceiptImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

      if (image != null) {
        // --- LOGIC UPLOAD ẢNH ---
        // Nếu bạn chưa có server upload, dùng tạm ảnh local để test logic UI:
        // receiptPhotoUrl.value = "https://via.placeholder.com/150";

        // Nếu đã có StorageService:
        final String? url = await _storageService.uploadFile(File(image.path), 'receipts/${order.id}');

        if (url != null) {
          receiptPhotoUrl.value = url;
          paymentErrorMessage.value = null;
        } else {
          paymentErrorMessage.value = "Tải ảnh lên thất bại. Vui lòng thử lại.";
        }
      }
    } catch (e) {
      paymentErrorMessage.value = "Lỗi camera: ${e.toString()}";
    }
  }

  Future<void> _startDelivery() async {
    Get.offNamed(AppRoutes.deliveryScreen, arguments: order);
  }
}