// lib/widgets/review_section.dart

import 'package:flutter/material.dart';

class ReviewSection extends StatefulWidget {
  const ReviewSection({super.key});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  double averageRating = 4.5;
  int totalReviews = 120;

  final List<Map<String, dynamic>> ratingDistribution = [
    {'label': '5', 'value': 0.4, 'percentage': '90%'},
    {'label': '4', 'value': 0.3, 'percentage': '80%'},
    {'label': '3', 'value': 0.15, 'percentage': '15%'},
    {'label': '2', 'value': 0.1, 'percentage': '10%'},
    {'label': '1', 'value': 0.05, 'percentage': '5%'},
  ];

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Hảo',
      'date': '2 weeks ago',
      'comment': 'Xẻng bằng thép không gỉ, lưỡi sắc, tay cầm chắc chắn',
      'rating': 5,
      'avatarAsset': 'assets/images/avatar_hao.png',
    },
    {
      'name': 'Chị tư',
      'date': '1 month ago',
      'comment': 'Sản phẩm tốt',
      'rating': 4,
      'avatarAsset': 'assets/images/avatar_tu.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá & Xếp hạng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < averageRating.floor()
                            ? Icons.star
                            : (index < averageRating
                            ? Icons.star_half
                            : Icons.star_border),
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$totalReviews reviews',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: ratingDistribution
                      .map((r) => RatingBar(
                    label: r['label'],
                    value: r['value'],
                    percentage: r['percentage'],
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...reviews.map((r) => Column(
            children: [
              ReviewComment(
                name: r['name'],
                date: r['date'],
                comment: r['comment'],
                rating: r['rating'],
                avatarAsset: r['avatarAsset'],
              ),
              if (r != reviews.last)
                const Divider(height: 32, color: Colors.grey),
            ],
          )),
        ],
      ),
    );
  }
}

class RatingBar extends StatelessWidget {
  final String label;
  final double value;
  final String percentage;

  const RatingBar({
    super.key,
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(percentage,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class ReviewComment extends StatelessWidget {
  final String name;
  final String date;
  final String comment;
  final int rating;
  final String avatarAsset;

  const ReviewComment({
    super.key,
    required this.name,
    required this.date,
    required this.comment,
    required this.rating,
    required this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(avatarAsset),
              onBackgroundImageError: (_, __) {},
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
                (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.green,
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(comment, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
