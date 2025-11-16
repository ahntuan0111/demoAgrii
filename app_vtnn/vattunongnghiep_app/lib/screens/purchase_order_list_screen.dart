// screens/purchase_order_list_screen.dart (BẢN CHỈNH SỬA HOÀN CHỈNH)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/purchase_order_list_controller.dart';
import '../models/purchase_order_model.dart';
// (Import AppColors nếu có)

class PurchaseOrderListScreen extends GetView<PurchaseOrderListController> {
  const PurchaseOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // (Giả sử AppColors)
    const Color kAppBlue = Color(0xFF3B82F6);
    const Color kAppGreen = Color(0xFF1B5E20);
    const Color kAppGrey = Color(0xFFF4F6F5);

    return Scaffold(
      backgroundColor: kAppGrey,
      appBar: AppBar(
        backgroundColor: kAppBlue, // Màu xanh dương
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Nhập hàng từ Agrii',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () { /* TODO: Mở Menu */ },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 1. PHẦN HEADER (TÓM TẮT & NÚT) ---
          _buildHeader(context, kAppGreen),

          // --- 2. DANH SÁCH ĐƠN HÀNG ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: kAppGreen));
              }
              if (controller.poList.isEmpty) {
                return const Center(
                    child: Text("Bạn chưa có đơn đặt hàng nào.",
                        style: TextStyle(fontSize: 16, color: Colors.grey)));
              }

              // Danh sách
              return RefreshIndicator(
                onRefresh: controller.fetchPurchaseOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.poList.length,
                  itemBuilder: (context, index) {
                    final po = controller.poList[index];
                    return _buildPurchaseOrderCard(po);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS CON ---

  // 1. Header (Thẻ đếm, Nút tạo đơn)
  Widget _buildHeader(BuildContext context, Color kAppGreen) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6), // Màu xanh dương
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý đơn đặt hàng và nhập kho',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Thẻ đếm
            Row(
              children: [
                Expanded(child: Obx(() => _buildStatCard('Chờ xử lý', controller.pendingCount.value.toString()))),
                const SizedBox(width: 12),
                Expanded(child: Obx(() => _buildStatCard('Đang giao', controller.shippingCount.value.toString()))),
                const SizedBox(width: 12),
                Expanded(child: Obx(() => _buildStatCard('Đã nhận', controller.completedCount.value.toString()))),
              ],
            ),
            const SizedBox(height: 20),
            // Nút "Tạo đơn"
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.grid_view_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.createNewPurchaseOrder,
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text('Tạo đơn đặt hàng mới', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppGreen.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 2. Thẻ Đơn đặt hàng (PO Card)
  Widget _buildPurchaseOrderCard(PurchaseOrder po) {
    // Logic lấy màu/text cho trạng thái
    Color statusColor = Colors.orange;
    String statusText = 'Chờ xử lý';
    IconData statusIcon = Icons.access_time_filled_outlined;

    switch (po.status) {
      case 'shipped':
        statusText = 'Đang giao';
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      case 'completed':
        statusText = 'Đã nhận';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusText = 'Đã hủy';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
      default:
        statusText = 'Chờ xử lý';
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_filled_outlined;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.viewPurchaseOrderDetail(po),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ✅ SỬA LẠI ĐỂ DÙNG SỐ PO NGẮN ---
                        Text(po.shortPoNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        // ---------------------------------
                        const Text('Agrii Vietnam', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- ✅ SỬA LỖI Ở ĐÂY (dùng totalItemCount) ---
                  Text('${po.totalItemCount} sản phẩm', style: const TextStyle(color: Colors.grey)),
                  // ---------------------------------
                  Text(controller.dateFormatter.format(po.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Thẻ đếm
  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}