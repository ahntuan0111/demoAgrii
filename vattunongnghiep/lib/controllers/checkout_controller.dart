// controllers/checkout_controller.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agri_flutter/controllers/cart_controller.dart';
import 'package:agri_flutter/services/order_service.dart';
import 'package:agri_flutter/routes/app_routes.dart';

enum PaymentMethod { cod, online }

class CheckoutController extends GetxController {
  // --- 1. KẾT NỐI VỚI CÁC DEPENDENCIES ---
  final CartController cartController = Get.find<CartController>();
  final OrderService _orderService = Get.find<OrderService>();

  // --- 2. STATE CỦA MÀN HÌNH CHECKOUT ---
  final selectedAddress = 'Vui lòng chọn địa chỉ giao hàng'.obs;
  final selectedTime = 'Càng sớm càng tốt'.obs;
  final selectedPaymentMethod = PaymentMethod.cod.obs;
  final allowSubstitution = false.obs;
  final isLoading = false.obs;

  // --- 3. STATE VỀ GIÁ (LẤY TỪ CART CONTROLLER) ---
  final subtotal = 0.0.obs;
  final shippingFee = 30000.0.obs; // Giả lập phí ship
  final vatFee = 0.0.obs;
  final total = 0.0.obs;

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void onInit() {
    super.onInit();
    // Đây chính là logic "chuyển giá qua"
    calculateTotals();
  }

  /// Đọc dữ liệu từ CartController và tính toán
  void calculateTotals() {
    subtotal.value = cartController.subtotal.value;
    vatFee.value = subtotal.value * 0.08; // Giả lập VAT 8%
    total.value = (cartController.total.value) + shippingFee.value + vatFee.value;
    if (total.value < 0) total.value = 0;
  }

  // (Các hàm UI giữ nguyên như code của bạn)
  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }
  void toggleSubstitution(bool? value) {
    allowSubstitution.value = value ?? false;
  }
  void showAddressInputDialog() {
    final TextEditingController addressTextController =
    TextEditingController(
        text: selectedAddress.value == 'Vui lòng chọn địa chỉ giao hàng'
            ? ''
            : selectedAddress.value
    );
    Get.defaultDialog(
      title: "Cập nhật địa chỉ giao hàng",
      content: TextField(
        controller: addressTextController,
        decoration: const InputDecoration(
          hintText: "Nhập địa chỉ của bạn...",
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      textCancel: "Hủy",
      textConfirm: "Xác nhận",
      onConfirm: () {
        if (addressTextController.text.isNotEmpty) {
          selectedAddress.value = addressTextController.text;
        } else {
          selectedAddress.value = 'Vui lòng chọn địa chỉ giao hàng';
        }
        Get.back(); // Đóng dialog
      },
    );
  }


  /// 4. HÀM CHÍNH: ĐẶT HÀNG (GỌI API)
  Future<void> placeOrder() async {
    try {
      if(selectedAddress.value == 'Vui lòng chọn địa chỉ giao hàng') {
        Get.snackbar("Lỗi", "Vui lòng nhập địa chỉ giao hàng.", snackPosition: SnackPosition.BOTTOM);
        return;
      }
      isLoading(true);

      // 1. Chuẩn bị DỮ LIỆU JSON cho API (để gửi lên BE)
      final List<Map<String, dynamic>> orderItemsJson = cartController.cartItems.map((item) => {
        'name': item.name,
        'quantity': item.quantity,
        'image': item.image,
        'price': item.price,
        'variantName': item.variantName,
        'productId': item.productId,
      }).toList();

      final Map<String, dynamic> apiOrderData = {
        'shippingAddress': selectedAddress.value,
        'paymentMethod': selectedPaymentMethod.value.name,
        'items': orderItemsJson, // Gửi List<Map>
        'subtotal': subtotal.value,
        'shippingFee': shippingFee.value,
        'vatFee': vatFee.value,
        'totalPrice': total.value,
      };

      // --- ✅ SỬA LỖI 2 TẠI ĐÂY ---
      // 2. Chuẩn bị DỮ LIỆU ARGUMENTS (để gửi cho màn hình Confirmation)
      //    (Phải khớp với những gì màn hình Confirmation mong đợi)
      final Map<String, dynamic> confirmationArguments = {
        'deliveryTime': selectedTime.value,
        'deliveryAddress': selectedAddress.value,
        'cartItems': cartController.cartItems.toList(), // <-- Gửi List<CartItem>
        'total': total.value, // <-- Gửi key 'total'
        'auxiliaryFee': vatFee.value, // <-- Gửi key 'auxiliaryFee'
      };
      // --- KẾT THÚC SỬA LỖI ---


      // 3. Gọi Service (dùng data JSON)
      final createdOrder = await _orderService.createOrder(apiOrderData);

      // 4. (QUAN TRỌNG) Xóa giỏ hàng ở FE
      cartController.clearCart();

      // 5. Điều hướng đến màn hình xác nhận (dùng data Arguments)
      Get.offNamed(AppRoutes.orderConfirmation, arguments: confirmationArguments);

    } catch (e) {
      Get.snackbar("Đặt hàng thất bại", e.toString().replaceFirst("Exception: ", ""),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }
}