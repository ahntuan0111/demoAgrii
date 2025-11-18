import 'package:agri_flutter/screens/module/famer/voice_recorder_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

import '../../../models/message.dart';
import '../../../services/chat_history_service.dart';
import '../../../services/chatbox_ai_service.dart';
import '../../../shared/widgets/chat_input.dart';
import 'camera_screen.dart';
import 'suggestions_page.dart';
import 'my_suggestions_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _serverConnected = false;

  // New variables for pending file
  Map<String, dynamic>? _pendingFile;
  bool _isFilePending = false;

  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;
  AnimationController? _typingController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    );
    // Typing indicator controller (stopped by default)
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Check server health after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServerHealth();
    });
  }

  Future<void> _checkServerHealth() async {
    final isHealthy = await ApiService.checkHealth();

    if (!mounted) return;

    setState(() {
      _serverConnected = isHealthy;
    });

    if (!isHealthy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '⚠️ Không thể kết nối Backend. Vui lòng chạy START_ALL.bat',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: _checkServerHealth,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _fadeController?.dispose();
    _typingController?.dispose();
    super.dispose();
  }

  // Modified function to handle file selection (store file info but don't send immediately)
  void _onFileSelected(String fileName, String base64Content, String fileType) {
    setState(() {
      _pendingFile = {
        'fileName': fileName,
        'fileContent': base64Content,
        'fileType': fileType,
      };
      _isFilePending = true;
    });

    // Show a message that file is ready to be sent
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "File '$fileName' đã được chọn. Nhập tin nhắn và gửi để xử lý.",
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Modified sendMessage to handle pending files
  void _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _isLoading) return;

    // Add user message with file if there's a pending file
    setState(() {
      if (_isFilePending && _pendingFile != null) {
        // Add message with file
        _messages.add(
          Message(
            content: prompt,
            isUser: true,
            fileInfo: {
              'name': _pendingFile!['fileName'],
              'type': _pendingFile!['fileType'],
            },
          ),
        );
        _isFilePending = false;
      } else {
        // Add regular message
        _messages.add(Message(content: prompt, isUser: true));
      }
      _isLoading = true;
      _errorMessage = null;
      // Start typing animation
      _typingController?.repeat();
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // Process file and prompt together if there's a pending file
      if (_pendingFile != null) {
        final response = await ApiService.processFile(
          _pendingFile!['fileName'],
          _pendingFile!['fileContent'],
          _pendingFile!['fileType'],
        );

        // Clear pending file
        setState(() {
          _pendingFile = null;
        });

        // Add AI response
        setState(() {
          _messages.add(
            Message(
              content: response.answer,
              isUser: false,
              keywords: response.keywords,
              csvResultsCount: response.totalFound,
              csvResults: response.csvResults != null
                  ? (response.csvResults as List)
                  .map(
                    (item) =>
                    CsvResult.fromJson(item as Map<String, dynamic>),
              )
                  .toList()
                  : [],
              showSuggestions: response.showSuggestions,
            ),
          );
          _isLoading = false;
        });
      } else {
        // Regular chat processing
        final response = await ApiService.sendChat(prompt);

        // Add AI response
        setState(() {
          _messages.add(
            Message(
              content: response.answer,
              isUser: false,
              keywords: response.keywords,
              csvResultsCount: response.totalFound,
              csvResults: response.csvResults != null
                  ? (response.csvResults as List)
                  .map(
                    (item) =>
                    CsvResult.fromJson(item as Map<String, dynamic>),
              )
                  .toList()
                  : [],
              showSuggestions: response.showSuggestions,
            ),
          );
          _isLoading = false;
        });
      }

      _typingController?.stop();
      _typingController?.value = 0.0;
      _scrollToBottom();
    } catch (e) {
      String errorMsg =
          'Lỗi: Không thể kết nối với AI. Vui lòng kiểm tra server.';

      // Provide more specific error messages
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMsg =
        'Lỗi: Không thể kết nối với Backend (${ApiService.baseUrl}).\n\nVui lòng kiểm tra:\n1. Backend Node.js đã chạy chưa\n2. Port 3000 có bị chiếm không';
      } else if (e.toString().contains('TimeoutException')) {
        errorMsg =
        'Lỗi: Timeout - Server phản hồi quá lâu.\n\nVui lòng kiểm tra:\n1. Python AI Engine (port 8000) đã chạy chưa\n2. OpenAI API key có hợp lệ không';
      } else if (e.toString().contains('Connection refused')) {
        errorMsg =
        'Lỗi: Backend từ chối kết nối.\n\nVui lòng chạy START_ALL.bat để khởi động tất cả services';
      }

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        // Add error message
        _messages.add(Message(content: errorMsg, isUser: false));
      });
      _typingController?.stop();
      _typingController?.value = 0.0;
      _scrollToBottom();

      // Show snackbar with quick help
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Không thể kết nối. Kiểm tra console để biết chi tiết.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  // New function to handle file upload
  void _sendFile(String fileName, String base64Content, String fileType) async {
    // Add user message indicating file upload
    setState(() {
      _messages.add(
        Message(
          content: "📎 Đã gửi file: $fileName",
          isUser: true,
          fileInfo: {'name': fileName, 'type': fileType},
        ),
      );
      _isLoading = true;
      _errorMessage = null;
      // Start typing animation
      _typingController?.repeat();
    });

    _scrollToBottom();

    try {
      // Call backend API to process file
      final response = await ApiService.processFile(
        fileName,
        base64Content,
        fileType,
      );

      // Add AI response with animated text
      setState(() {
        _messages.add(
          Message(
            content: response.answer,
            isUser: false,
            keywords: response.keywords,
            csvResultsCount: response.totalFound,
            csvResults: response.csvResults,
            showSuggestions: response.showSuggestions,
          ),
        );
        _isLoading = false;
      });

      _typingController?.stop();
      _typingController?.value = 0.0;

      _scrollToBottom();
    } catch (e) {
      String errorMsg = 'Lỗi: Không thể xử lý file. Vui lòng kiểm tra server.';

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        // Add error message
        _messages.add(Message(content: errorMsg, isUser: false));
      });
      _typingController?.stop();
      _typingController?.value = 0.0;
      _scrollToBottom();

      // Show snackbar with quick help
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Không thể xử lý file. Kiểm tra console để biết chi tiết.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onPlusPressed() async {
    // Show options when plus button is pressed
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tùy chọn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('Tạo đoạn chat mới'),
                  onTap: () {
                    Navigator.pop(context);
                    _createNewChat();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file, color: Colors.green),
                  title: const Text('Gửi file đính kèm'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show instruction to use the attachment icon
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Vui lòng sử dụng nút đính kèm (📎) trong ô nhập liệu để gửi file",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.green),
                  title: const Text('Xem lịch sử chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _showChatHistory();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createNewChat() async {
    // Show confirmation dialog before creating new chat
    if (_messages.isNotEmpty) {
      final shouldCreateNewChat = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Tạo đoạn chat mới'),
            content: const Text(
              'Bạn có muốn lưu đoạn chat hiện tại vào lịch sử trước khi tạo đoạn chat mới không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(false), // Don't save, just create new
                child: const Text(
                  'Hủy bỏ',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Save and create new
                child: const Text('Lưu và tạo mới'),
              ),
            ],
          );
        },
      );

      if (shouldCreateNewChat == null) return; // Dialog was dismissed

      // Only proceed if user explicitly confirmed
      if (shouldCreateNewChat == true) {
        // Save current chat session
        await ChatHistoryService.saveCurrentChatSession(_messages);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã lưu đoạn chat vào lịch sử"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // User pressed "Hủy bỏ" - do nothing, keep current chat
        return;
      }
    } else {
      // Show confirmation dialog even when there are no messages
      final shouldCreateNewChat = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Tạo đoạn chat mới'),
            content: const Text('Bạn muốn tạo đoạn chat mới?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Tạo mới'),
              ),
            ],
          );
        },
      );

      // Only proceed if user explicitly confirmed
      if (shouldCreateNewChat != true) return;
    }

    // Clear current messages to start a new chat
    setState(() {
      _messages.clear();
      _isLoading = false;
      _errorMessage = null;
    });
  }

  void _showChatHistory() async {
    final historyItems = await ChatHistoryService.getHistoryItems();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 00.6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lịch sử trò chuyện',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            // Delete all history button
                            if (historyItems.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Xóa lịch sử'),
                                        content: const Text(
                                          'Bạn có chắc chắn muốn xóa toàn bộ lịch sử trò chuyện không? Hành động này không thể hoàn tác.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text(
                                              'Xóa',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldDelete == true) {
                                    await ChatHistoryService.clearAllHistory();
                                    // Refresh the history list
                                    final updatedHistoryItems =
                                    await ChatHistoryService.getHistoryItems();
                                    setState(() {});

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Đã xóa toàn bộ lịch sử",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // History list
                  Expanded(
                    child: historyItems.isEmpty
                        ? const Center(
                      child: Text(
                        'Chưa có lịch sử trò chuyện',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: historyItems.length,
                      itemBuilder: (context, index) {
                        final item = historyItems[index];
                        return ListTile(
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${item.messageCount} tin nhắn • ${_formatDateTime(item.timestamp)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => _loadChatSession(item.id),
                          // Add delete button for individual items
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Xóa đoạn chat'),
                                    content: const Text(
                                      'Bạn có chắc chắn muốn xóa đoạn chat này không?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          context,
                                        ).pop(false),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          context,
                                        ).pop(true),
                                        child: const Text(
                                          'Xóa',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldDelete == true) {
                                await ChatHistoryService.deleteHistoryItem(
                                  item.id,
                                );
                                // Refresh the history list
                                final updatedHistoryItems =
                                await ChatHistoryService.getHistoryItems();
                                setState(() {});

                                if (mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text("Đã xóa đoạn chat"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Hôm nay ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _loadChatSession(String id) async {
    // Save current session first if it has messages
    if (_messages.isNotEmpty) {
      await ChatHistoryService.saveCurrentChatSession(_messages);
    }

    // Load selected session
    final messages = await ChatHistoryService.loadChatSession(id);

    if (!mounted) return;

    setState(() {
      _messages.clear();
      _messages.addAll(messages);
      _isLoading = false;
      _errorMessage = null;
    });

    Navigator.pop(context); // Close the bottom sheet
    _scrollToBottom(); // Scroll to bottom to see latest messages

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã tải lại đoạn chat từ lịch sử"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showTopicSelector() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Chọn chủ đề/cây trồng")));
  }

  void _showSuggestions(Message message) {
    // Navigate to dynamic suggestions page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuggestionsPage(message: message),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display file info if this is a file message
            if (message.fileInfo != null) ...[
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      message.fileInfo!['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            // Sử dụng _buildMessageContent cho cả tin nhắn người dùng và AI
            _buildMessageContent(message.content, !message.isUser),
            // Show suggestions button based on backend decision
            if (!message.isUser && message.showSuggestions)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showSuggestions(message);
                  },
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: Text(
                    'Xem đề xuất (${message.csvResults != null ? message.csvResults!.length : 0})',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    // Ensure the controller is properly initialized
    if (_typingController == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'AI Nhà Nông đang suy nghĩ...',
          style: TextStyle(fontSize: 15),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedBuilder(
          animation: _typingController!,
          builder: (context, _) {
            final v = _typingController?.value ?? 0.0;
            final dots = ((v * 3).floor() % 3) + 1;
            return Text(
              'AI Nhà Nông đang suy nghĩ${"." * dots}',
              style: const TextStyle(fontSize: 15),
            );
          },
        ),
      ),
    );
  }

  String _sanitizeAIContent(String content) {
    // Remove metadata line that starts with @keyword_service.py
    content = content.replaceAll(
      RegExp(r'\s*@keyword_service\.py\s+\d+-\d+\s*$', multiLine: false),
      '',
    );

    final lines = content.split('\n');
    final prefixes = [
      'crop:',
      'disease:',
      'product:',
      'location:',
      'farmer_role:',
      'action:',
      'Cây trồng:',
      'Bệnh:',
      'Sản phẩm:',
      'Địa điểm:',
      'Hành động:',
      'Thông tin từ cơ sở dữ liệu:',
      'tìm thấy',
    ];
    final filtered = lines.where((l) {
      final s = l.trim().toLowerCase();
      if (s.isEmpty) return false;
      for (final p in prefixes) {
        if (s.startsWith(p.toLowerCase())) return false;
      }
      if (RegExp(r'^\d+\.\s').hasMatch(s)) return false;
      return true;
    }).toList();
    return filtered.join('\n').trim();
  }

  Widget _buildMessageContent(String content, [bool isAIResponse = false]) {
    // Luôn hiển thị nội dung trực tiếp, không cần hiệu ứng chạy chữ
    content = _sanitizeAIContent(content);
    // Parse markdown-style bold (**text**) for highlighting
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final matches = regex.allMatches(content);

    if (matches.isEmpty) {
      return Text(content, style: const TextStyle(fontSize: 15));
    }

    List<TextSpan> spans = [];
    int currentPosition = 0;

    for (final match in matches) {
      // Add text before match
      if (match.start > currentPosition) {
        spans.add(
          TextSpan(text: content.substring(currentPosition, match.start)),
        );
      }

      // Add highlighted text (the content between **)
      spans.add(
        TextSpan(
          text: match.group(
            1,
          ), // This should be the text between the ** markers
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      );

      currentPosition = match.end;
    }

    // Add remaining text
    if (currentPosition < content.length) {
      spans.add(TextSpan(text: content.substring(currentPosition)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        children: spans,
      ),
    );
  }

  // Add new methods for camera and voice functionality
  void _onCameraPressed() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần quyền truy cập camera để sử dụng tính năng này'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Navigate to camera screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    // Handle the result from camera screen
    if (result != null && result is Map && mounted) {
      setState(() {
        _messages.add(Message(content: result['message'], isUser: true));
        _isLoading = true;
      });

      _scrollToBottom();

      try {
        // Send the analysis result to AI for further processing
        final response = await ApiService.sendChat(result['message']);

        if (mounted) {
          setState(() {
            _messages.add(
              Message(
                content: response.answer,
                isUser: false,
                keywords: response.keywords,
                csvResultsCount: response.totalFound,
                csvResults: response.csvResults,
              ),
            );
            _isLoading = false;
          });

          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _messages.add(
              Message(
                content:
                'Lỗi: Không thể kết nối với AI. Vui lòng kiểm tra server.',
                isUser: false,
              ),
            );
          });

          _scrollToBottom();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không thể kết nối. Kiểm tra console để biết chi tiết.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _onVoicePressed() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cần quyền truy cập microphone để sử dụng tính năng này',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Navigate to voice recorder screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VoiceRecorderScreen()),
    );

    // Handle the result from voice recorder screen
    if (result != null && result is Map && mounted) {
      final transcribedText = result['message'] as String;
      final aiResponse = result['ai_response'] as String?;
      final keywords = result['keywords'] as Map<String, dynamic>?;

      if (transcribedText.isNotEmpty) {
        setState(() {
          // Add user message (transcribed text)
          _messages.add(Message(content: transcribedText, isUser: true));

          // Add AI response if available
          if (aiResponse != null) {
            _messages.add(
              Message(content: aiResponse, isUser: false, keywords: keywords),
            );
          }

          _isLoading =
              aiResponse == null; // Still loading if no AI response yet
        });

        _scrollToBottom();

        // If no AI response was provided, get one now
        if (aiResponse == null) {
          try {
            // Send the transcribed text to AI for processing
            final response = await ApiService.sendChat(transcribedText);

            if (mounted) {
              setState(() {
                _messages.add(
                  Message(
                    content: response.answer,
                    isUser: false,
                    keywords: response.keywords,
                    csvResultsCount: response.totalFound,
                    csvResults: response.csvResults,
                  ),
                );
                _isLoading = false;
              });

              _scrollToBottom();
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _messages.add(
                  Message(
                    content:
                    'Lỗi: Không thể kết nối với AI. Vui lòng kiểm tra server.',
                    isUser: false,
                  ),
                );
              });

              _scrollToBottom();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Không thể kết nối. Kiểm tra console để biết chi tiết.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agrii AI'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
            Navigator.maybePop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MySuggestionsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background logo that's always visible
                Center(
                  child: Opacity(
                    opacity: 0.1, // Faded appearance
                    child: Image.asset(
                      'assets/img/logo.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                // Messages or empty state
                Positioned.fill(
                  child: _messages.isEmpty
                      ? const Center(
                    // child: Text(
                    //   'Nhập thông tin triệu chứng cây trồng của bạn',
                    //   style: TextStyle(color: Colors.grey, fontSize: 16),
                    //   textAlign: TextAlign.center,
                    // ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return _buildTypingBubble();
                      }
                      return _buildMessage(_messages[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Show pending file indicator if there's a file waiting
          if (_isFilePending && _pendingFile != null)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.green[50],
              child: Row(
                children: [
                  Icon(Icons.attach_file, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "File đính kèm: ${_pendingFile!['fileName']}",
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _isFilePending = false;
                        _pendingFile = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ChatInput(
            controller: _controller,
            onSend: _sendMessage,
            onPlus: _onPlusPressed,
            onCamera: _onCameraPressed, // Add camera handler
            onVoice: _onVoicePressed, // Add voice handler
            onFileSelected: _onFileSelected, // Modified file handler
          ),
        ],
      ),
    );
  }
}
