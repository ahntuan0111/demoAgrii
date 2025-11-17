// controllers/cart_controller.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/variant_model.dart';
import '../services/cart_service.dart'; // <-- Dịch vụ API thật

class CartController extends GetxController {
  // 1. INJECT SERVICE THẬT
  final CartService _cartService = Get.find<CartService>();

  var cartItems = <CartItem>[].obs;
  var isLoading = true.obs;
  var subtotal = 0.0.obs;
  var discount = 50000.0.obs; // (Tạm thời hardcode, bạn sẽ làm sau)
  var total = 0.0.obs;
  var isContactlessDelivery = false.obs;

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void onInit() {
    super.onInit();
    fetchCartItems(); // Tải giỏ hàng thật từ API
  }

  // --- LOGIC GỌI API THẬT ---
  Future<void> fetchCartItems() async {
    try {
      isLoading(true);
      var items = await _cartService.getCartItems(); // <-- GỌI API
      cartItems.assignAll(items);
      calculateTotals();
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  /// Hàm này được gọi từ ProductDetailScreen
  Future<void> addToCart(
      Product product, Variant selectedVariant, int quantity) async {
    try {
      // (Bạn có thể thêm 1 biến isLoadingAdd riêng nếu muốn)
      // isLoading(true);

      // 1. GỌI API POST
      final updatedItems = await _cartService.addItem(
        product,
        selectedVariant,
        quantity,
      );

      // 2. Cập nhật UI với giỏ hàng mới
      cartItems.assignAll(updatedItems);
      calculateTotals();

      Get.snackbar("Thành công", "Đã thêm ${product.name} vào giỏ hàng",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
          "Lỗi", "Không thể thêm vào giỏ: ${e.toString().replaceFirst("Exception: ", "")}",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      // isLoading(false);
    }
  }

  Future<void> incrementQuantity(CartItem item) async {
    try {
      int newQuantity = item.quantity + 1;
      final updatedItems =
      await _cartService.updateItemQuantity(item.id, newQuantity);
      cartItems.assignAll(updatedItems);
      calculateTotals();
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật số lượng");
    }
  }

  Future<void> decrementQuantity(CartItem item) async {
    try {
      int newQuantity = item.quantity - 1;
      if (newQuantity < 1) {
        await removeItem(item); // Nếu < 1 thì gọi hàm xóa
      } else {
        final updatedItems =
        await _cartService.updateItemQuantity(item.id, newQuantity);
        cartItems.assignAll(updatedItems);
        calculateTotals();
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật số lượng");
    }
  }

  Future<void> removeItem(CartItem item) async {
    Get.defaultDialog(
      title: "Xác nhận xóa",
      middleText:
      "Bạn có chắc chắn muốn xóa sản phẩm '${item.name}' khỏi giỏ hàng?",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      onConfirm: () async {
        Get.back(); // Đóng dialog
        try {
          final updatedItems = await _cartService.removeItem(item.id);
          cartItems.assignAll(updatedItems);
          calculateTotals();
          Get.snackbar("Thông báo", "Đã xóa ${item.name} khỏi giỏ hàng");
        } catch (e) {
          Get.snackbar("Lỗi", "Không thể xóa sản phẩm");
        }
      },
    );
  }

  // Hàm này dùng để gọi bởi CheckoutController
  void clearCart() {
    cartItems.clear();
    calculateTotals();
    // TODO: Gọi API để xóa giỏ hàng trên server
  }

  void calculateTotals() {
    double currentSubtotal = 0.0;
    for (var item in cartItems) {
      currentSubtotal += item.price * item.quantity;
    }
    subtotal.value = currentSubtotal;
    total.value = subtotal.value - discount.value;
    if (total.value < 0) total.value = 0;
  }

  void toggleContactlessDelivery(bool value) {
    isContactlessDelivery.value = value;
  }
}