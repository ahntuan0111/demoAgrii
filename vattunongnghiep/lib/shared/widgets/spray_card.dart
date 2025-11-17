import 'package:flutter/material.dart';

class SprayCard extends StatelessWidget {
  final bool isGood;
  final String title;
  final String time;

  const SprayCard({
    super.key,
    required this.isGood,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final Color boxColor = isGood
        ? const Color(0xFFE9F7E9)
        : const Color(0xFFF4F4F4);

    final Color iconColor = const Color(0xFF0E1B0E);
    final Color timeColor = isGood ? const Color(0xFF17CF17) : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isGood ? Icons.check_rounded : Icons.close_rounded,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0E1B0E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 15,
                    color: timeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}