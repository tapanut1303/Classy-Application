import 'package:flutter/material.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_text.dart';
import '../grades/grades_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../schedule/schedule_screen.dart';
import '../tasks/tasks_screen.dart';

/// โครงหลักของแอปหลังล็อกอิน
///
/// responsive ตรงนี้:
///   จอมือถือ (แคบ)    -> เมนูอยู่ "ด้านล่าง" แบบ BottomNavigationBar
///   จอแท็บเล็ตขึ้นไป  -> เมนูย้ายไป "ด้านซ้าย" แบบ NavigationRail
///                        เพราะจอกว้างแล้วนิ้วเอื้อมถึงขอบล่างยาก และเปลืองพื้นที่
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // หน้าจอทั้ง 5 เรียงตามลำดับปุ่มเมนู
  final _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    TasksScreen(),
    GradesScreen(),
    ProfileScreen(),
  ];

  // ข้อมูลของแต่ละเมนู เก็บเป็นลิสต์จะได้ไม่ต้องเขียนซ้ำ 2 ที่
  static const _items = [
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.calendar_today_outlined, label: 'Schedule'),
    (icon: Icons.check_circle_outline, label: 'Tasks'),
    (icon: Icons.school_outlined, label: 'Grades'),
    (icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder บอกความกว้างจริงที่ widget นี้ได้รับ
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= Breakpoints.tablet;

        // IndexedStack เก็บทุกหน้าไว้ในหน่วยความจำ สลับแท็บแล้วไม่โหลดใหม่
        final body = IndexedStack(index: _currentIndex, children: _screens);

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                _buildRail(),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  // ---------------- เมนูซ้าย (จอกว้าง) ----------------
  Widget _buildRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      backgroundColor: Theme.of(context).cardColor,
      // extended = โชว์ชื่อเมนูข้างไอคอน เปิดเฉพาะจอใหญ่จริง ๆ
      extended: context.isDesktop,
      labelType: context.isDesktop ? null : NavigationRailLabelType.all,
      selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      unselectedIconTheme:
          IconThemeData(color: Theme.of(context).colorScheme.onSurfaceVariant),
      destinations: [
        for (final item in _items)
          NavigationRailDestination(
            icon: Icon(item.icon, size: 21),
            label: Text(item.label, style: AppText.sans(context, size: 12)),
          ),
      ],
    );
  }

  // ---------------- เมนูล่าง (จอมือถือ) ----------------
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                _buildTab(i, _items[i].icon, _items[i].label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = index == _currentIndex;
    final colors = Theme.of(context).colorScheme;
    final color = isActive ? colors.primary : colors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppText.sans(
                context,
                size: 10,
                weight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
