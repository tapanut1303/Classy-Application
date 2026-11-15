import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../data/models/task_item.dart';

/// รายการงานที่ใกล้ถึงกำหนด
///
/// รับลิสต์เข้ามาจากข้างนอก ไม่ไปอ่านฐานข้อมูลเอง
/// ข้อดีคือเอาไปใช้ซ้ำที่อื่นได้ และเทสต์ง่าย
class DueSoonList extends StatelessWidget {
  final List<TaskItem> tasks;

  const DueSoonList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Text('ไม่มีงานค้างส่ง สบายไปเลย', style: AppText.muted(context));
    }

    return Column(
      children: [
        for (final task in tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // จุดสีแดงถ้าเลยกำหนด สีทองถ้ายังปกติ
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: task.isOverdue ? AppColors.brick : AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(context, size: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Text(task.dueLabel, style: AppText.muted(context, size: 11)),
              ],
            ),
          ),
      ],
    );
  }
}
