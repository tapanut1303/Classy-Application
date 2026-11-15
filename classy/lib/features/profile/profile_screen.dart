import 'package:flutter/material.dart';
import '../../app.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/gold_divider.dart';
import '../../data/local/app_database.dart';
import '../../data/profile_data.dart';
import '../../data/repositories/subject_repository.dart';
import '../auth/logout_dialog.dart';
import '../notifications/notifications_screen.dart';
import 'about_screen.dart';

/// หน้าโปรไฟล์ + ตั้งค่าแอป
///
/// ตัวเลขสรุปด้านบนคำนวณจากข้อมูลจริงในฐานข้อมูล ไม่ได้ hardcode
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _subjectRepo = SubjectRepository();

  int _subjectCount = 0;
  int _totalCredits = 0;
  double _gpa = 0;

  @override
  void initState() {
    super.initState();
    SubjectRepository.dataChanged.addListener(_loadStats);
    _loadStats();
  }

  @override
  void dispose() {
    SubjectRepository.dataChanged.removeListener(_loadStats);
    super.dispose();
  }

  Future<void> _loadStats() async {
    final subjects = await _subjectRepo.getAll();
    final credits = await _subjectRepo.totalCredits();
    final gpa = await _subjectRepo.calculateGpa();
    if (!mounted) return;

    setState(() {
      _subjectCount = subjects.length;
      _totalCredits = credits;
      _gpa = gpa;
    });
  }

  /// ล้างฐานข้อมูลแล้วใส่ข้อมูลตัวอย่างกลับเข้าไปใหม่
  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('รีเซ็ตข้อมูล?', style: AppText.serif(context, size: 20)),
        content: Text(
          'วิชา งาน และตารางสอบทั้งหมดจะถูกลบ แล้วใส่ข้อมูลตัวอย่างกลับเข้าไปใหม่',
          style: AppText.muted(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('ยกเลิก', style: AppText.muted(context, size: 14)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('รีเซ็ต',
                style: AppText.sans(context, size: 14, color: AppColors.brick)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AppDatabase.instance.resetToSampleData();
    if (!mounted) return;

    _loadStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('รีเซ็ตข้อมูลเรียบร้อย')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            ResponsiveLayout(
              topPadding: 24,
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 14),
                  Text(ProfileData.userName, style: AppText.serif(context, size: 24)),
                  const SizedBox(height: 4),
                  Text(
                    '${ProfileData.studentId}  ·  ${ProfileData.faculty}',
                    style: AppText.muted(context, size: 11),
                  ),
                  const SizedBox(height: 22),

                  _buildStats(),
                  const GoldDivider(top: 22, bottom: 10),

                
                  _buildMenuItem(
                    Icons.notifications_none,
                    'การแจ้งเตือน',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.brightness_6_outlined,
                    'โหมดมืด',
                    trailing: Switch(
                      value: isDark,
                      activeColor: AppColors.gold,
                      onChanged: (value) {
                        themeModeNotifier.value =
                            value ? ThemeMode.dark : ThemeMode.light;
                        setState(() {});
                      },
                    ),
                  ),
      
                  _buildMenuItem(
                    Icons.groups_outlined,
                    'ทีมผู้พัฒนา',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                  _buildMenuItem(Icons.restart_alt, 'รีเซ็ตข้อมูลตัวอย่าง',
                      onTap: _resetData),
                  _buildMenuItem(Icons.info_outline, 'เกี่ยวกับแอป',
                      subtitle: 'v1.0.0', onTap: () {}),

                  const SizedBox(height: 26),
                  TextButton(
                    onPressed: () => showLogoutDialog(context),
                    child: Text('ออกจากระบบ',
                        style: AppText.sans(context, size: 14, color: AppColors.magenta)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withOpacity(0.18),
        border: Border.all(color: AppColors.gold, width: 1.6),
      ),
      child: Text(ProfileData.initials, style: AppText.serif(context, size: 30)),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildStatItem('$_subjectCount', 'SUBJECTS'),
        _buildStatItem('$_totalCredits', 'CREDITS'),
        _buildStatItem(_gpa.toStringAsFixed(2), 'CUMULATIVE GPA'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppText.serif(context, size: 24)),
          const SizedBox(height: 4),
          Text(label, style: AppText.label(context)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 19, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppText.sans(context, size: 14))),
            if (subtitle != null) ...[
              Text(subtitle, style: AppText.muted(context)),
              const SizedBox(width: 8),
            ],
            trailing ??
                Icon(Icons.chevron_right,
                    size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
