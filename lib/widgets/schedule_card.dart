import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/jalali_utils.dart';
import '../models/loop.dart';
import 'calm_card.dart';

class ScheduleCard extends StatelessWidget {
  final List<Loop> items;
  const ScheduleCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('برنامه امروز', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...items.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    l.dueDate != null ? JalaliUtils.formatTime(l.dueDate!) : '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
