import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/crop_advice_card.dart';
import '../../../shared/widgets/spray_card.dart';
import '../../../shared/widgets/weather_chart.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  // Ví dụ: có thể thêm dữ liệu động ở đây
  double rainfall = 10.0;
  double rainfallChange = 5.0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FCF7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Thời tiết & Mùa vụ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E1B0E),
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset('assets/images/logo.png', height: 30),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF17CF17),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Hôm nay"),
              Tab(text: "72h"),
              Tab(text: "7-14 ngày"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TodayWeatherTab(
              rainfall: rainfall,
              rainfallChange: rainfallChange,
              onRefresh: _simulateDataChange,
            ),
            const _WeatherPlaceholderTab(label: "Dự báo 72h"),
            const _WeatherPlaceholderTab(label: "Dự báo 7-14 ngày"),
          ],
        ),
      ),
    );
  }

  // Hàm mô phỏng việc thay đổi dữ liệu (ví dụ: sau khi gọi API)
  void _simulateDataChange() {
    setState(() {
      rainfall = (rainfall + 1) % 20;
      rainfallChange = rainfallChange + 1;
    });
  }
}

class _TodayWeatherTab extends StatelessWidget {
  final double rainfall;
  final double rainfallChange;
  final VoidCallback onRefresh;

  const _TodayWeatherTab({
    required this.rainfall,
    required this.rainfallChange,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mưa/gió",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            "${rainfall.toStringAsFixed(1)}mm",
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          Text(
            "Hôm nay +${rainfallChange.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 14, color: Colors.green),
          ),
          const SizedBox(height: 16),

          const WeatherChart(),
          const SizedBox(height: 28),

          const Text(
            "Cửa sổ phun xịt hôm nay",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF0E1B0E),
            ),
          ),
          const SizedBox(height: 12),

          const SprayCard(
            isGood: true,
            title: "Phun xịt tốt",
            time: "10:00 AM - 12:00 PM",
          ),
          const SprayCard(
            isGood: false,
            title: "Không nên phun xịt",
            time: "12:00 PM - 6:00 PM",
          ),
          const SizedBox(height: 28),

          const Text(
            "Thẻ khuyến nghị theo cây trồng",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF0E1B0E),
            ),
          ),
          const SizedBox(height: 16),

          const CropAdviceCard(
            image: 'assets/images/rice_field.png',
            title: 'Lúa',
            description:
            'Kiểm tra độ ẩm đất.\nNếu đất khô, tưới nước đủ ẩm để đảm bảo sinh trưởng.',
          ),
          const CropAdviceCard(
            image: 'assets/images/coffee_tree.png',
            title: 'Cà phê',
            description:
            'Bảo vệ cây con\nChe chắn khỏi nắng gắt và gió mạnh.',
          ),
          const CropAdviceCard(
            image: 'assets/images/fruit_tree.png',
            title: 'Cây ăn quả',
            description:
            'Tỉa cành\nTỉa cành để cây tập trung dinh dưỡng cho quả.',
          ),
          const SizedBox(height: 28),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onRefresh,
              label: const Text(
                "Đặt nhắc lịch / Cập nhật",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E9F0E),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 1,
                shadowColor: Colors.greenAccent,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _WeatherPlaceholderTab extends StatelessWidget {
  final String label;
  const _WeatherPlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}