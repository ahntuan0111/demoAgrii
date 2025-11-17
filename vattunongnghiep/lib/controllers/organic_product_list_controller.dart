// controllers/organic_product_list_controller.dart (ĐÃ CẬP NHẬT)
import 'package:get/get.dart';
import 'package:agri_flutter/models/store_product_model.dart'; // <-- 1. SỬA MODEL
import 'package:agri_flutter/services/product_service.dart';

class OrganicProductListController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  // States
  // --- 2. SỬA KIỂU DANH SÁCH ---
  final RxList<StoreProduct> productList = <StoreProduct>[].obs;
  // Danh sách cache (lưu trữ TẤT CẢ sản phẩm từ VTNN)
  final _allStoreProducts = <StoreProduct>[].obs;
  // -----------------------------

  final isLoading = false.obs;
  final isLoadingBrands = false.obs;

  final RxList<String> brands = <String>['Tất cả'].obs;
  final RxString selectedBrand = 'Tất cả'.obs;

  @override
  void onInit() {
    super.onInit();
    // 3. GỌI HÀM LẤY SẢN PHẨM (ĐÃ BAO GỒM LẤY BRAND)
    fetchStoreProducts();
  }

  // --- 4. VIẾT LẠI HOÀN TOÀN LOGIC LẤY DỮ LIỆU ---

  /// Tải TẤT CẢ sản phẩm từ kho của VTNN (Chỉ 1 lần)
  Future<void> fetchStoreProducts() async {
    try {
      isLoading(true);
      isLoadingBrands(true);

      // 1. Gọi hàm service CHÍNH XÁC (từ #211)
      final allProducts = await _productService.getStoreProducts();

      // 2. Lưu vào cache
      _allStoreProducts.assignAll(allProducts);

      // 3. Lọc danh sách Brand từ cache
      _fetchBrandsFromCache();

      // 4. Lọc danh sách sản phẩm lần đầu (chỉ hiển thị 'organic')
      filterProducts();

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
    // Lấy 'brand' từ các sản phẩm có category là 'organic'
    final fetchedBrands = _allStoreProducts
        .where((p) => p.product.category == 'organic')
        .map((p) => p.product.brand)
        .toSet() // Lấy duy nhất
        .toList();

    brands.assignAll(['Tất cả', ...fetchedBrands]);
  }

  /// HÀM LỌC (Client-side)
  /// Hàm này sẽ được gọi bởi fetchStoreProducts() và khi brand thay đổi
  void filterProducts() {
    final brandFilter = selectedBrand.value == 'Tất cả' ? null : selectedBrand.value;

    // Lọc từ danh sách cache (không gọi lại API)
    var filteredList = _allStoreProducts.where((storeProduct) {

      // 1. Lọc theo Category (quan trọng nhất)
      final bool isCategoryMatch = storeProduct.product.category == 'organic';
      if (!isCategoryMatch) return false;

      // 2. Lọc theo Brand (nếu có)
      if (brandFilter != null) {
        final bool isBrandMatch = storeProduct.product.brand == brandFilter;
        if (!isBrandMatch) return false;
      }

      return true; // Vượt qua tất cả
    });

    // Cập nhật danh sách hiển thị
    productList.assignAll(filteredList.toList());
  }

  // 5. HÀM CẬP NHẬT FILTER (Sửa lại để gọi filterProducts)
  void updateBrand(String? newBrand) {
    if (newBrand != null) {
      selectedBrand.value = newBrand;
      filterProducts(); // <-- Gọi hàm lọc (Client-side)
    }
  }
}