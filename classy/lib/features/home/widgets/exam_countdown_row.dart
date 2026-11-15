import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/classy_card.dart';
import '../../../data/models/exam.dart';

/// การ์ดนับถอยหลังสอบวางเรียงกันในแนวนอน
class ExamCountdownRow extends StatelessWidget {
  final List<Exam> exams;

  const ExamCountdownRow({super.key, required this.exams});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return Text('ยังไม่มีตารางสอบ', style: AppText.muted(context));
    }

    return Row(
      children: [
        for (var i = 0; i < exams.length; i++) ...[
          Expanded(child: _buildCard(context, exams[i])),
          // เว้นช่องว่างระหว่างการ์ด ยกเว้นใบสุดท้าย
          if (i < exams.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _buildCard(BuildContext context, Exam exam) {
    return ClassyCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exam.subject.toUpperCase(), style: AppText.label(context)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${exam.daysLeft}', style: AppText.serif(context, size: 30)),
              const SizedBox(width: 5),
              Text('วัน', style: AppText.muted(context)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${exam.monthShort} ${exam.date.day}  ${exam.time}',
              style: AppText.muted(context, size: 11)),
        ],
      ),
    );
  }
}
