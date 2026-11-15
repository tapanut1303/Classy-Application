import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_views.dart';
import '../../data/models/subject.dart';
import '../../data/repositories/subject_repository.dart';
import 'widgets/gpa_chart.dart';
import 'widgets/gpa_simulator_sheet.dart';

/// หน้าเกรด: GPA ที่คำนวณจากข้อมูลจริงในฐานข้อมูล
class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final _repo = SubjectRepository();

  List<Subject> _subjects = [];
  double _gpa = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SubjectRepository.dataChanged.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    SubjectRepository.dataChanged.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final subjects = await _repo.getAll();
    final gpa = await _repo.calculateGpa();
    if (!mounted) return;

    setState(() {
      _subjects = subjects;
      _gpa = gpa;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: _load,
          child: ListView(
            children: [
              ResponsiveLayout(
                child: _loading ? const LoadingView() : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_subjects.isEmpty) {
      return const EmptyView(
        icon: Icons.school_outlined,
        title: 'ยังไม่มีข้อมูลเกรด',
        message: 'เพิ่มวิชาในหน้า Schedule ก่อน แล้วเกรดจะมาโชว์ที่นี่',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ภาคเรียนที่ 2 / 2568', style: AppText.label(context)),
        const SizedBox(height: 6),

        // GPA ตัวใหญ่ คำนวณสดจากวิชาในฐานข้อมูล
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(_gpa.toStringAsFixed(2), style: AppText.serif(context, size: 54)),
            const SizedBox(width: 10),
            Text('เกรดเฉลี่ยสะสม', style: AppText.muted(context)),
          ],
        ),
        const SizedBox(height: 26),

        const SectionTitle(title: 'Performance History'),
        const SizedBox(height: 14),
        const GpaChart(),
        const SizedBox(height: 26),

        _buildTargetCard(),
        const SizedBox(height: 26),

        const SectionTitle(title: 'Term Subject Breakdown'),
        const SizedBox(height: 12),
        _buildSubjectList(),
      ],
    );
  }

  Widget _buildTargetCard() {
    // ต้องทำอีกเท่าไหร่ถึงจะถึง 3.75 (เกณฑ์เกียรตินิยมอันดับหนึ่งทั่วไป)
    final gap = (3.75 - _gpa).clamp(0.0, 4.0);

    return ClassyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GOAL', style: AppText.label(context)),
          const SizedBox(height: 8),
          Text(
            gap == 0
                ? 'เกรดถึงเกณฑ์เกียรตินิยมอันดับหนึ่งแล้ว\nรักษาระดับนี้ไว้ให้ได้'
                : 'อยากได้เกียรตินิยมอันดับหนึ่ง\nต้องดัน GPA ขึ้นอีก ${gap.toStringAsFixed(2)}',
            style: AppText.serif(context, size: 18, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text('ลองเปลี่ยนเกรดดูว่าวิชาไหนขยับ GPA ได้มากที่สุด',
              style: AppText.muted(context)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await showGpaSimulator(context, subjects: _subjects);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('ลองคำนวณดู',
                  style: AppText.sans(context, size: 12, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    return Column(
      children: [
        for (final subject in _subjects)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClassyCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(width: 3, height: 38, color: subject.color),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${subject.code}  ·  ${subject.credits} หน่วยกิต',
                            style: AppText.label(context)),
                        const SizedBox(height: 5),
                        Text(subject.name, style: AppText.serif(context, size: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(subject.grade, style: AppText.serif(context, size: 22)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
