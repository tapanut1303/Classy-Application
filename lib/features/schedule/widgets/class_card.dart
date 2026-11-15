import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/classy_card.dart';
import '../../../data/models/subject.dart';

/// การ์ดคาบเรียน 1 คาบ: เวลาอยู่ซ้าย รายละเอียดอยู่ขวา
class ClassCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback? onTap;

  const ClassCard({super.key, required this.subject, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClassyCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.startTime, style: AppText.serif(context, size: 15)),
                const SizedBox(height: 2),
                Text(subject.endTime, style: AppText.muted(context, size: 11)),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 46,
            margin: const EdgeInsets.only(right: 14),
            color: subject.color,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.code, style: AppText.label(context)),
                const SizedBox(height: 5),
                Text(subject.name, style: AppText.serif(context, size: 17)),
                const SizedBox(height: 6),
                Text('${subject.lecturer}  ·  ${subject.room}',
                    style: AppText.muted(context, size: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
