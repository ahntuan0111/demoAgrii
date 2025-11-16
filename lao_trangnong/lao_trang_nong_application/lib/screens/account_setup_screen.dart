// screens/account_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/account_setup_controller.dart';
import '../shared/themes/app_colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AccountSetupScreen extends GetView<AccountSetupController> {
  const AccountSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back
        title: const Text('Thiết lập tài khoản',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Phần Header Xanh ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.green,
              child: const Text(
                'Vui lòng cung cấp thông tin cơ bản',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ),

            // --- Phần Form Trắng ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. KHU VỰC HOẠT ĐỘNG (Dropdown)
                    _buildLabel('Khu vực hoạt động *'),
                    Obx(() => DropdownButtonFormField2<String>(
                      value: controller.selectedArea.value,
                      decoration: _inputDecoration(),
                      isExpanded: true,
                      items: controller.areaList.map((String area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(
                            area,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: controller.selectArea,
                      validator: (value) =>
                      value == null ? 'Vui lòng chọn khu vực' : null,
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200, // 👉 Chỉ hiển thị khoảng 4 item (tùy font size)
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    )),
                    const SizedBox(height: 24),

                    // 2. CÂY TRỒNG CHÍNH (Chips)
                    _buildLabel('Cây trồng chính * (chọn tối thiểu 1)'),
                    Obx(() => Wrap(
                      spacing: 8.0, // Khoảng cách ngang
                      runSpacing: 4.0, // Khoảng cách dọc
                      children: controller.cropList.map((crop) {
                        final bool isSelected =
                        controller.selectedCrops.contains(crop);
                        return FilterChip(
                          label: Text(crop),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            controller.toggleCrop(crop);
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: AppColors.lightGreen,
                          checkmarkColor: AppColors.green,
                          labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.green
                                  : Colors.black54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: isSelected
                                    ? AppColors.green
                                    : Colors.grey[300]!),
                          ),
                        );
                      }).toList(),
                    )),
                    Obx(() => Text(
                      'Đã chọn: ${controller.selectedCrops.join(', ')}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    )),
                    const SizedBox(height: 24),

                    // 3. ĐỊA CHỈ (TextField)
                    _buildLabel('Địa chỉ'),
                    TextFormField(
                      controller: controller.addressController,
                      decoration: _inputDecoration(hint: 'Nhập địa chỉ'),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Vui lòng nhập địa chỉ'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // 4. NÚT HOÀN TẤT
                    Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                          : const Text(
                        'Hoàn tất',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper cho Text Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper cho Input Decoration
  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.grey[100],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}