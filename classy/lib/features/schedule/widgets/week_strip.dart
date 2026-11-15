import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

/// แถบเลือกวันในสัปดาห์ (จันทร์ - อาทิตย์)
///
/// วันที่ที่โชว์คำนวณจากวันจริงในเครื่อง ไม่ได้ hardcode
/// onSelect จะถูกเรียกพร้อมเลขวัน (1 = จันทร์ ... 7 = อาทิตย์)
class WeekStrip extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onSelect;

  const WeekStrip({super.key, required this.selectedDay, required this.onSelect});

  static const _dayNames = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  /// หาวันจันทร์ของสัปดาห์นี้
  /// DateTime.weekday: จันทร์ = 1 ... อาทิตย์ = 7
  /// ถอยหลังไป (weekday - 1) วัน ก็จะได้วันจันทร์พอดี
  DateTime get _monday {
    final today = DateTime.now();
    return today.subtract(Duration(days: today.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final monday = _monday;
    final todayWeekday = DateTime.now().weekday;

    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i + 1),
              child: _buildDay(
                context,
                index: i,
                date: monday.add(Duration(days: i)),
                isToday: todayWeekday == i + 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDay(
    BuildContext context, {
    required int index,
    required DateTime date,
    required bool isToday,
  }) {
    final isSelected = index + 1 == selectedDay;
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        // วันนี้ที่ยังไม่ได้เลือก จะมีขอบบาง ๆ บอกไว้
        border: isToday && !isSelected ? Border.all(color: AppColors.gold) : null,
      ),
      child: Column(
        children: [
          Text(
            _dayNames[index],
            style: AppText.sans(
              context,
              size: 11,
              color: isSelected ? Colors.white : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: AppText.serif(
              context,
              size: 16,
              color: isSelected ? Colors.white : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
