import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_button.dart';
import 'goodbye_screen.dart';

/// กล่องยืนยันก่อนออกจากระบบ
///
/// วิธีเรียกใช้จากหน้าไหนก็ได้:  showLogoutDialog(context);
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ไอคอนหน้าเศร้า
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.magenta.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sentiment_dissatisfied_outlined,
                  color: AppColors.magenta, size: 28),
            ),
            const SizedBox(height: 18),
            Text('ออกจากระบบ?', style: AppText.serif(context, size: 24)),
            const SizedBox(height: 8),
            Text(
              'ข้อมูลตารางเรียนและงานของคุณจะยังอยู่ครบ\nกลับมาเข้าใหม่ได้ทุกเมื่อ',
              textAlign: TextAlign.center,
              style: AppText.muted(context),
            ),
            const SizedBox(height: 24),

            ClassyButton(
              label: 'ออกจากระบบ',
              color: AppColors.magenta,
              onPressed: () {
                Navigator.pop(dialogContext); // ปิดกล่องก่อน
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const GoodbyeScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 10),
            ClassyButton(
              label: 'ยกเลิก',
              outlined: true,
              color: AppColors.magenta,
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
      ),
    ),
  );
}
