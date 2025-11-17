class ChatHistoryItem {
  final String id;
  final String title;
  final String lastMessage;
  final String timestamp;
  final String iconAsset; // Đường dẫn đến ảnh icon

  ChatHistoryItem({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.iconAsset,
  });
}