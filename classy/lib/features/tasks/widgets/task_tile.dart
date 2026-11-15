import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/classy_card.dart';
import '../../../data/models/task_item.dart';

/// แถวงาน 1 ชิ้น
///
/// - กดช่องสี่เหลี่ยมซ้ายมือ = ติ๊กว่าทำเสร็จ (update)
/// - แตะที่การ์ด            = เปิดฟอร์มแก้ไข (update)
/// - ปัดไปทางซ้าย          = ลบงาน (delete)
class TaskTile extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 22),
          decoration: BoxDecoration(
            color: AppColors.brick,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
        ),
        child: ClassyCard(
          padding: const EdgeInsets.all(16),
          onTap: onEdit,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(context),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.subject.toUpperCase(),
                      style: AppText.label(context, color: overdue ? AppColors.brick : null),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: AppText.serif(context, size: 16).copyWith(
                        // ขีดฆ่าชื่องานถ้าทำเสร็จแล้ว
                        decoration: task.done ? TextDecoration.lineThrough : null,
                        color: task.done
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: overdue
                              ? AppColors.brick
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          task.dueLabel,
                          style: AppText.sans(
                            context,
                            size: 11,
                            color: overdue
                                ? AppColors.brick
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: task.done ? AppColors.forest : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: task.done ? AppColors.forest : Theme.of(context).dividerColor,
            width: 1.4,
          ),
        ),
        child: task.done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
      ),
    );
  }
}
