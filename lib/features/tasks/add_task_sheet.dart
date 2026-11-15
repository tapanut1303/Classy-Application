import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/thai_date.dart';
import '../../core/widgets/classy_button.dart';
import '../../core/widgets/classy_text_field.dart';
import '../../data/models/subject.dart';
import '../../data/models/task_item.dart';
import '../../data/repositories/subject_repository.dart';
import '../../data/repositories/task_repository.dart';

/// เปิดฟอร์มเพิ่ม/แก้ไขงาน คืนค่า true ถ้าบันทึกสำเร็จ
Future<bool?> showAddTaskSheet(BuildContext context, {TaskItem? existing}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddTaskSheet(existing: existing),
  );
}

class _AddTaskSheet extends StatefulWidget {
  final TaskItem? existing;

  const _AddTaskSheet({this.existing});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _taskRepo = TaskRepository();
  final _subjectRepo = SubjectRepository();

  late final _titleController = TextEditingController(text: widget.existing?.title);

  // กำหนดส่ง ถ้าเป็นงานใหม่ ตั้งเริ่มต้นเป็นพรุ่งนี้ 5 โมงเย็น
  late DateTime _dueDate = widget.existing?.dueDate ?? _defaultDue();

  List<Subject> _subjects = [];
  String? _selectedSubject;
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  static DateTime _defaultDue() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17, 0);
  }

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.existing?.subject;
    _loadSubjects();
  }

  /// ดึงรายชื่อวิชาจากฐานข้อมูลมาทำเป็นตัวเลือกใน dropdown
  Future<void> _loadSubjects() async {
    final subjects = await _subjectRepo.getAll();
    if (!mounted) return;

    setState(() {
      _subjects = subjects;
      // ถ้ายังไม่ได้เลือก ให้เลือกวิชาแรกไว้ก่อน
      _selectedSubject ??= subjects.isEmpty ? null : subjects.first.name;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// เปิดปฏิทินให้เลือกวัน แล้วต่อด้วยนาฬิกาให้เลือกเวลา
  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return; // ผู้ใช้กดยกเลิก
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (!mounted) return;

    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _dueDate.hour,
        time?.minute ?? _dueDate.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'กรุณากรอกชื่องาน');
      return;
    }
    if (_selectedSubject == null) {
      setState(() => _error = 'ยังไม่มีวิชาในระบบ กรุณาเพิ่มวิชาก่อน');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final task = TaskItem(
      id: widget.existing?.id,
      title: _titleController.text.trim(),
      subject: _selectedSubject!,
      dueDate: _dueDate,
      done: widget.existing?.done ?? false,
    );

    if (_isEditing) {
      await _taskRepo.update(task);
    } else {
      await _taskRepo.insert(task);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(_isEditing ? 'EDIT TASK' : 'NEW TASK', style: AppText.label(context)),
            const SizedBox(height: 6),
            Text(_isEditing ? 'แก้ไขงาน' : 'เพิ่มงานใหม่',
                style: AppText.serif(context, size: 28)),
            const SizedBox(height: 22),

            ClassyTextField(
              label: 'ชื่องาน',
              hint: 'เช่น ส่งรายงานบทที่ 3',
              controller: _titleController,
            ),
            const SizedBox(height: 18),

            _buildSubjectPicker(),
            const SizedBox(height: 18),

            _buildDuePicker(),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: AppText.sans(context, size: 12, color: AppColors.brick)),
            ],
            const SizedBox(height: 24),

            ClassyButton(
              label: _saving ? 'กำลังบันทึก...' : 'บันทึกงาน',
              color: AppColors.ink,
              onPressed: _saving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }

  /// เลือกวิชา ดึงรายชื่อมาจากตาราง subjects
  Widget _buildSubjectPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('วิชา', style: AppText.label(context)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSubject,
              isExpanded: true,
              hint: Text('เลือกวิชา', style: AppText.muted(context, size: 14)),
              style: AppText.sans(context, size: 14),
              dropdownColor: Theme.of(context).cardColor,
              items: [
                for (final subject in _subjects)
                  DropdownMenuItem(
                    value: subject.name,
                    child: Text(subject.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) => setState(() => _selectedSubject = value),
            ),
          ),
        ),
      ],
    );
  }

  /// เลือกกำหนดส่ง กดแล้วเปิดปฏิทิน
  Widget _buildDuePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('กำหนดส่ง', style: AppText.label(context)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ThaiDate.shortWithTime(_dueDate),
                    style: AppText.sans(context, size: 14),
                  ),
                ),
                Text(ThaiDate.dueLabel(_dueDate), style: AppText.muted(context)),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
