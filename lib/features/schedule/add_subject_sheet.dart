import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_button.dart';
import '../../core/widgets/classy_text_field.dart';
import '../../data/models/subject.dart';
import '../../data/api/firestore_database.dart';
import '../../data/repositories/subject_repository.dart';

/// เปิดฟอร์มเพิ่ม/แก้ไขวิชา
///
/// ส่ง existing เข้ามา = โหมดแก้ไข, ไม่ส่ง = โหมดเพิ่มใหม่
/// คืนค่า true ถ้าบันทึกสำเร็จ หน้าที่เรียกจะได้รู้ว่าต้องโหลดข้อมูลใหม่
Future<bool?> showAddSubjectSheet(BuildContext context, {Subject? existing}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddSubjectSheet(existing: existing),
  );
}

class _AddSubjectSheet extends StatefulWidget {
  final Subject? existing;

  const _AddSubjectSheet({this.existing});

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  final _repo = SubjectRepository();

  // controller คือตัวเก็บข้อความในแต่ละช่อง
  late final _nameController = TextEditingController(text: widget.existing?.name);
  late final _codeController = TextEditingController(text: widget.existing?.code);
  late final _roomController = TextEditingController(text: widget.existing?.room);
  late final _lecturerController = TextEditingController(text: widget.existing?.lecturer);
  late final _startController =
      TextEditingController(text: widget.existing?.startTime ?? '13:00');
  late final _endController =
      TextEditingController(text: widget.existing?.endTime ?? '15:30');
  late final _creditsController =
      TextEditingController(text: '${widget.existing?.credits ?? 3}');

  late Set<int> _selectedDays = <int>{...?widget.existing?.days};
  late String _grade = widget.existing?.grade ?? 'A';
  late int _colorIndex = _findColorIndex();

  bool _saving = false;
  String? _error; // ข้อความเตือนตอนกรอกไม่ครบ

  /// โหมดแก้ไขไหม ดูจากว่ามีวิชาเดิมส่งมาหรือเปล่า
  bool get _isEditing => widget.existing != null;

  int _findColorIndex() {
    if (widget.existing == null) return 0;

    final index = AppColors.subjectPalette
        .indexWhere((color) => color.value == widget.existing!.colorValue);

    return index == -1 ? 0 : index;
  }

