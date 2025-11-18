import 'package:flutter/material.dart';
import '../../models/chat_response_model.dart' hide CsvResult;
import '../../services/chatbox_ai_service.dart';
import '../themes/image_helper.dart';

/// Bottom sheet widget displaying product suggestions with tabs
class SuggestionsBottomSheet extends StatefulWidget {
  final List<CsvResult> csvResults;
  final Map<String, dynamic> keywords;

  const SuggestionsBottomSheet({
    super.key,
    required this.csvResults,
    required this.keywords,
  });

  @override
  State<SuggestionsBottomSheet> createState() => _SuggestionsBottomSheetState();
}

class _SuggestionsBottomSheetState extends State<SuggestionsBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Updated to 4 tabs instead of 3
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar with 4 tabs
        _buildTabBar(),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ProductSuggestionsTab(csvResults: widget.csvResults),
              _StoresTab(csvResults: widget.csvResults),
              _ExpertsTab(csvResults: widget.csvResults),
              _HotlineTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeywordsSection() {
    // Filter out empty or null values
    final validKeywords = widget.keywords.entries
        .where(
          (entry) =>
      entry.value != null &&
          entry.value.toString().isNotEmpty &&
          entry.key != 'model_used',
    )
        .toList();

    if (validKeywords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8, // Consistent spacing
        runSpacing: 4, // Consistent run spacing
        children: validKeywords.map((entry) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[300]!, width: 1),
            ),
            child: Chip(
              label: Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.green[700],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.green[700],
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ), // Reduced from 14 to 13
        tabs: const [
          Tab(text: 'Sản phẩm đề xuất'),
          Tab(text: 'Cửa hàng VTNN'),
          Tab(text: 'Lão nông gần bạn'),
          Tab(text: 'Tổng đài'),
        ],
      ),
    );
  }
}

/// Product suggestions tab
class _ProductSuggestionsTab extends StatelessWidget {
  final List<CsvResult> csvResults;

  const _ProductSuggestionsTab({required this.csvResults});

  @override
  Widget build(BuildContext context) {
    if (csvResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm đề xuất',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: csvResults.length,
      itemBuilder: (context, index) {
        return _ProductCard(result: csvResults[index]);
      },
    );
  }
}

/// Product card widget with enhanced disease image display
class _ProductCard extends StatelessWidget {
  final CsvResult result;

