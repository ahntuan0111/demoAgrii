// controllers/account_setup_controller.dart (ĐÃ THÊM LOG CHI TIẾT)
import 'package:flutter/foundation.dart'; // <-- 1. THÊM IMPORT ĐỂ DÙNG DEBUGPRINT
import '../routes/app_routes.dart';
import '../services/user_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

// --- 1. ĐỊNH NGHĨA MỘT HẰNG SỐ PLACEHOLDER ---
const String kAreaPlaceholder = 'Chọn tỉnh thành';
// ------------------------------------------

class AccountSetupController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final isLoading = false.obs;

  // State cho Form
  final formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();

  // State cho Dropdown (Khu vực)
  // 2. ✅ BẮT ĐẦU VỚI PLACEHOLDER
  final areaList = <String>[kAreaPlaceholder].obs;
  // 3. ✅ GÁN GIÁ TRỊ MẶC ĐỊNH LÀ PLACEHOLDER
  final selectedArea = kAreaPlaceholder.obs; // (Không cần Rxn nữa)

  // State cho Chip (Cây trồng)
  final cropList = [
    'Lúa', 'Ngô', 'Dưa hấu', 'Cà chua', 'Ớt', 'Bắp cải',
    'Rau ăn lá', 'Bí đỏ', 'Đậu các loại', 'Cây ăn trái'
  ];
  final selectedCrops = <String>['Lúa'].obs; // RxList

  @override
  void onInit() {
    super.onInit();
    // 4. ✅ TẢI DANH SÁCH TỈNH VÀO SAU PLACEHOLDER
    areaList.addAll([
      "Hà Nội", "Quảng Ninh", "Lạng Sơn", "Cao Bằng", "Bắc Kạn", "Lào Cai",
      "Điện Biên", "Lai Châu", "Sơn La", "Hòa Bình", "Bắc Giang", "Hải Phòng",
      "Thái Bình", "Hải Dương", "Thanh Hóa", "Nghệ An", "Hà Tĩnh", "Quảng Bình",
      "Đà Nẵng", "Quảng Ngãi", "Khánh Hòa", "Kon Tum", "Gia Lai", "Đắk Lắk",
      "Bình Phước", "TP. Hồ Chí Minh", "Đồng Nai", "Long An", "Cần Thơ",
      "Sóc Trăng", "Đồng Tháp", "An Giang", "Cà Mau"
      // (Bạn có thể để 'Khác' ở cuối nếu muốn)
    ]);
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }

  // --- CÁC HÀM XỬ LÝ UI ---
  void selectArea(String? newValue) {
    if (newValue != null) {
      selectedArea.value = newValue;
    }
  }

  void toggleCrop(String cropName) {
    if (selectedCrops.contains(cropName)) {
      if (selectedCrops.length > 1) {
        selectedCrops.remove(cropName);
      } else {
        Get.snackbar("Thông báo", "Bạn phải chọn ít nhất 1 cây trồng chính.");
      }
    } else {
      selectedCrops.add(cropName);
    }
  }

  // --- HÀM SUBMIT CHÍNH ---
  Future<void> submitProfile() async {
    // 1. Validate Form (Địa chỉ)
    if (!formKey.currentState!.validate()) {
      debugPrint("--- AccountSetupController: Lỗi Validate: Form không hợp lệ.");
      return;
    }

    // 2. ✅ THÊM VALIDATE CHO KHU VỰC
    if (selectedArea.value == kAreaPlaceholder) {
      debugPrint("--- AccountSetupController: Lỗi Validate: Khu vực chưa được chọn.");
      Get.snackbar("Lỗi", "Vui lòng chọn khu vực hoạt động.");
      return;
    }

    // 3. Validate Cây trồng
    if (selectedCrops.isEmpty) {
      debugPrint("--- AccountSetupController: Lỗi Validate: Cây trồng chưa được chọn.");
      Get.snackbar("Lỗi", "Vui lòng chọn ít nhất 1 cây trồng chính.");
      return;
    }

    isLoading(true);

    // --- 4. THÊM LOG DỮ LIỆU GỬI ĐI ---
    final dataToSend = {
      'operatingArea': selectedArea.value,
      'mainCrops': selectedCrops.toList(),
      'address': addressController.text.trim(),
    };
    debugPrint("--- AccountSetupController: Gọi API updateManagerProfile ---");
    debugPrint("Dữ liệu gửi đi: $dataToSend");
    // --------------------------------

    try {
      // 5. Gọi Service
      await _userService.updateManagerProfile(
        operatingArea: selectedArea.value,
        mainCrops: selectedCrops.toList(),
        address: addressController.text.trim(),
      );

      // --- 6. THÊM LOG THÀNH CÔNG ---
      debugPrint("--- AccountSetupController: Cập nhật hồ sơ THÀNH CÔNG ---");
      // -----------------------------

      // 7. Thành công -> Điều hướng
      Get.snackbar("Hoàn tất", "Hồ sơ của bạn đã được cập nhật.");
      Get.offAllNamed(AppRoutes.homePage); // Đi đến màn hình chính

    } catch (e) {
      // --- 8. THÊM LOG LỖI CHI TIẾT ---
      debugPrint("--- AccountSetupController: Lỗi submitProfile (Catch) ---");
      debugPrint("Lỗi: ${e.toString()}");
      // -----------------------------
      Get.snackbar("Lỗi", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading(false);
    }
  }
}