  @override
  void dispose() {
    // controller ทุกตัวต้องคืนหน่วยความจำ ไม่งั้นจะรั่ว
    _nameController.dispose();
    _codeController.dispose();
    _roomController.dispose();
    _lecturerController.dispose();
    _startController.dispose();
    _endController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  /// ตรวจข้อมูลแล้วบันทึกลงฐานข้อมูล
  Future<void> _save() async {
    // ตรวจก่อนว่ากรอกครบไหม
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'กรุณากรอกชื่อวิชา');
      return;
    }
    if (_selectedDays.isEmpty) {
      setState(() => _error = 'กรุณาเลือกวันที่เรียนอย่างน้อย 1 วัน');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final subject = Subject(
      id: widget.existing?.id, // โหมดแก้ไขจะมี id ติดมาด้วย
      name: _nameController.text.trim(),
      code: _codeController.text.trim().isEmpty ? '-' : _codeController.text.trim(),
      room: _roomController.text.trim().isEmpty ? '-' : _roomController.text.trim(),
      lecturer:
          _lecturerController.text.trim().isEmpty ? '-' : _lecturerController.text.trim(),
      // tryParse คืน null ถ้าแปลงไม่ได้ เลยมี ?? 3 กันพลาด
      credits: int.tryParse(_creditsController.text.trim()) ?? 3,
      grade: _grade,
      colorValue: AppColors.subjectPalette[_colorIndex].value,
      days: _selectedDays.toList()..sort(),
      startTime: _startController.text.trim(),
      endTime: _endController.text.trim(),
    );

    try {
      // มี id = แก้ของเดิม / ไม่มี id = เพิ่มใหม่
      if (_isEditing) {
        await _repo.update(subject);
      } else {
        await _repo.insert(subject);
      }
    } on FirebaseAuthException catch (error) {
      setState(() => _error = 'ต้องเข้าสู่ระบบก่อนบันทึกข้อมูล (${error.code})');
      return;
    } on FirebaseException catch (error) {
      setState(() => _error = 'บันทึก Firebase ไม่สำเร็จ (${error.code}) UID: ${FirestoreDatabase.instance.currentUserId ?? '-'}');
      return;
    } catch (error) {
      setState(() => _error = 'บันทึกข้อมูลไม่สำเร็จ: $error');
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    if (!mounted) return;
    Navigator.pop(context, true); // ส่ง true กลับไปบอกว่าบันทึกแล้ว
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // เว้นที่ให้คีย์บอร์ด ฟอร์มจะได้ไม่โดนบัง
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      // จำกัดความสูงไม่ให้เกิน 90% ของจอ
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

            Text(_isEditing ? 'EDIT CLASS' : 'NEW CLASS', style: AppText.label(context)),
            const SizedBox(height: 6),
            Text(_isEditing ? 'แก้ไขวิชา' : 'Add Subject',
                style: AppText.serif(context, size: 28)),
            const SizedBox(height: 22),

            ClassyTextField(
              label: 'ชื่อวิชา',
              hint: 'Advanced Human-Computer Interaction',
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ClassyTextField(
                    label: 'รหัสวิชา',
                    hint: 'HCI 5021',
                    controller: _codeController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClassyTextField(
                    label: 'ห้องเรียน',
                    hint: 'Studio 301',
                    controller: _roomController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ClassyTextField(
              label: 'อาจารย์ผู้สอน',
              hint: 'Prof. Evelyn Starling',
              controller: _lecturerController,
            ),
            const SizedBox(height: 20),

            Text('วันที่เรียน', style: AppText.label(context)),
            const SizedBox(height: 10),
            _buildDayPicker(),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ClassyTextField(
                    label: 'เวลาเริ่ม',
                    hint: '13:00',
                    controller: _startController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClassyTextField(
                    label: 'เวลาเลิก',
                    hint: '15:30',
                    controller: _endController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ClassyTextField(
                    label: 'หน่วยกิต',
                    hint: '3',
                    controller: _creditsController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildGradePicker()),
              ],
            ),
            const SizedBox(height: 20),

            Text('สีประจำวิชา', style: AppText.label(context)),
            const SizedBox(height: 10),
            _buildColorPicker(),

            // ข้อความเตือนตอนกรอกไม่ครบ
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: AppText.sans(context, size: 12, color: AppColors.brick)),
            ],
            const SizedBox(height: 24),

            ClassyButton(
              label: _saving ? 'กำลังบันทึก...' : 'Save class',
              color: AppColors.ink,
              onPressed: _saving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    const names = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                final day = i + 1;
                // กดซ้ำ = เอาออก, กดใหม่ = เพิ่มเข้า
                if (_selectedDays.contains(day)) {
                  _selectedDays.remove(day);
                } else {
                  _selectedDays.add(day);
                }
              }),
              child: Container(
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedDays.contains(i + 1) ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  names[i],
                  style: AppText.sans(
                    context,
                    size: 11,
                    color: _selectedDays.contains(i + 1)
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          if (i < 6) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildGradePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('เกรดที่ได้', style: AppText.label(context)),
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
              value: _grade,
              isExpanded: true,
              style: AppText.sans(context, size: 14),
              dropdownColor: Theme.of(context).cardColor,
              items: [
                for (final grade in Subject.gradePoints.keys)
                  DropdownMenuItem(value: grade, child: Text(grade)),
              ],
              onChanged: (value) => setState(() => _grade = value ?? 'A'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: [
        for (var i = 0; i < AppColors.subjectPalette.length; i++) ...[
          GestureDetector(
            onTap: () => setState(() => _colorIndex = i),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.subjectPalette[i],
                shape: BoxShape.circle,
                border: Border.all(
                  color: _colorIndex == i
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ],
    );
  }
}
