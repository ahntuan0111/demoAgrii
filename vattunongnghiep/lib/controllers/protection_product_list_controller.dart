// controllers/protection_product_list_controller.dart (ĐÃ CẬP NHẬT)
import 'package:get/get.dart';
import 'package:agri_flutter/models/store_product_model.dart'; // <-- 1. SỬA MODEL
import 'package:agri_flutter/services/product_service.dart';

class ProtectionProductListController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  // --- 2. SỬA KIỂU DANH SÁCH ---
  final RxList<StoreProduct> productList = <StoreProduct>[].obs;
  final _allStoreProducts = <StoreProduct>[].obs; // Cache
  // -----------------------------

  final isLoading = false.obs;
  final isLoadingBrands = false.obs;

  final RxList<String> brands = <String>['Tất cả'].obs;
  final RxString selectedBrand = 'Tất cả'.obs;

  @override
  void onInit() {
    super.onInit();
    // 3. GỌI HÀM LẤY SẢN PHẨM
    fetchStoreProducts();
  }

  // --- 4. VIẾT LẠI HOÀN TOÀN LOGIC LẤY DỮ LIỆU ---

  /// Tải TẤT CẢ sản phẩm từ kho của VTNN (Chỉ 1 lần)
  Future<void> fetchStoreProducts() async {
    try {
      isLoading(true);
      isLoadingBrands(true);

      final allProducts = await _productService.getStoreProducts();
      _allStoreProducts.assignAll(allProducts);

      _fetchBrandsFromCache(); // Lọc Brand
      filterProducts(); // Lọc Product

    } catch (e) {
      Get.snackbar(
        "Lỗi",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
      isLoadingBrands(false);
    }
  }

  /// Lọc Brand từ danh sách sản phẩm đã tải về
  void _fetchBrandsFromCache() {
    // Lấy 'brand' từ các sản phẩm có category là 'protection'
    final fetchedBrands = _allStoreProducts
        .where((p) => p.product.category == 'protection')
        .map((p) => p.product.brand)
        .toSet()
        .toList();
    brands.assignAll(['Tất cả', ...fetchedBrands]);
  }

  /// HÀM LỌC (Client-side)
  void filterProducts() {
    final brandFilter = selectedBrand.value == 'Tất cả' ? null : selectedBrand.value;

    var filteredList = _allStoreProducts.where((storeProduct) {

      // 1. Lọc theo Category
      final bool isCategoryMatch = storeProduct.product.category == 'protection';
      if (!isCategoryMatch) return false;

      // 2. Lọc theo Brand
      if (brandFilter != null) {
        final bool isBrandMatch = storeProduct.product.brand == brandFilter;
        if (!isBrandMatch) return false;
      }
      return true;
    });

    productList.assignAll(filteredList.toList());
  }

  // 5. HÀM CẬP NHẬT FILTER
  void updateBrand(String? newBrand) {
    if (newBrand != null) {
      selectedBrand.value = newBrand;
      filterProducts(); // <-- Gọi hàm lọc (Client-side)
    }
  }
}