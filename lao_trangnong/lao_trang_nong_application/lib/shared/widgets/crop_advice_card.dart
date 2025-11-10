import 'package:flutter/material.dart';

class CropAdviceCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const CropAdviceCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final lines = description.split('\n');
    final firstLine = lines.first;
    final remaining = lines.length > 1 ? lines.sublist(1).join('\n') : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  firstLine,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0E1B0E),
                    fontSize: 15,
                  ),
                ),
                if (remaining.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    remaining,
                    style: const TextStyle(
                      color: Colors.lightGreen,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              width: 90,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
