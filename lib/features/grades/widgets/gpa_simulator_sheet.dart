import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/classy_button.dart';
import '../../../data/models/subject.dart';

/// เปิดหน้าลองคำนวณ GPA แบบสมมติ
///
/// รับรายวิชาจากหน้าที่เรียกมา ไม่ได้อ่านฐานข้อมูลเอง
Future<void> showGpaSimulator(BuildContext context, {required List<Subject> subjects}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GpaSimulatorSheet(subjects: subjects),
  );
}

class _GpaSimulatorSheet extends StatefulWidget {
  final List<Subject> subjects;

  const _GpaSimulatorSheet({required this.subjects});

  @override
  State<_GpaSimulatorSheet> createState() => _GpaSimulatorSheetState();
}

class _GpaSimulatorSheetState extends State<_GpaSimulatorSheet> {
  // เกรดสมมติของแต่ละวิชา เริ่มจากเกรดจริงที่มีอยู่
  late final List<String> _grades =
      widget.subjects.map((subject) => subject.grade).toList();

  /// GPA = ผลรวม(แต้มเกรด x หน่วยกิต) หารด้วย ผลรวมหน่วยกิต
  double get _simulatedGpa {
    var totalPoints = 0.0;
    var totalCredits = 0;

    for (var i = 0; i < widget.subjects.length; i++) {
      final credits = widget.subjects[i].credits;
      totalPoints += (Subject.gradePoints[_grades[i]] ?? 0) * credits;
      totalCredits += credits;
    }

    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GPA SIMULATOR', style: AppText.label(context)),
            const SizedBox(height: 6),
            Text('ลองเปลี่ยนเกรดดู', style: AppText.serif(context, size: 26)),
            const SizedBox(height: 4),
            Text('กดเลือกเกรดที่คิดว่าจะได้ แล้วดูว่า GPA ขยับไปเท่าไหร่',
                style: AppText.muted(context)),
            const SizedBox(height: 20),

            // ตัวเลขอัปเดตทันทีที่กดเปลี่ยนเกรด
            Center(
              child: Text(
                _simulatedGpa.toStringAsFixed(2),
                style: AppText.serif(context, size: 46, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 22),

            for (var i = 0; i < widget.subjects.length; i++) ...[
              Text(widget.subjects[i].name, style: AppText.sans(context, size: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final grade in Subject.gradePoints.keys)
                    GestureDetector(
                      onTap: () => setState(() => _grades[i] = grade),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _grades[i] == grade ? AppColors.gold : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Text(
                          grade,
                          style: AppText.sans(
                            context,
                            size: 11,
                            color: _grades[i] == grade
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
            ],

            ClassyButton(
              label: 'ปิด',
              color: AppColors.ink,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
