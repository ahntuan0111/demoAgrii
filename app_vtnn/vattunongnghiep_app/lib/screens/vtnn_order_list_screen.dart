// screens/vtnn_order_list_screen.dart (ĐÃ SỬA LỖI OBX)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vtnn_order_list_controller.dart';
import '../models/vtnn_order_model.dart';
// (Import AppColors nếu có)

class VtnnOrderListScreen extends GetView<VtnnOrderListController> {
  const VtnnOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // (Giả sử AppColors)
    const Color kAppGreen = Color(0xFF1B5E20);
    const Color kAppGrey = Color(0xFFF4F6F5);

    return Scaffold(
      backgroundColor: kAppGrey,
      appBar: AppBar(
        backgroundColor: kAppGrey,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back (vì là tab)
        title: const Text(
          'Đơn hàng',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () { /* TODO: Mở Drawer */ },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // --- 1. THANH TABS FILTER ---
          _buildFilterTabs(),

          // --- 2. DANH SÁCH ĐƠN HÀNG ---
          Expanded(
            child: Obx(() { // <-- Obx này ĐÚNG (vì nó dùng isLoading và filteredOrders)
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: kAppGreen));
              }
              if (controller.filteredOrders.isEmpty) {
                return const Center(
                    child: Text("Không có đơn hàng nào.",
                        style: TextStyle(fontSize: 16, color: Colors.grey)));
              }

              // Danh sách
              return RefreshIndicator(
                onRefresh: controller.fetchAllOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.filteredOrders[index];
                    return _buildOrderCard(order, kAppGreen);
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

  // 1. Thanh Tabs Filter (ĐÃ SỬA LỖI)
  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16),
      // --- ✅ SỬA LỖI 1: XÓA Obx() BỌC NGOÀI ---
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.tabs.length, // Dùng list tĩnh (không .obs)
        itemBuilder: (context, index) {
          final tabName = controller.tabs[index];

          // --- ✅ SỬA LỖI 2: CHỈ BỌC Obx() VÀO WIDGET CẦN THAY ĐỔI ---
          return Obx(() {
            final bool isSelected = controller.selectedStatusTab.value == tabName;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(tabName),
                selected: isSelected, // <-- Dùng biến isSelected (đã quan sát)
                onSelected: (bool selected) {
                  if (selected) {
                    controller.filterOrders(tabName);
                  }
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.green[50],
                labelStyle: TextStyle(
                    color: isSelected ? Colors.green.shade900 : Colors.black54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: isSelected ? Colors.green : Colors.transparent),
                ),
              ),
            );
          });
          // --- KẾT THÚC SỬA LỖI 2 ---
        },
      ),
    );
  }

  // 2. Thẻ Đơn hàng (Hàm này giữ nguyên)
  Widget _buildOrderCard(VtnnOrder order, Color kAppGreen) {
    // Logic lấy màu/text cho trạng thái
    Color statusColor = Colors.orange;
    String statusText = 'Chờ xử lý';
    IconData statusIcon = Icons.access_time_filled_outlined;

    switch (order.status) {
      case 'pending_vtnn_prep':
        statusText = 'Chờ xử lý';
        statusColor = Colors.orange.shade700;
        statusIcon = Icons.access_time_filled_outlined;
        break;
      case 'preparing':
        statusText = 'Đang xử lý';
        statusColor = Colors.blue.shade700;
        statusIcon = Icons.inventory_2_outlined;
        break;
      case 'ready_for_pickup':
        statusText = 'Chờ thu tiền';
        statusColor = Colors.purple.shade700;
        statusIcon = Icons.wallet_outlined;
        break;
      case 'awaiting_payment':
        statusText = 'Chờ thu tiền';
        statusColor = Colors.purple.shade700;
        statusIcon = Icons.wallet_outlined;
        break;
      case 'out_for_delivery':
      case 'delivered':
      case 'completed':
        statusText = 'Đã thu tiền';
        statusColor = kAppGreen;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        statusText = 'Đã hủy';
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.viewOrderDetail(order),
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
                        Text(order.shortId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(order.customerName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
                  // Tag LN/TN
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kAppGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        order.managerRoleAbbreviation, // 'LN' hoặc 'TN'
                        style: TextStyle(color: kAppGreen, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ),
                  Text('${order.totalItemCount} SP', style: const TextStyle(color: Colors.grey)),
                  Text(
                      controller.currencyFormatter.format(order.totalPrice),
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}