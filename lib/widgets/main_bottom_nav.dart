import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex; // 0 = خانه، 1 = دستیار
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(icon: Icons.home_rounded, label: 'خانه', index: 0),
            const SizedBox(width: 56), // جای FAB شناور
            _navItem(icon: Icons.smart_toy_outlined, label: 'دستیار', index: 1),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final selected = currentIndex == index;
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
