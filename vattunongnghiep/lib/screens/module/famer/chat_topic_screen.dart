import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';


class ChatTopicScreen extends StatefulWidget {
  const ChatTopicScreen({super.key});

  @override
  State<ChatTopicScreen> createState() => _ChatTopicScreenState();
}

class _ChatTopicScreenState extends State<ChatTopicScreen> {
  // --- STATE VARIABLES ---
  String _selectedIndustry = 'Trồng trọt';
  final Set<String> _selectedCrops = {};
  final Set<String> _selectedTopics = {};

  final TextEditingController _textController = TextEditingController();

  // Dữ liệu giả lập cho các lựa chọn
  final List<String> industries = ['Trồng trọt', 'Chăn nuôi', 'Thủy sản'];
  final List<String> crops = ['Lúa', 'Cà phê', 'Sầu riêng', 'Dừa', 'Bưởi'];
  final List<String> topics = ['Bệnh hại', 'Dinh dưỡng', 'Kỹ thuật canh tác', 'Sâu hại', 'Thị trường', 'Phương pháp điều trị'];

  // --- LOGIC ---
  void _onIndustrySelected(String industry) {
    setState(() {
      _selectedIndustry = industry;
    });
  }

  void _onCropToggled(String crop) {
    setState(() {
      if (_selectedCrops.contains(crop)) {
        _selectedCrops.remove(crop);
      } else {
        _selectedCrops.add(crop);
      }
    });
  }

  void _onTopicToggled(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _navigateToChat() {
    // Thu thập tất cả thông tin
    String mainQuery = _textController.text;
    String context = "Chủ đề: $_selectedIndustry. Cây trồng: ${_selectedCrops.join(', ')}. Quan tâm: ${_selectedTopics.join(', ')}.";

    // Nếu người dùng không nhập gì, tạo câu hỏi từ các chip
    if (mainQuery.isEmpty) {
      mainQuery = "Hỗ trợ về $_selectedIndustry, cụ thể là ${_selectedCrops.isNotEmpty ? _selectedCrops.first : 'chung'} về chủ đề ${_selectedTopics.isNotEmpty ? _selectedTopics.first : 'chung'}.";
    }

    // Gửi câu hỏi và bối cảnh (context) đến màn hình chat
    Get.toNamed(AppRoutes.chatBoxHistory, arguments: mainQuery);
  }

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
        title: const Text('Chọn chủ đề & cây/ngành', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Bar ---
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Bạn đang trồng hay nuôi gì?',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // --- Industry Selection ---
            Row(
              children: industries.map((industry) {
                bool isSelected = _selectedIndustry == industry;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onIndustrySelected(industry),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        industry,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // --- Cây trồng/Vật nuôi ---
            const Text('Cây trồng/Vật nuôi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: crops.map((crop) => _buildFilterChip(
                label: crop,
                isSelected: _selectedCrops.contains(crop),
                onSelected: () => _onCropToggled(crop),
              )).toList(),
            ),
            const SizedBox(height: 24),

            // --- Chủ đề quan tâm ---
            const Text('Chủ đề quan tâm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: topics.map((topic) => _buildFilterChip(
                label: topic,
                isSelected: _selectedTopics.contains(topic),
                onSelected: () => _onTopicToggled(topic),
              )).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildContinueButton(),
    );
  }

  // Widget helper cho các chip
  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onSelected}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(),
      backgroundColor: Colors.white,
      selectedColor: Colors.green.withOpacity(0.1),
      labelStyle: TextStyle(color: isSelected ? Colors.green[800] : Colors.black87),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.green : Colors.grey[300]!),
      ),
      showCheckmark: false,
    );
  }

  // Nút Tiếp tục
  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: _navigateToChat, // Gọi hàm điều hướng
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF17CF17),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Tiếp tục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}