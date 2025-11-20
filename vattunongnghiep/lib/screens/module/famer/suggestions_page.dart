import 'package:flutter/material.dart';

import '../../../models/chat_response_model.dart' hide CsvResult;
import '../../../models/message.dart';
import '../../../services/chatbox_ai_service.dart';
import '../../../shared/widgets/suggestions_bottom_sheet.dart';


class SuggestionsPage extends StatefulWidget {
  final Message message;

  const SuggestionsPage({super.key, required this.message});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  List<CsvResult> dynamicSuggestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDynamicSuggestions();
  }

  Future<void> _loadDynamicSuggestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Extract keywords from the message
      final keywords = widget.message.keywords ?? {};

      // Search for suggestions based on keywords
      final response = await ApiService.searchByKeywords(keywords);

      if (response['success'] == true) {
        // Convert response to CsvResult list
        final results = response['results'] as List;
        setState(() {
          dynamicSuggestions = results
              .map(
                (item) => CsvResult(
              crop: item['crop'] ?? '',
              disease: item['disease'] ?? '',
              product: item['product'] ?? '',
              location: item['location'] ?? '',
              farmerRole: item['farmer_role'] ?? '',
              action: item['action'] ?? '',
            ),
          )
              .toList();
        });
      } else {
        // If there's an error, fall back to the original message data
        setState(() {
          dynamicSuggestions = widget.message.csvResults ?? [];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể tải đề xuất mới: ${response['message']}. Hiển thị dữ liệu gốc.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // If there's an error, fall back to the original message data
      setState(() {
        dynamicSuggestions = widget.message.csvResults ?? [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể tải đề xuất mới: $e. Hiển thị dữ liệu gốc.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đề xuất thông minh',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDynamicSuggestions,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SuggestionsBottomSheet(
        csvResults: dynamicSuggestions,
        keywords: widget.message.keywords ?? {},
      ),
    );
  }
}
