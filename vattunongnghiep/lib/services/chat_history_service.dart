import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class ChatHistoryItem {
  final String id;
  final String title;
  final DateTime timestamp;
  final int messageCount;

  ChatHistoryItem({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.messageCount,
  });
}

class ChatHistoryService {
  static const String _historyKey = 'chat_history_list';
  static const int _maxHistoryItems = 15; // Changed from 50 to 15

  /// Save current chat session to history
  static Future<void> saveCurrentChatSession(List<Message> messages) async {
    if (messages.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load existing history
      final historyList = await _loadHistoryList();

      // Create new history item
      final newHistoryItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'messages': messages.map((msg) => msg.toJson()).toList(),
      };

      // Add new item to the beginning of the list
      historyList.insert(0, newHistoryItem);

      // Limit to max history items (15)
      if (historyList.length > _maxHistoryItems) {
        historyList.removeRange(_maxHistoryItems, historyList.length);
      }

      // Save updated history
      final jsonString = jsonEncode(historyList);
      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      print('Error saving chat session: $e');
    }
  }

  /// Load chat history list
  static Future<List<Map<String, dynamic>>> _loadHistoryList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> historyList = jsonDecode(jsonString);
      return historyList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading history list: $e');
      return [];
    }
  }

  /// Load specific chat session by ID
  static Future<List<Message>> loadChatSession(String id) async {
    try {
      final historyList = await _loadHistoryList();
      final session = historyList.firstWhere(
            (item) => item['id'] == id,
        orElse: () => {},
      );

      if (session.isEmpty) return [];

      final List<dynamic> jsonMessages = session['messages'];
      return jsonMessages
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading chat session: $e');
      return [];
    }
  }

  /// Get list of chat history items for display
  static Future<List<ChatHistoryItem>> getHistoryItems() async {
    try {
      final historyList = await _loadHistoryList();

      return historyList.map((item) {
        final List<dynamic> messages = item['messages'];
        final firstMessage = Message.fromJson(
          messages.first as Map<String, dynamic>,
        );

        return ChatHistoryItem(
          id: item['id'] as String,
          title: firstMessage.content.length > 50
              ? '${firstMessage.content.substring(0, 50)}...'
              : firstMessage.content,
          timestamp: DateTime.parse(item['timestamp'] as String),
          messageCount: messages.length,
        );
      }).toList();
    } catch (e) {
      print('Error getting history items: $e');
      return [];
    }
  }

  /// Delete a specific chat history item by ID
  static Future<void> deleteHistoryItem(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = await _loadHistoryList();

      // Remove the item with the specified ID
      historyList.removeWhere((item) => item['id'] == id);

      // Save updated history
      final jsonString = jsonEncode(historyList);
      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      print('Error deleting history item: $e');
    }
  }

  /// Clear all chat history
  static Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing all history: $e');
    }
  }

  /// Clear current session (don't save it to history)
  static Future<void> clearCurrentSession() async {
    // This is a no-op now since we don't automatically save to a single key
    // The current session is only saved when explicitly requested
  }
}
