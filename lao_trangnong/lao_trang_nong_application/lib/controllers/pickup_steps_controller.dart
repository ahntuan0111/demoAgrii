// controllers/pickup_steps_controller.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/manager_order_model.dart';
import '../routes/app_routes.dart';
import '../services/order_service.dart';
import '../services/storage_service.dart';
import '../shared/widgets/confirm_payment_dialog.dart';

class PickupStepsController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  final StorageService _storageService = Get.find<StorageService>(); // <-- Khởi tạo StorageService
  final ImagePicker _picker = ImagePicker(); // <-- Khởi tạo ImagePicker

  late final ManagerOrder order;

  final isLoading = false.obs;
  final currentStep = 0.obs;

  // --- THÊM CÁC BIẾN VÀ HÀM CHO POPUP THANH TOÁN ---
  final amountPaid = Rxn<double>(); // Số tiền đã nộp (từ popup)
  final receiptPhotoUrl = Rxn<String>(); // URL ảnh biên nhận (từ popup)
  final isPaymentConfirming = false.obs; // Trạng thái loading của popup
  final paymentErrorMessage = Rxn<String>(); // Thông báo lỗi popup

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void onInit() {
    super.onInit();
    order = Get.arguments as ManagerOrder;
  }

  // --- CÁC HÀM XỬ LÝ ACTION ---

  // Mở Google Maps để chỉ đường đến VTNN
  void openDirectionsToStore() async {
    final lat = order.storeLocation.latitude;
    final lon = order.storeLocation.longitude;
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    final Uri launchUri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Lỗi", "Không thể mở Google Maps.");
    }
  }

  // Mở ứng dụng gọi điện cho Nông Dân
  void callCustomer() async {
    final Uri launchUri = Uri(scheme: 'tel', path: order.customerPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar("Lỗi", "Không thể gọi ${order.customerPhone}");
    }
  }

  Future<void> handleMainButtonAction() async {
    switch (currentStep.value) {
      case 0: // Bước 1: Nhấn "Đã đến VTNN"
        await _confirmArrivalAtStore();
        break;
      case 1: // Bước 2: Nhấn "Xác nhận đã thanh toán"
      // --- ✅ THAY ĐỔI TẠI ĐÂY: HIỂN THỊ POPUP ---
        _showConfirmPaymentDialog();
        break;
      case 2: // Bước 3: Nhấn "Bắt đầu giao hàng"
        await _startDelivery();
        break;
    }
  }

  // (Step 1) Lão Nông xác nhận đã đến VTNN
  Future<void> _confirmArrivalAtStore() async {
    isLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    currentStep.value = 1;
    isLoading(false);
  }

  // --- ✅ THAY THẾ HÀM NÀY BẰNG VIỆC GỌI POPUP ---
  void _showConfirmPaymentDialog() {
    amountPaid.value = null; // Reset giá trị
    receiptPhotoUrl.value = null; // Reset giá trị
    paymentErrorMessage.value = null; // Reset lỗi

    Get.dialog(
      ConfirmPaymentDialog(), // Popup mới của chúng ta
      barrierDismissible: false,
    );
  }

  // --- HÀM MỚI: XỬ LÝ XÁC NHẬN THANH TOÁN TỪ POPUP ---
  Future<void> processPaymentConfirmation(double amount, String? photoUrl) async {
    isPaymentConfirming(true);
    paymentErrorMessage.value = null; // Reset lỗi

    // 1. Kiểm tra dữ liệu từ popup
    if (amount <= 0) {
      paymentErrorMessage.value = "Vui lòng nhập số tiền đã nộp.";
      isPaymentConfirming(false);
      return;
    }
    // if (photoUrl == null || photoUrl.isEmpty) {
    //   paymentErrorMessage.value = "Vui lòng chụp ảnh biên nhận.";
    //   isPaymentConfirming(false);
    //   return;
    // }

    // 2. So sánh số tiền với 'amountPayableToStore' của đơn hàng
    if (amount < order.amountPayableToStore) {
      paymentErrorMessage.value = "Số tiền nộp phải bằng hoặc lớn hơn số tiền cần nộp.";
      isPaymentConfirming(false);
      return;
    }

    try {
      // 3. Gọi API xác nhận thanh toán (TẠM THỜI GIẢ LẬP)
      // await _orderService.confirmPaymentToStore(order.id, amount, photoUrl);
      await Future.delayed(const Duration(seconds: 1)); // Giả lập API

      Get.back(); // Đóng popup
      Get.snackbar("Thành công", "Đã xác nhận thanh toán với VTNN.");
      currentStep.value = 2; // Chuyển sang bước 3 (Lấy hàng đi giao)

    } catch (e) {
      paymentErrorMessage.value = e.toString().replaceFirst("Exception: ", "");
      Get.snackbar("Lỗi", "Xác nhận thanh toán thất bại: ${e.toString().replaceFirst("Exception: ", "")}");
    } finally {
      isPaymentConfirming(false);
    }
  }

  // Hàm chụp ảnh biên nhận (sẽ được gọi từ popup)
  Future<void> pickReceiptImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (image != null) {
        // Tải ảnh lên Storage và lấy URL
        final String? url = await _storageService.uploadFile(image.path as File, 'receipts/${order.id}');
        if (url != null) {
          receiptPhotoUrl.value = url;
          paymentErrorMessage.value = null; // Xóa lỗi nếu có ảnh
        } else {
          paymentErrorMessage.value = "Tải ảnh lên thất bại.";
        }
      }
    } catch (e) {
      Get.snackbar("Lỗi chụp ảnh", "Không thể chọn hoặc tải ảnh lên: ${e.toString()}");
      paymentErrorMessage.value = "Lỗi chụp ảnh: ${e.toString().replaceFirst("Exception: ", "")}";
    }
  }

  // (Step 3) Lão Nông nhấn "Bắt đầu giao hàng"
  Future<void> _startDelivery() async {
    // TODO: Điều hướng đến màn hình Giao Hàng (chỉ đường đến Customer)
    // Get.offNamed(AppRoutes.deliveryScreen, arguments: order);
    Get.offNamed(AppRoutes.deliveryScreen, arguments: order);
  }

}