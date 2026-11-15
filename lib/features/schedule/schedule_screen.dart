import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/thai_date.dart';
import '../../core/widgets/status_views.dart';
import '../../data/models/subject.dart';
import '../../data/repositories/subject_repository.dart';
import 'add_subject_sheet.dart';
import 'widgets/class_card.dart';
import 'widgets/week_strip.dart';

/// หน้าตารางเรียน อ่านวิชาจากฐานข้อมูลตามวันที่เลือก
///
/// ครบ CRUD:
///   Create -> ปุ่ม Add Subject
///   Read   -> _load()
///   Update -> แตะการ์ดเพื่อแก้ไข
///   Delete -> ปัดการ์ดไปทางซ้าย
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _repo = SubjectRepository();

  int _selectedDay = DateTime.now().weekday; // เริ่มที่วันนี้
  List<Subject> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// อ่านวิชาของวันที่เลือกจากฐานข้อมูล
  Future<void> _load() async {
    setState(() => _loading = true);

    final subjects = await _repo.getByDay(_selectedDay);
    if (!mounted) return;

    setState(() {
      _subjects = subjects;
      _loading = false;
    });
  }

  /// เปลี่ยนวันแล้วโหลดใหม่
  void _selectDay(int day) {
    setState(() => _selectedDay = day);
    _load();
  }

  /// เปิดฟอร์มเพิ่มวิชาใหม่ ถ้าบันทึกสำเร็จให้โหลดตารางใหม่
  Future<void> _addSubject() async {
    final saved = await showAddSubjectSheet(context);
    if (saved == true) _load();
  }

  /// เปิดฟอร์มเดิมแต่ส่งวิชาที่จะแก้เข้าไปด้วย
  Future<void> _editSubject(Subject subject) async {
    final saved = await showAddSubjectSheet(context, existing: subject);
    if (saved == true) _load();
  }

  /// ลบวิชาออกจากฐานข้อมูล พร้อมปุ่มเลิกทำ
  Future<void> _deleteSubject(Subject subject) async {
    await _repo.delete(subject.id!);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ลบ ${subject.name} แล้ว'),
        action: SnackBarAction(
          label: 'เลิกทำ',
          onPressed: () async {
            // บันทึกกลับเข้าไปใหม่ (จะได้ id ใหม่ แต่ข้อมูลเหมือนเดิม)
            await _repo.insert(subject);
            _load();
          },
        ),
      ),
    );

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveLayout(
          bottomPadding: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ThaiDate.monthYear(DateTime.now()), style: AppText.label(context)),
              const SizedBox(height: 6),
              Text('Schedule', style: AppText.serif(context, size: 30)),
              const SizedBox(height: 18),

              WeekStrip(selectedDay: _selectedDay, onSelect: _selectDay),
              const SizedBox(height: 18),

              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.ink,
        onPressed: _addSubject,
        icon: const Icon(Icons.add, size: 18, color: Colors.white),
        label: Text('Add Subject',
            style: AppText.sans(context, size: 13, color: Colors.white)),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const LoadingView();

    if (_subjects.isEmpty) {
      return const EmptyView(
        icon: Icons.weekend_outlined,
        title: 'วันนี้ไม่มีคาบเรียน',
        message: 'กดปุ่ม Add Subject ด้านล่างเพื่อเพิ่มวิชาเข้าตาราง',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ValueKey(subject.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteSubject(subject),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 22),
              decoration: BoxDecoration(
                color: AppColors.brick,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
            ),
            child: ClassCard(
              subject: subject,
              onTap: () => _editSubject(subject),
            ),
          ),
        );
      },
    );
  }
}
