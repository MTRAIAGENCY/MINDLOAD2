import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/loop.dart';
import 'calm_card.dart';

class NextActionCard extends StatelessWidget {
  final Loop? loop;
  final VoidCallback onStart;
  const NextActionCard({super.key, required this.loop, required this.onStart});

  @override
  Widget build(BuildContext context) {
    if (loop == null) {
      return const CalmCard(
        child: Text(
          'مورد فوری وجود ندارد.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقدام بعدی',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            loop!.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              child: const Text('شروع'),
            ),
          ),
        ],
      ),
    );
  }
}
