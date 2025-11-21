import 'package:agri_flutter/models/suggestion_model.dart';
import 'package:agri_flutter/services/chatbox_ai_service.dart' show ApiService;
import 'package:flutter/material.dart';

import '../../../models/csv_model.dart';
import '../../../models/message.dart';
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
  SuggestionData? suggestionData; // Add this line

  @override
  void initState() {
    super.initState();
    _loadDynamicSuggestions();
  }

  /// Helper function to check if data contains meaningful keywords
  bool _containsMeaningfulKeyword(dynamic data) {
    if (data == null) return false;

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return false;
      // Filter out generic greetings
      final greetings = [
        'xin chào',
        'hello',
        'hi',
        'chào bạn',
        'chào',
        'good morning',
        'good afternoon',
        'good evening',
      ];
      final lower = trimmed.toLowerCase();
      return !greetings.any((g) => lower.contains(g));
    }

    if (data is bool) return data == true;

    if (data is List) return data.any(_containsMeaningfulKeyword);

    if (data is Map) return data.values.any(_containsMeaningfulKeyword);

    return false;
  }

  Future<void> _loadDynamicSuggestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check if we already have suggestions data in the message
      if (widget.message.suggestions != null &&
          widget.message.suggestions!.isNotEmpty) {
        // Use the existing suggestions data
        setState(() {
          suggestionData = SuggestionData.fromJson(widget.message.suggestions!);
          isLoading = false;
        });
      } else if (widget.message.csvResults != null &&
          widget.message.csvResults!.isNotEmpty) {
        // Use the existing csvResults data
        setState(() {
          dynamicSuggestions = widget.message.csvResults!;
          isLoading = false;
        });
      } else {
        // Extract keywords from the message
        final keywords = widget.message.keywords ?? {};

        // Only search if we have meaningful keywords
        if (_containsMeaningfulKeyword(keywords)) {
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
        } else {
          // No meaningful keywords, use empty list
          setState(() {
            dynamicSuggestions = [];
          });
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // If there's an error, fall back to the original message data
      setState(() {
        dynamicSuggestions = widget.message.csvResults ?? [];
        isLoading = false;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề xuất thông minh', style: TextStyle(fontSize: 18)),
        centerTitle: true,
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
              suggestionData: suggestionData, // Pass suggestionData
            ),
    );
  }
}
