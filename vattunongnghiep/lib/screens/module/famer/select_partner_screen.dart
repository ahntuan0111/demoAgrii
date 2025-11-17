// screens/select_partner_screen.dart (ĐÃ CẬP NHẬT HOÀN CHỈNH)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agri_flutter/controllers/select_partner_controller.dart';
import 'package:agri_flutter/models/nearest_partner_model.dart';
import 'package:intl/intl.dart';

class SelectPartnerScreen extends GetView<SelectPartnerController> {
  const SelectPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text('Chọn Đối tác',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn Quản lý (Lão/Tráng Nông)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => _buildPartnerList(
              context: context, // Thêm context
              state: controller.managerLoadingState.value,
              partners: controller.managerList,
              onSelect: controller.selectManager,
              selectedId: controller.selectedManagerId.value,
              isSaving: controller.isSavingManager.value, // <-- 1. Thêm
              isManager: true,
            )),

            const SizedBox(height: 24),

            const Text(
              'Chọn Cửa hàng (VTNN)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => _buildPartnerList(
              context: context, // Thêm context
              state: controller.storeLoadingState.value,
              partners: controller.storeList,
              onSelect: controller.selectStore,
              selectedId: controller.selectedStoreId.value,
              isSaving: controller.isSavingStore.value, // <-- 2. Thêm
              isManager: false,
            )),
          ],
        ),
      ),
    );
  }

  // --- 3. CẬP NHẬT WIDGET CON ---
  Widget _buildPartnerList({
    required BuildContext context, // Thêm context
    required LoadingState state,
    required List<NearestPartner> partners,
    required Function(String) onSelect,
    required String? selectedId,
    required bool isSaving, // <-- Thêm
    required bool isManager,
  }) {
    final distanceFormatter = NumberFormat("###.0#", "vi_VN");

    if (state == LoadingState.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }
    if (state == LoadingState.error) {
      return const Center(child: Text("Lỗi tải dữ liệu."));
    }
    if (partners.isEmpty) {
      return const Center(child: Text("Không tìm thấy ai gần bạn."));
    }

    // Hiển thị ListView
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: partners.length,
      itemBuilder: (context, index) {
        final partner = partners[index];
        final bool isSelected = selectedId == partner.id;

        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Colors.green[50] : Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? Colors.green : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              )),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        partner.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'Cách ${distanceFormatter.format(partner.distance)} km',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  // Hiển thị SĐT (nếu là VTNN) hoặc Vai trò (nếu là Quản lý)
                  isManager ? (partner.role ?? 'Quản lý') : (partner.phoneNumber ?? 'Không có SĐT'),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const Divider(height: 20),

                // --- 4. CẬP NHẬT NÚT BẤM ĐỂ HIỂN THỊ LOADING ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Vô hiệu hóa nút nếu đang lưu (isSaving)
                    onPressed: isSaving ? null : () => onSelect(partner.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.grey : Colors.green,
                    ),
                    // Hiển thị vòng xoay hoặc text
                    child: (isSaving && selectedId == partner.id) // Nếu đang lưu CHÍNH NÚT NÀY
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isSelected ? 'Đã chọn' : 'Chọn'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}