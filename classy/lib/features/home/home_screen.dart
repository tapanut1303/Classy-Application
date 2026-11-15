import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/thai_date.dart';
import '../../core/widgets/classy_card.dart';
import '../../core/widgets/gold_divider.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_views.dart';
import '../../data/api/weather_api.dart';
import '../../data/models/exam.dart';
import '../../data/models/subject.dart';
import '../../data/models/task_item.dart';
import '../../data/models/weather.dart';
import '../../data/profile_data.dart';
import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/subject_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../exams/exam_schedule_screen.dart';
import '../focus/focus_timer_screen.dart';
import '../notifications/notifications_screen.dart';
import 'widgets/due_soon_list.dart';
import 'widgets/exam_countdown_row.dart';
import 'widgets/up_next_card.dart';
import 'widgets/weather_row.dart';

/// หน้าแรก รวมทุกอย่างที่ต้องรู้ของวันนี้
///
/// หน้านี้ดึงข้อมูลจาก 2 แหล่งพร้อมกัน
///   - ฐานข้อมูล SQLite : วิชา งาน ตารางสอบ
///   - API ภายนอก      : อากาศวันนี้
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _subjectRepo = SubjectRepository();
  final _taskRepo = TaskRepository();
  final _examRepo = ExamRepository();
  final _weatherApi = WeatherApi();

  bool _loading = true;
  double _gpa = 0;
  Weather? _weather; // null ได้ ถ้าโหลดอากาศไม่สำเร็จ
  List<Subject> _todayClasses = [];
  List<TaskItem> _dueSoon = [];
  List<Exam> _upcomingExams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// โหลดข้อมูลทั้งหมดของหน้านี้
  ///
  /// Future.wait = ยิงทุกงานพร้อมกันแล้วรอให้เสร็จครบ
  /// เร็วกว่ารอทีละอันแบบ await ต่อกันเป็นแถว
  Future<void> _loadData() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      _subjectRepo.getByDay(DateTime.now().weekday),
      _taskRepo.getPending(limit: 3),
      _examRepo.getUpcoming(limit: 2),
      _subjectRepo.calculateGpa(),
      _weatherApi.fetchCurrentWeather(),
    ]);

    // mounted = หน้านี้ยังอยู่บนจอไหม ถ้าผู้ใช้กดออกไปแล้วห้าม setState
    if (!mounted) return;

    setState(() {
      _todayClasses = results[0] as List<Subject>;
      _dueSoon = results[1] as List<TaskItem>;
      _upcomingExams = results[2] as List<Exam>;
      _gpa = results[3] as double;
      _weather = results[4] as Weather?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // ดึงลงเพื่อโหลดข้อมูลใหม่ ทั้งจากฐานข้อมูลและ API
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: _loadData,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 18),

        WeatherRow(weather: _weather),
        const GoldDivider(top: 22, bottom: 22),

        // ---- คาบเรียนวันนี้ ----
        const SectionTitle(title: 'Up Next', action: 'FULL SCHEDULE'),
        const SizedBox(height: 12),
        if (_todayClasses.isEmpty)
          Text('วันนี้ไม่มีคาบเรียน', style: AppText.muted(context))
        else
          UpNextCard(subject: _todayClasses.first),
        const SizedBox(height: 26),

        // ---- นับถอยหลังสอบ ----
        SectionTitle(
          title: 'Exams Countdown',
          action: 'ALL EXAMS',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExamScheduleScreen()),
          ),
        ),
        const SizedBox(height: 12),
        ExamCountdownRow(exams: _upcomingExams),
        const SizedBox(height: 26),

        // ---- งานใกล้ถึงกำหนด ----
        const SectionTitle(title: 'Due Soon', action: 'VIEW ALL TASKS'),
        const SizedBox(height: 12),
        DueSoonList(tasks: _dueSoon),
        const SizedBox(height: 26),

        _buildDeanList(),
      ],
    );
  }

  /// แถบบนสุด: คำทักทาย + ปุ่มจับเวลา + ปุ่มแจ้งเตือน
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ThaiDate.full(DateTime.now()), style: AppText.label(context)),
              const SizedBox(height: 6),
              Text(
                'Good morning, ${ProfileData.userFirstName}.',
                style: AppText.serif(context, size: 30),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.timer_outlined, size: 22),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FocusTimerScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, size: 22),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildDeanList() {
    return ClassyCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACADEMIC STANDING', style: AppText.label(context)),
                const SizedBox(height: 6),
                Text("Dean's List Status", style: AppText.serif(context, size: 20)),
                const SizedBox(height: 4),
                Text(
                  _gpa == 0 ? 'ยังไม่มีข้อมูลเกรด' : 'เกรดเฉลี่ยสะสมตอนนี้ผ่านเกณฑ์แล้ว',
                  style: AppText.muted(context),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 1.4),
            ),
            child: Text(
              _gpa == 0 ? '--' : _gpa.toStringAsFixed(2),
              style: AppText.serif(context, size: 18),
            ),
          ),
        ],
      ),
    );
  }

}
