import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/classy_card.dart';
import '../../../data/models/subject.dart';

/// การ์ดคาบเรียนถัดไป มีแถบสีประจำวิชาอยู่ด้านซ้าย
class UpNextCard extends StatelessWidget {
  final Subject subject;

  const UpNextCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return ClassyCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // แถบสีประจำวิชา
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: subject.color,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subject.timeRange}  ·  ห้อง ${subject.room}',
                      style: AppText.label(context),
                    ),
                    const SizedBox(height: 8),
                    Text(subject.name, style: AppText.serif(context, size: 19)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // วงกลมตัวอักษรย่อแทนรูปอาจารย์
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: subject.color,
                          child: Text(
                            subject.lecturer.substring(0, 1),
                            style: AppText.sans(context, size: 10, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(subject.lecturer, style: AppText.muted(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
