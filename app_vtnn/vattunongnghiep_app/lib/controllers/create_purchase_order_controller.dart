// controllers/create_purchase_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vattunongnghiep_app/controllers/purchase_order_list_controller.dart';

import '../models/product_model.dart';
import '../models/variant_model.dart';
import '../services/product_service.dart';
import '../services/purchase_order_service.dart';

class CreatePurchaseOrderController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  final PurchaseOrderService _poService = Get.find<PurchaseOrderService>();

  final isLoading = true.obs;
  final isSubmitting = false.obs; // Loading cho nút "Tạo đơn"

  // --- Danh sách Master ---
  final masterProductList = <Product>[].obs; // Danh sách sản phẩm gốc

  // --- State của Form Thêm ---
  final selectedProduct = Rxn<Product>(); // Sản phẩm đang chọn
  final selectedVariant = Rxn<Variant>(); // Đóng gói đang chọn
  final quantityController = TextEditingController(text: '1');

  // --- DANH SÁCH ĐƠN HÀNG (GIỎ HÀNG) ---
  final orderItems = <Map<String, dynamic>>[].obs;
  final totalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMasterProducts();
  }

  @override
  void onClose() {
    quantityController.dispose();
    super.onClose();
  }

  /// Tải danh sách sản phẩm gốc (Master) từ BE
  Future<void> fetchMasterProducts() async {
    try {
      isLoading(true);
      // Giả sử ProductService có hàm getProducts()
      final products = await _productService.getProducts(category: 'all'); // Lấy tất cả
      masterProductList.assignAll(products);
    } catch (e) {
      Get.snackbar("Lỗi tải sản phẩm", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }

  // --- HÀM XỬ LÝ FORM ---

  /// Khi chọn 1 sản phẩm từ Dropdown
  void onProductSelected(Product? product) {
    selectedProduct.value = product;
    // Tự động chọn variant đầu tiên
    if (product != null && product.variants.isNotEmpty) {
      onVariantSelected(product.variants.first);
    } else {
      selectedVariant.value = null;
    }
  }

  /// Khi chọn 1 "Đóng gói" (Variant)
  void onVariantSelected(Variant? variant) {
    selectedVariant.value = variant;
  }

  /// Nút "+ Thêm sản phẩm"
  void addProductToOrder() {
    if (selectedProduct.value == null || selectedVariant.value == null) {
      Get.snackbar("Lỗi", "Vui lòng chọn sản phẩm và đóng gói.");
      return;
    }
    final int quantity = int.tryParse(quantityController.text) ?? 0;
    if (quantity <= 0) {
      Get.snackbar("Lỗi", "Số lượng phải lớn hơn 0.");
      return;
    }

    // Tạo item (đúng format BE yêu cầu)
    final newItem = {
      "productId": selectedProduct.value!.id,
      "variantName": selectedVariant.value!.name,
      "quantity": quantity,
      // (Thêm 2 trường này chỉ để hiển thị, BE sẽ tự lấy)
      "name": selectedProduct.value!.name,
      "price": selectedVariant.value!.price
    };

    orderItems.add(newItem);
    _calculateTotal();

    // Reset form
    quantityController.text = '1';
    selectedProduct.value = null;
    selectedVariant.value = null;
  }

  /// Xóa 1 sản phẩm khỏi danh sách
  void removeProductFromOrder(int index) {
    orderItems.removeAt(index);
    _calculateTotal();
  }

  /// Tính tổng tiền
  void _calculateTotal() {
    double total = 0;
    for (var item in orderItems) {
      total += (item['price'] * item['quantity']);
    }
    totalAmount.value = total;
  }

  // --- HÀM SUBMIT CHÍNH ---
  Future<void> submitPurchaseOrder() async {
    if (orderItems.isEmpty) {
      Get.snackbar("Lỗi", "Giỏ hàng rỗng. Vui lòng thêm sản phẩm.");
      return;
    }

    isSubmitting(true);
    try {
      // Gọi API POST
      await _poService.createPurchaseOrder(orderItems.toList());

      Get.back(); // Đóng BottomSheet
      Get.snackbar("Thành công", "Đã tạo đơn đặt hàng mới thành công.");
      // Tải lại danh sách PO ở màn hình trước
      if (Get.isRegistered<PurchaseOrderListController>()) {
        Get.find<PurchaseOrderListController>().fetchPurchaseOrders();
      }

    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isSubmitting(false);
    }
  }
}