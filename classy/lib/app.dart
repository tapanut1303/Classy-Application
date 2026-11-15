import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';

/// ตัวแปรกลางที่เก็บว่าตอนนี้ใช้ธีมสว่างหรือมืด
///
/// ใช้ ValueNotifier เพราะง่ายที่สุด ไม่ต้องลง package เพิ่ม
/// หน้าไหนอยากสลับธีม ก็แค่สั่ง: themeModeNotifier.value = ThemeMode.dark;
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

class ClassyApp extends StatelessWidget {
  const ClassyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder = ถ้าค่าใน notifier เปลี่ยน ให้ build ใหม่
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Classy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
