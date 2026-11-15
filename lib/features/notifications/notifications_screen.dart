import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_card.dart';
import '../../core/widgets/status_views.dart';
import '../../data/models/app_notification.dart';
import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/task_repository.dart';

/// หน้าแจ้งเตือน
///
/// ไม่ได้มีตารางแจ้งเตือนแยกในฐานข้อมูล
/// แต่สร้างรายการขึ้นมาสด ๆ จากงานและตารางสอบที่ใกล้ถึงกำหนด
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _taskRepo = TaskRepository();
  final _examRepo = ExamRepository();

  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await _taskRepo.getPending();
    final exams = await _examRepo.getUpcoming(limit: 3);
    if (!mounted) return;

    final items = <AppNotification>[];

    // งานที่เลยกำหนดหรือครบกำหนดใน 3 วัน ถือว่าเร่งด่วน
    for (final task in tasks) {
      if (task.isOverdue) {
        items.add(AppNotification(
          title: 'งานเลยกำหนดส่งแล้ว',
          body: '${task.title} (${task.subject})',
          time: task.dueLabel,
          isUrgent: true,
        ));
      } else if (task.isToday) {
        items.add(AppNotification(
          title: 'วันนี้มีงานต้องส่ง',
          body: '${task.title} (${task.subject})',
          time: task.dueLabel,
        ));
      }
    }

    // สอบที่เหลือไม่เกิน 14 วัน
    for (final exam in exams) {
      if (exam.daysLeft <= 14) {
        items.add(AppNotification(
          title: 'ใกล้ถึงวันสอบแล้ว',
          body: '${exam.subject} ห้อง ${exam.room} ที่นั่ง ${exam.seat}',
          time: 'อีก ${exam.daysLeft} วัน',
        ));
      }
    }

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: AppText.serif(context, size: 20)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();

    if (_items.isEmpty) {
      return const EmptyView(
        icon: Icons.notifications_none,
        title: 'ไม่มีการแจ้งเตือน',
        message: 'ยังไม่มีงานหรือการสอบที่ต้องรีบจัดการ',
      );
    }

    return ListView(
      children: [
        ResponsiveLayout(
          topPadding: 8,
          child: Column(
            children: [
              for (final item in _items) _buildTile(item),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile(AppNotification item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClassyCard(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: item.isUrgent ? AppColors.brick : AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: AppText.sans(context, size: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item.body, style: AppText.muted(context)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(item.time, style: AppText.muted(context, size: 10)),
          ],
        ),
      ),
    );
  }
}
