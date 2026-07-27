import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'calm_card.dart';

class MentalStatusCard extends StatelessWidget {
  final String message;
  const MentalStatusCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return CalmCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.self_improvement_rounded, color: AppColors.success),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
