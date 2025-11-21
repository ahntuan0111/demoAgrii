import 'dart:convert';

import 'package:agri_flutter/services/chatbox_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onPlus;
  final VoidCallback? onVoice;
  final VoidCallback? onCamera;
  final Function(String, String, String)? onFileSelected;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onPlus,
    this.onVoice,
    this.onCamera,
    this.onFileSelected,
  });

  // Method to trigger file picking from outside
  void pickFile(BuildContext context) {
    final state = context.findAncestorStateOfType<_ChatInputState>();
    if (state != null) {
      state.pickFile();
    }
  }

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  double _plusScale = 1.0;
  bool _isListening = false;
  Map<String, dynamic> _keywords = {};
  bool _isLoadingKeywords = false;
  Set<String> _selectedKeywords = {};

  @override
  void initState() {
    super.initState();
    // Add listener to text controller to extract keywords as user types
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  // Public method to trigger file picking
  void pickFile() {
    _pickFile();
  }

  void _onTextChanged() {
    // Debounce the keyword extraction to avoid too many API calls
    _debounceKeywordExtraction();
  }

  // Simple debounce mechanism
  void _debounceKeywordExtraction() {
    if (_isLoadingKeywords) return;

    // Only extract keywords if text is long enough to be meaningful
    if (widget.controller.text.trim().length > 2) {
      setState(() {
        _isLoadingKeywords = true;
      });

      // Extract keywords after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _extractKeywords(widget.controller.text.trim());
        }
      });
    } else {
      // Clear keywords if text is too short
      setState(() {
        _keywords = {};
        _isLoadingKeywords = false;
      });
    }
  }

  Future<void> _extractKeywords(String text) async {
    try {
      final keywords = await ApiService.extractKeywords(text);
      if (mounted) {
        setState(() {
          _keywords = keywords;
          _isLoadingKeywords = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _keywords = {};
          _isLoadingKeywords = false;
        });
      }
    }
  }

  Widget _buildKeywordBubble(String keyword) {
    final isSelected = _selectedKeywords.contains(keyword);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedKeywords.remove(keyword);
          } else {
            _selectedKeywords.add(keyword);
          }

          // Add the keyword to the text input field
          final currentText = widget.controller.text;
          final separator = currentText.isEmpty ? '' : ' ';
          final newText = '$currentText$separator$keyword';
          widget.controller.text = newText;
          // Move cursor to the end
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: newText.length),
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[700] : Colors.green[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green[800]! : Colors.green[300]!,
            width: 1,
          ),
        ),
        child: Text(
          keyword,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.green[800],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildKeywordBubbles() {
    final List<Widget> bubbles = [];

    // Filter out empty or meaningless keywords
    final excludeKeys = ['model_used'];
    final excludeValues = [
      '',
      ' ',
      'có',
      'là',
      'và',
      'các',
      'có thể',
      'nên',
      'cần',
      'muốn',
      'giúp',
      'hỗ trợ',
      'chào',
      'xin',
      'hello',
      'hi',
    ];

    _keywords.forEach((key, value) {
      if (!excludeKeys.contains(key) &&
          value != null &&
          value.toString().trim().isNotEmpty) {
        final valueStr = value.toString().trim();
        if (valueStr.isNotEmpty &&
            valueStr.length > 1 &&
            !excludeValues.contains(valueStr.toLowerCase())) {
          bubbles.add(_buildKeywordBubble(valueStr));
        }
      }
    });

    return bubbles;
  }

  // Function to handle file picking
  void _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true, // This ensures we get the file data
      );

      if (result != null) {
        final file = result.files.first;
        if (file.bytes != null && widget.onFileSelected != null) {
          // Convert bytes to base64
          final base64Content = base64Encode(file.bytes!);

          // Determine file type more accurately
          String fileType = file.extension ?? 'unknown';
          if (fileType.isEmpty) {
            fileType = 'unknown';
          }

          // Create a proper MIME type based on extension
          String mimeType = _getMimeType(fileType);

          widget.onFileSelected!(
            file.name,
            base64Content,
            mimeType, // Pass the proper MIME type
          );
        }
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Không thể chọn file. Vui lòng thử lại."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper function to get MIME type from file extension
  String _getMimeType(String extension) {
    final mimeTypes = {
      // Images
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'bmp': 'image/bmp',
      'webp': 'image/webp',

      // Documents
      'pdf': 'application/pdf',
      'txt': 'text/plain',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',

      // Audio
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',

      // Video
      'mp4': 'video/mp4',
      'avi': 'video/x-msvideo',
      'mov': 'video/quicktime',
      'wmv': 'video/x-ms-wmv',

      // Other
      'zip': 'application/zip',
      'rar': 'application/vnd.rar',
    };

    return mimeTypes[extension.toLowerCase()] ?? 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keyword suggestions as bubbles (only show if there are meaningful keywords)
          if (_keywords.isNotEmpty && _buildKeywordBubbles().isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 8, // Consistent spacing
                runSpacing: 4, // Consistent run spacing
                children: _buildKeywordBubbles(),
              ),
            ),
          ],
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end, // Align items at the bottom
            children: [
              GestureDetector(
                onTapDown: (_) => setState(() => _plusScale = 0.9),
                onTapUp: (_) {
                  setState(() => _plusScale = 1.0);
                  if (widget.onPlus != null) widget.onPlus!();
                },
                onTapCancel: () => setState(() => _plusScale = 1.0),
                child: Transform.scale(
                  scale: _plusScale,
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 2,
                    ), // Fine-tune vertical alignment
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                  ), // Ensure minimum height
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null, // Allow multiple lines
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: "Nhập thông tin...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      // Add suffix icons inside the text field
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // File attachment icon
                          IconButton(
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              width: 30,
                              height: 30,
                              child: const Icon(
                                Icons.attach_file,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            onPressed: _pickFile,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                          // Camera icon
                          IconButton(
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              width: 30,
                              height: 30,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.green,
                              ),
                            ),
                            onPressed: widget.onCamera,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                          // Microphone icon
                          IconButton(
                            icon: Container(
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? Colors.orange
                                    : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              width: 30,
                              height: 30,
                              child: const Icon(
                                Icons.voice_chat,
                                color: Colors.green,
                              ),
                            ),
                            onPressed: widget.onVoice,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: widget.onSend,
                color: Colors.green,
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
