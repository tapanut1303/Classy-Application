import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// วงหมุนตอนกำลังโหลดข้อมูล
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
      ),
    );
  }
}

/// หน้าจอตอนไม่มีข้อมูล บอกผู้ใช้ว่าต้องทำอะไรต่อ
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: AppColors.gold),
            const SizedBox(height: 12),
            Text(title, style: AppText.serif(context, size: 20)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: AppText.muted(context)),
          ],
        ),
      ),
    );
  }
}
