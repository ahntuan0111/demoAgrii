import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeatherChart extends StatelessWidget {
  const WeatherChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Biểu đồ chính
        SizedBox(
          height: 200,
          width: double.infinity,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 24,
              minY: 0,
              maxY: 10,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),

              lineBarsData: [
                // 🌿 Nhiệt độ (dao động mạnh – “chart chính”)
                LineChartBarData(
                  isCurved: true,
                  color: const Color(0xFF4CAF50),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  preventCurveOverShooting: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50).withOpacity(0.25),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  spots: const [
                    FlSpot(0, 4.2),
                    FlSpot(1, 5.1),
                    FlSpot(2, 6.4),
                    FlSpot(3, 5.9),
                    FlSpot(4, 7.3),
                    FlSpot(5, 6.8),
                    FlSpot(6, 8.1),
                    FlSpot(7, 6.7),
                    FlSpot(8, 8.4),
                    FlSpot(9, 7.5),
                    FlSpot(10, 9.0),
                    FlSpot(11, 7.6),
                    FlSpot(12, 8.8),
                    FlSpot(13, 6.9),
                    FlSpot(14, 8.2),
                    FlSpot(15, 7.1),
                    FlSpot(16, 8.9),
                    FlSpot(17, 7.2),
                    FlSpot(18, 9.1),
                    FlSpot(19, 7.5),
                    FlSpot(20, 8.4),
                    FlSpot(21, 6.8),
                    FlSpot(22, 7.9),
                    FlSpot(23, 6.3),
                    FlSpot(24, 7.5),
                  ],
                ),

                // 💧 Độ ẩm (nhịp nhẹ hơn, nhưng vẫn “lượn” theo sóng)
                LineChartBarData(
                  isCurved: true,
                  color: const Color(0xFF7C4DFF),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  preventCurveOverShooting: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7C4DFF).withOpacity(0.18),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  spots: const [
                    FlSpot(0, 7.2),
                    FlSpot(1, 7.5),
                    FlSpot(2, 7.9),
                    FlSpot(3, 7.2),
                    FlSpot(4, 8.3),
                    FlSpot(5, 7.6),
                    FlSpot(6, 8.0),
                    FlSpot(7, 7.3),
                    FlSpot(8, 8.5),
                    FlSpot(9, 7.8),
                    FlSpot(10, 8.7),
                    FlSpot(11, 7.9),
                    FlSpot(12, 8.4),
                    FlSpot(13, 7.1),
                    FlSpot(14, 8.3),
                    FlSpot(15, 7.5),
                    FlSpot(16, 8.6),
                    FlSpot(17, 7.8),
                    FlSpot(18, 8.9),
                    FlSpot(19, 8.0),
                    FlSpot(20, 8.4),
                    FlSpot(21, 7.2),
                    FlSpot(22, 8.0),
                    FlSpot(23, 7.6),
                    FlSpot(24, 8.2),
                  ],
                ),

                // ☔ Lượng mưa (dao động nhanh, thấp – như gợn sóng)
                LineChartBarData(
                  isCurved: true,
                  color: const Color(0xFF2196F3),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  preventCurveOverShooting: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2196F3).withOpacity(0.2),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  spots: const [
                    FlSpot(0, 4.8),
                    FlSpot(1, 5.5),
                    FlSpot(2, 5.0),
                    FlSpot(3, 5.9),
                    FlSpot(4, 5.1),
                    FlSpot(5, 6.0),
                    FlSpot(6, 4.6),
                    FlSpot(7, 6.4),
                    FlSpot(8, 4.8),
                    FlSpot(9, 6.7),
                    FlSpot(10, 5.0),
                    FlSpot(11, 6.3),
                    FlSpot(12, 4.9),
                    FlSpot(13, 6.5),
                    FlSpot(14, 5.2),
                    FlSpot(15, 6.1),
                    FlSpot(16, 4.8),
                    FlSpot(17, 6.2),
                    FlSpot(18, 5.1),
                    FlSpot(19, 6.5),
                    FlSpot(20, 5.0),
                    FlSpot(21, 6.0),
                    FlSpot(22, 4.9),
                    FlSpot(23, 5.8),
                    FlSpot(24, 4.7),
                  ],
                ),
              ],

              lineTouchData: LineTouchData(enabled: false),
            ),
            duration: const Duration(milliseconds: 1000),
          ),
        ),

        const SizedBox(height: 10),

        // 🕒 Các mốc thời gian (thẳng hàng)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _TimeLabel('6AM'),
              const SizedBox(width: 10),
              _TimeLabel('12PM'),
              const SizedBox(width: 10),
              _TimeLabel('6PM'),
              const SizedBox(width: 10),
              _TimeLabel('12AM'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 📝 Ghi chú màu
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Legend(color: Color(0xFF4CAF50), label: 'Nhiệt độ'),
            SizedBox(width: 12),
            _Legend(color: Color(0xFF7C4DFF), label: 'Độ ẩm'),
            SizedBox(width: 12),
            _Legend(color: Color(0xFF2196F3), label: 'Lượng mưa'),
          ],
        ),
      ],
    );
  }
}

// 🔸 Nhãn giờ
class _TimeLabel extends StatelessWidget {
  final String label;
  const _TimeLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0E1B0E),
      ),
    );
  }
}

// 🔸 Ghi chú (legend)
class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }
}