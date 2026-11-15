import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_card.dart';
import '../../core/widgets/status_views.dart';
import '../../data/models/exam.dart';
import '../../data/repositories/exam_repository.dart';

/// หน้าตารางสอบ แบ่งเป็นกลางภาค / ปลายภาค อ่านจากตาราง exams
class ExamScheduleScreen extends StatefulWidget {
  const ExamScheduleScreen({super.key});

  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  final _repo = ExamRepository();

  bool _showFinal = false; // false = กลางภาค, true = ปลายภาค
  List<Exam> _exams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final exams = await _repo.getByType(isFinal: _showFinal);
    if (!mounted) return;

    setState(() {
      _exams = exams;
      _loading = false;
    });
  }

  void _switchTab(bool isFinal) {
    setState(() => _showFinal = isFinal);
    _load();
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
        title: Text('Exam Schedule', style: AppText.serif(context, size: 20)),
      ),
      body: ResponsiveLayout(
        topPadding: 0,
        bottomPadding: 0,
        child: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: 20),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          _buildTab('กลางภาค', false),
          _buildTab('ปลายภาค', true),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isFinalTab) {
    final isActive = _showFinal == isFinalTab;

    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(isFinalTab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: AppText.sans(
              context,
              size: 13,
              color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const LoadingView();

    if (_exams.isEmpty) {
      return const EmptyView(
        icon: Icons.event_available_outlined,
        title: 'ยังไม่มีตารางสอบ',
        message: 'ตารางสอบจะขึ้นที่นี่เมื่อมหาวิทยาลัยประกาศ',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 30),
      itemCount: _exams.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildExamCard(_exams[index]),
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    return ClassyCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text('${exam.date.day}', style: AppText.serif(context, size: 30)),
              Text(exam.monthShort, style: AppText.label(context)),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.subject, style: AppText.serif(context, size: 18)),
                const SizedBox(height: 6),
                Text('${exam.time}  ·  ${exam.room}', style: AppText.muted(context, size: 11)),
                const SizedBox(height: 2),
                Text('ที่นั่ง ${exam.seat}', style: AppText.muted(context, size: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                exam.urgencyLabel,
                style: AppText.label(
                  context,
                  color: exam.daysLeft <= 7 ? AppColors.brick : null,
                ),
              ),
              const SizedBox(height: 4),
              Text('เหลือ ${exam.daysLeft} วัน', style: AppText.muted(context, size: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
