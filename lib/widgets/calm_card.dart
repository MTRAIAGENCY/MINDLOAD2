import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// کارت پایه‌ی مورد استفاده در سراسر اپ — گوشه‌ی گرد بزرگ، سایه‌ی خیلی کم
class CalmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CalmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
