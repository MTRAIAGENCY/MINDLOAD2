import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/loop_type.dart';
import 'area_detail_screen.dart';

class LifeAreasScreen extends StatelessWidget {
  const LifeAreasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('حوزه‌های زندگی')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.3,
        ),
        itemCount: LifeArea.values.length,
        itemBuilder: (context, i) {
          final area = LifeArea.values[i];
          return Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AreaDetailScreen(area: area)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14)),
                      child: Icon(area.icon, color: AppColors.primary, size: 22),
                    ),
                    Text(area.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
