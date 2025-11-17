import 'package:flutter/material.dart';

import '../../../models/chat_history_item_model.dart';


class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  // --- STATE VARIABLES ---

  // Biến lưu trữ bộ lọc thời gian đang được chọn
  String _selectedFilter = 'Hôm nay';

  // Danh sách các cuộc hội thoại (dữ liệu giả lập)
  late List<ChatHistoryItem> _chatHistory;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu giả lập. Sau này bạn sẽ gọi API ở đây.
    _loadChatHistory();
  }

  // Phương thức để tải dữ liệu. Trong tương lai, nó sẽ là một hàm bất đồng bộ gọi API.
  void _loadChatHistory() {
    setState(() {
      _chatHistory = [
        ChatHistoryItem(id: '1', title: 'Bệnh cây lúa', lastMessage: 'Cây lỳ bị đốm vàng, lá khô', timestamp: '10:30', iconAsset: 'assets/icons/ai_bot_icon.png'),
        ChatHistoryItem(id: '2', title: 'Tính liều thuốc', lastMessage: 'Liều lượng thuốc cho bò', timestamp: '11:15', iconAsset: 'assets/icons/ai_bot_icon_2.png'),
        ChatHistoryItem(id: '3', title: 'Gợi ý phân bón', lastMessage: 'Phân bón cho cây điều', timestamp: '12:45', iconAsset: 'assets/icons/ai_bot_icon_3.png'),
      ];
    });
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Lịch sử chat', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.eco, color: Colors.green[700]),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Bar ---
            _buildSearchBar(),
            const SizedBox(height: 24),

            // --- "Gần đây" Header ---
            const Text('Gần đây', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // --- Filter Chips & Dropdown ---
            _buildFilters(),
            const SizedBox(height: 24),

            // --- Chat History List ---
            Expanded(
              child: ListView.separated(
                itemCount: _chatHistory.length + 1, // +1 cho item "Bắt đầu hội thoại mới"
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildNewChatItem();
                  }
                  final item = _chatHistory[index - 1];
                  return _buildHistoryItem(item);
                },
              ),
            ),
          ],
        ),
      ),
      // --- Nút bấm ở dưới cùng ---
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7EF), // Màu nền search bar
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm lịch sử chat',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Hôm nay'),
          _buildFilterChip('7 ngày'),
          _buildFilterChip('30 ngày'),
          const SizedBox(width: 8),
          _buildDropdownFilter(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
            // TODO: Gọi hàm lọc danh sách chat dựa trên `_selectedFilter`
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.green,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildDropdownFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'Theo cây', // Giá trị mặc định
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: <String>['Theo cây', 'Lúa', 'Ngô', 'Khoai']
              .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ))
              .toList(),
          onChanged: (String? newValue) {
            // TODO: Xử lý logic lọc theo cây
          },
        ),
      ),
    );
  }

  Widget _buildNewChatItem() {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: Image.asset('assets/icons/ai_bot_new.png'), // Icon cho "New Chat"
      ),
      title: const Text('Bắt đầu hội thoại mới', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Tôi có thể giúp gì cho bạn?'),
      trailing: const Icon(Icons.add, color: Colors.black, size: 28),
      onTap: () {
        // TODO: Điều hướng đến màn hình chat box mới
      },
    );
  }

  Widget _buildHistoryItem(ChatHistoryItem item) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: Image.asset(item.iconAsset),
      ),
      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(item.lastMessage, overflow: TextOverflow.ellipsis),
      trailing: Text(item.timestamp, style: const TextStyle(color: Colors.grey)),
      onTap: () {
        // TODO: Điều hướng đến màn hình chat box tương ứng với ID `item.id`
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Điều hướng đến màn hình chat box mới
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF17CF17),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Bắt đầu một hội thoại mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}