  const _ProductCard({required this.result});

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
            // Product header with disease image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.eco, color: Colors.green[700], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.product,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bệnh: ${result.disease}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Disease image - automatically selected based on disease name
                ImageHelper.buildImageWidget(
                  imagePath: ImageHelper.getDiseaseImage(result.disease),
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.circular(8),
                  placeholderIcon: Icons.image_not_supported,
                  placeholderColor: Colors.grey[400]!,
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Details
            _buildInfoRow(Icons.eco, 'Cây trồng', result.crop, Colors.green),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on_outlined,
              'Khu vực',
              result.location,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.info_outline,
              'Phương pháp chữa trị',
              result.action,
              Colors.orange,
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Show detailed information about the disease
                      _showDiseaseDetails(context, result);
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Tìm hiểu thêm'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Save suggestion functionality
                      try {
                        final response = await ApiService.saveSuggestion(
                          result,
                        );
                        if (response['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã lưu gợi ý thành công'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
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
                            content: Text('Lỗi khi lưu gợi ý: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Lưu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      side: BorderSide(color: Colors.blue[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add to cart functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã thêm "${result.product}" vào giỏ hàng',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('Thêm vào'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
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

  void _showDiseaseDetails(BuildContext context, CsvResult result) {
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
                  'Thông tin chi tiết về ${result.disease}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.eco,
                  'Cây trồng',
                  result.crop,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Khu vực phổ biến',
                  result.location,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.info_outline,
                  'Phương pháp chữa trị',
                  result.action,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả bệnh:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đây là một bệnh phổ biến trên cây. Bệnh thường xuất hiện trong điều kiện thời tiết ẩm ướt và nhiệt độ cao. Các triệu chứng bao gồm lá chuyển màu vàng, xuất hiện đốm nâu hoặc đen trên lá, và có thể dẫn đến chết cây nếu không được xử lý kịp thời.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cách phòng tránh:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Luôn đảm bảo thoát nước tốt cho cây\n2. Tránh tưới nước lên lá vào buổi tối\n3. Thường xuyên kiểm tra và loại bỏ lá bệnh\n4. Sử dụng phân bón cân đối để tăng sức đề kháng cho cây',
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

/// Stores tab with product images
class _StoresTab extends StatefulWidget {
  final List<CsvResult> csvResults;

  const _StoresTab({required this.csvResults});

  @override
  _StoresTabState createState() => _StoresTabState();
}

class _StoresTabState extends State<_StoresTab> {
  List<Map<String, dynamic>> stores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try {
      // Fetch stores from the database
      final response = await ApiService.getAllStores();

      if (response['success'] == true) {
        setState(() {
          stores = List<Map<String, dynamic>>.from(response['stores']);
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load stores');
      }
    } catch (e) {
      print('Error loading stores: $e');
      // No fallback to mock data - use empty list instead
      setState(() {
        stores = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy cửa hàng',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.store,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store['ten_cua_hang'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                store['location'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_searching,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                store['khoang_cach'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: store['con_hang']
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  store['con_hang'] ? 'Còn hàng' : 'Hết hàng',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: store['con_hang']
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bán sản phẩm:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                // Product images - automatically selected based on product names
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: (store['san_pham'] as List)
                        .map(
                          (product) => Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageHelper.buildImageWidget(
                              imagePath: ImageHelper.getProductImage(
                                product,
                              ),
                              width: 40,
                              height: 40,
                              borderRadius: BorderRadius.circular(4),
                              placeholderIcon: Icons.image_not_supported,
                              placeholderColor: Colors.grey[400]!,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                product,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Use SingleChildScrollView to prevent overflow in button row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Direction functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đang mở bản đồ chỉ đường...'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Chỉ đường'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[700],
                          side: BorderSide(color: Colors.blue[300]!),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          // Save store functionality
                          // Create a mock CsvResult for this store
                          final mockResult = CsvResult(
                            crop: '',
                            disease: '',
                            product: store['ten_cua_hang'],
                            location: store['location'],
                            farmerRole: 'Cửa hàng VTNN',
                            action: 'Mua hàng',
                          );

                          try {
                            final response = await ApiService.saveSuggestion(
                              mockResult,
                            );
                            if (response['success']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã lưu cửa hàng thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
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
                                content: Text('Lỗi khi lưu cửa hàng: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Lưu'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[700],
                          side: BorderSide(color: Colors.blue[300]!),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Call functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đang gọi ${store['ten_cua_hang']}...',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Gọi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Order functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đặt hàng tại ${store['ten_cua_hang']}',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart, size: 18),
                        label: const Text('Đặt hàng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Experts tab with farmer images
class _ExpertsTab extends StatefulWidget {
  final List<CsvResult> csvResults;

  const _ExpertsTab({required this.csvResults});

  @override
  _ExpertsTabState createState() => _ExpertsTabState();
}

class _ExpertsTabState extends State<_ExpertsTab> {
  List<Map<String, dynamic>> farmers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    try {
      // Fetch farmers from the database
      final response = await ApiService.getAllFarmers();

      if (response['success'] == true) {
        setState(() {
          farmers = List<Map<String, dynamic>>.from(response['farmers']);
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load farmers');
      }
    } catch (e) {
      print('Error loading farmers: $e');
      // No fallback to mock data - use empty list instead
      setState(() {
        farmers = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (farmers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy lão nông',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        final farmer = farmers[index];
        // Get the first specialty for image selection
        final specialties = farmer['cay_trong_vung'] as List;
        final firstSpecialty = specialties.isNotEmpty
            ? (specialties[0]['cay_trong'] as String)
            : 'lúa'; // default to lúa if no specialty

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Farmer image - automatically selected based on specialty
                    ImageHelper.buildImageWidget(
                      imagePath: ImageHelper.getFarmerImage(firstSpecialty),
                      width: 60,
                      height: 60,
                      borderRadius: BorderRadius.circular(30),
                      placeholderIcon: Icons.person,
                      placeholderColor: Colors.orange[700]!,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${farmer['ten']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${farmer['dia_diem']} • ${farmer['khoang_cach']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.work,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${farmer['kinh_nghiem']} - ${farmer['chuyen_mon']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chuyên môn:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                // Fix overflow by using SingleChildScrollView for the Wrap widget
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8, // Consistent spacing
                    runSpacing: 4, // Consistent run spacing
                    children: (farmer['cay_trong_vung'] as List)
                        .map(
                          (cropInfo) => Container(
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green[300]!,
                            width: 1,
                          ),
                        ),
                        child: Chip(
                          label: Text(
                            '${cropInfo['cay_trong']} (${cropInfo['vung_trong']})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Use SingleChildScrollView to prevent overflow in button row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Chat functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đang mở chat với ${farmer['ten']}...',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat, size: 18),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange[700],
                          side: BorderSide(color: Colors.orange[300]!),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          // Save farmer functionality
                          // Create a mock CsvResult for this farmer
                          final mockResult = CsvResult(
                            crop: (farmer['cay_trong_vung'] as List).isNotEmpty
                                ? (farmer['cay_trong_vung'][0]
                            as Map)['cay_trong']
                                : '',
                            disease: '',
                            product: farmer['ten'],
                            location: farmer['dia_diem'],
                            farmerRole: 'Lão nông',
                            action: 'Tư vấn',
                          );

                          try {
                            final response = await ApiService.saveSuggestion(
                              mockResult,
                            );
                            if (response['success']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã lưu lão nông thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
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
                                content: Text('Lỗi khi lưu lão nông: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Lưu'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange[700],
                          side: BorderSide(color: Colors.orange[300]!),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Call functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đang gọi ${farmer['ten']}...'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Gọi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Order from farmer functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đặt hàng từ ${farmer['ten']}'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart, size: 18),
                        label: const Text('Đặt hàng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Hotline tab
class _HotlineTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Header section with icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_in_talk,
                size: 40,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Tổng đài hỗ trợ nông dân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            const Text(
              'Liên hệ với tổng đài Agri để được tư vấn miễn phí 24/7',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Phone number
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1900 1234',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Chat functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đang mở chat với tổng đài...'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange[700],
                      side: BorderSide(color: Colors.orange[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Call functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đang gọi tổng đài...'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Gọi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Added bottom spacing for consistency
          ],
        ),
      ),
    );
  }
}
