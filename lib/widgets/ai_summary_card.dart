import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'calm_card.dart';

class AiSummaryCard extends StatelessWidget {
  final String? summary;
  const AiSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary == null || summary!.trim().isEmpty) return const SizedBox.shrink();

    return CalmCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              summary!,
              style: const TextStyle(fontSize: 15, height: 1.6, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
