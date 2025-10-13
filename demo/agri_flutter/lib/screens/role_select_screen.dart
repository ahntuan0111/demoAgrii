import 'package:flutter/material.dart';
import 'package:agri_flutter/shared/themes/app_colors.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/role_item.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  static final List<Map<String, dynamic>> roles = [
    {
      'icon': Icons.person_outline,
      'title': 'Nông dân số',
      'desc': 'Mua sắm từ đại lý gần bạn & thiết lập hồ sơ mùa vụ.',
    },
    {
      'icon': Icons.people_outline_outlined,
      'title': 'Tráng nông/Lão nông',
      'desc': 'Chia sẻ sản phẩm – có/không trữ kho.',
    },
    {
      'icon': Icons.storefront_outlined,
      'title': 'Cửa hàng Vật Tư Nông Nghiệp',
      'desc': 'Kết nối cửa hàng hiện hữu, đưa hàng lên Agrii.',
    },
    {
      'icon': Icons.support_agent_outlined,
      'title': 'AI-Agrii & Tổng đài Nhà nông',
      'desc': 'Tư vấn trước-trong-sau mùa vụ, chẩn đoán bệnh.',
    },
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Đơn hàng của bạn',
      'desc': 'Theo dõi vận chuyển, POD & trạng thái giao.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: Get.back,
        ),
        title: const Text(
          'Chọn vai trò',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/images/logo.png', height: 30),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];
          return RoleItem(
            icon: role['icon'],
            title: role['title'],
            description: role['desc'],
            onTap: () {
              // TODO: Gọi controller hoặc Get.toNamed(...)
            },
          );
        },
      ),
    );
  }
}
