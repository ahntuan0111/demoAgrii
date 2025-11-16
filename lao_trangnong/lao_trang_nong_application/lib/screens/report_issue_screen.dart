// screens/report_issue_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_issue_controller.dart';
// (Import AppColors nếu có)

class ReportIssueScreen extends GetView<ReportIssueController> {
  const ReportIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // (Giả sử AppColors)
    const Color kAppGreen = Color(0xFF1B5E20);
    const Color kAppGreyLight = Color(0xFFF0F0F0);
    const Color kAppRed = Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kAppGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Báo sự cố',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Báo cáo sự cố đơn hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // 1. Loại sự cố
              _buildLabel('Loại sự cố'),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedIssueType.value,
                hint: const Text('Chọn loại sự cố'),
                items: controller.issueTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: controller.selectIssueType,
                decoration: _inputDecoration(),
              )),
              const SizedBox(height: 24),

              // 2. Mô tả chi tiết
              _buildLabel('Mô tả chi tiết'),
              TextFormField(
                controller: controller.descriptionController,
                decoration: _inputDecoration(
                    hint: 'Nhập mô tả vấn đề...'),
                maxLines: 4,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 24),

              // 3. Ảnh minh chứng
              _buildLabel('Ảnh minh chứng'),
              Obx(() => _buildImagePicker(kAppGreen)), // Widget chọn ảnh
              const SizedBox(height: 32),

              // 4. Nút Gửi báo cáo
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppRed, // Màu đỏ
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Gửi báo cáo',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              )),
            ],
          ),
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
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Helper cho Input Decoration
  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      fillColor: const Color(0xFFF0F0F0),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Helper cho ô chọn ảnh
  Widget _buildImagePicker(Color kAppGreen) {
    final imageFile = controller.reportImage.value;
    final imageUrl = controller.reportImageUrl.value;

    return InkWell(
      onTap: controller.pickReportImage,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: (imageFile != null) // Ưu tiên hiển thị file local
            ? ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.file(imageFile, fit: BoxFit.cover),
        )
            : (imageUrl != null) // Nếu không có file local, hiển thị URL (đã tải lên)
            ? ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        )
            : Center( // Nếu chưa có gì
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, color: kAppGreen, size: 30),
              const SizedBox(height: 8),
              Text('Chụp / Tải ảnh', style: TextStyle(color: kAppGreen)),
            ],
          ),
        ),
      ),
    );
  }
}