import 'package:agri_flutter/models/csv_model.dart';
import 'package:agri_flutter/services/chatbox_ai_service.dart';
import 'package:flutter/material.dart';


class MySuggestionsPage extends StatefulWidget {
  const MySuggestionsPage({super.key});

  @override
  State<MySuggestionsPage> createState() => _MySuggestionsPageState();
}

class _MySuggestionsPageState extends State<MySuggestionsPage> {
  List<CsvResult> savedSuggestions = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSavedSuggestions();
  }

  Future<void> _loadSavedSuggestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.getAllSuggestions();
      if (response['success'] == true) {
        final suggestions = response['suggestions'] as List;
        setState(() {
          savedSuggestions = suggestions
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
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<CsvResult> get filteredSuggestions {
    if (searchQuery.isEmpty) {
      return savedSuggestions;
    }

    return savedSuggestions.where((suggestion) {
      final query = searchQuery.toLowerCase();
      return suggestion.crop.toLowerCase().contains(query) ||
          suggestion.disease.toLowerCase().contains(query) ||
          suggestion.product.toLowerCase().contains(query) ||
          suggestion.location.toLowerCase().contains(query) ||
          suggestion.farmerRole.toLowerCase().contains(query) ||
          suggestion.action.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề xuất của tôi'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedSuggestions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm trong đề xuất đã lưu...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Suggestions list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSuggestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có đề xuất nào được lưu',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hãy lưu các đề xuất từ tab "Sản phẩm đề xuất", "Cửa hàng VTNN" hoặc "Lão nông gần bạn"',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSuggestions.length,
                    itemBuilder: (context, index) {
                      return _SavedSuggestionCard(
                        suggestion: filteredSuggestions[index],
                        onDelete: () {
                          // TODO: Implement delete functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Chức năng xóa sẽ được thêm trong phiên bản tiếp theo',
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SavedSuggestionCard extends StatelessWidget {
  final CsvResult suggestion;
  final VoidCallback onDelete;

  const _SavedSuggestionCard({
    required this.suggestion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bookmark,
                    color: Colors.green[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.product,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (suggestion.disease.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Bệnh: ${suggestion.disease}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Details
            if (suggestion.crop.isNotEmpty)
              _buildInfoRow(
                Icons.eco,
                'Cây trồng',
                suggestion.crop,
                Colors.green,
              ),

            if (suggestion.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_on_outlined,
                'Khu vực',
                suggestion.location,
                Colors.blue,
              ),
            ],

            if (suggestion.farmerRole.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.person,
                'Loại',
                suggestion.farmerRole,
                Colors.orange,
              ),
            ],

            if (suggestion.action.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.info_outline,
                'Hành động',
                suggestion.action,
                Colors.purple,
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Show detailed information
                      _showDetails(context, suggestion);
                    },
                    child: const Text('Chi tiết'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, CsvResult suggestion) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.product,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (suggestion.crop.isNotEmpty)
                  _buildInfoRow(
                    Icons.eco,
                    'Cây trồng',
                    suggestion.crop,
                    Colors.green,
                  ),

                if (suggestion.disease.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.healing,
                    'Bệnh',
                    suggestion.disease,
                    Colors.red,
                  ),
                ],

                if (suggestion.location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Khu vực',
                    suggestion.location,
                    Colors.blue,
                  ),
                ],

                if (suggestion.farmerRole.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person,
                    'Loại',
                    suggestion.farmerRole,
                    Colors.orange,
                  ),
                ],

                if (suggestion.action.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.info_outline,
                    'Hành động',
                    suggestion.action,
                    Colors.purple,
                  ),
                ],

                const SizedBox(height: 16),
                const Text(
                  'Thông tin chi tiết:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đây là một đề xuất đã được lưu từ trước. Bạn có thể sử dụng thông tin này để tham khảo trong quá trình canh tác hoặc tìm kiếm các sản phẩm, dịch vụ liên quan.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
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
    );
  }
}
