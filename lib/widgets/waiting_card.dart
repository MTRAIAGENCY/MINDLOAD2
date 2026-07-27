import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/loop.dart';
import 'calm_card.dart';

class WaitingCard extends StatelessWidget {
  final List<Loop> items;
  final VoidCallback onViewAll;
  const WaitingCard({super.key, required this.items, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final shown = items.take(3).toList();

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('در انتظار', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...shown.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.person != null ? '${l.title} — ${l.person}' : l.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (items.length > 3)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerRight),
              child: const Text('مشاهده همه'),
            ),
        ],
      ),
    );
  }
}
