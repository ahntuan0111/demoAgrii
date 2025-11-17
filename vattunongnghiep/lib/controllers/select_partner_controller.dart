import 'package:agri_flutter/models/nearest_partner_model.dart';
import 'package:agri_flutter/services/user_service.dart';
import 'package:agri_flutter/routes/app_routes.dart';
import 'package:get/get.dart';

enum LoadingState { loading, success, error }

class SelectPartnerController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  // Tải danh sách
  final managerLoadingState = LoadingState.loading.obs;
  final storeLoadingState = LoadingState.loading.obs;

  final managerList = <NearestPartner>[].obs;
  final storeList = <NearestPartner>[].obs;

  // Trạng thái LƯU (khi nhấn nút "Chọn")
  final isSavingManager = false.obs;
  final isSavingStore = false.obs;

  // Biến state để theo dõi đã chọn ai
  final selectedManagerId = Rxn<String>();
  final selectedStoreId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchNearestPartners();
  }

  Future<void> fetchNearestPartners() async {
    // Chạy song song cả 2 API
    await Future.wait([
      _fetchNearestManagers(),
      _fetchNearestStores(),
    ]);
  }

  Future<void> _fetchNearestManagers() async {
    try {
      managerLoadingState(LoadingState.loading);
      final managers = await _userService.getNearestManagers();
      managerList.assignAll(managers);
      managerLoadingState(LoadingState.success);
    } catch (e) {
      managerLoadingState(LoadingState.error);
      Get.snackbar("Lỗi tải Quản lý", e.toString().replaceFirst("Exception: ", ""));
    }
  }

  Future<void> _fetchNearestStores() async {
    try {
      storeLoadingState(LoadingState.loading);
      final stores = await _userService.getNearestStores();
      storeList.assignAll(stores);
      storeLoadingState(LoadingState.success);
    } catch (e) {
      storeLoadingState(LoadingState.error);
      Get.snackbar("Lỗi tải Cửa hàng", e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // --- ✅ 2. CẬP NHẬT HÀM XỬ LÝ KHI NHẤN "CHỌN" ---

  Future<void> selectManager(String managerId) async {
    isSavingManager(true);
    try {
      // GỌI API PUT
      await _userService.selectManager(managerId);
      selectedManagerId.value = managerId;
      Get.snackbar("Thành công", "Đã chọn Quản lý.");
      // Tự động chuyển đi nếu đã chọn cả 2
      _checkAndNavigate();
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isSavingManager(false);
    }
  }

  Future<void> selectStore(String storeId) async {
    isSavingStore(true);
    try {
      // GỌI API PUT
      await _userService.selectStore(storeId);
      selectedStoreId.value = storeId;
      Get.snackbar("Thành công", "Đã chọn Cửa hàng VTNN.");
      // Tự động chuyển đi nếu đã chọn cả 2
      _checkAndNavigate();
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isSavingStore(false);
    }
  }

  // 3. HÀM KIỂM TRA VÀ ĐIỀU HƯỚNG
  void _checkAndNavigate() {
    if (selectedManagerId.value != null && selectedStoreId.value != null) {
      // Nếu đã chọn cả 2 -> Đi đến màn hình chính
      Get.snackbar(
          "Hoàn tất!",
          "Bạn đã sẵn sàng để bắt đầu.",
          snackPosition: SnackPosition.TOP
      );
      // Dùng offAllNamed để xóa tất cả màn hình đăng ký/chọn
      Get.offAllNamed(AppRoutes.bottomNavigation);
    }
  }
}