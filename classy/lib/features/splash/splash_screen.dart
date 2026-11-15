import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../auth/login_screen.dart';

/// หน้าเปิดแอป โชว์โลโก้ 2 วินาทีแล้วเด้งไปหน้า Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ตั้งเวลา 2 วินาที แล้วค่อยไปหน้าถัดไป
    Timer(const Duration(seconds: 2), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return; // กันกรณีผู้ใช้ปิดหน้าไปก่อนครบเวลา
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แตะที่หน้าจอเพื่อข้ามได้เลย ไม่ต้องรอครบ 2 วิ
      body: GestureDetector(
        onTap: _goToLogin,
        child: Container(
          decoration: const BoxDecoration(
            // ไล่สีน้ำตาลให้ความรู้สึกเหมือนผ้าขนสัตว์ในดีไซน์
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8A5A2B), Color(0xFF4A2E17), Color(0xFF2A1A0E)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Classy',
                  style: AppText.serif(
                    context,
                    size: 64,
                    color: const Color(0xFFF6EBD9),
                  ).copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                Text(
                  'without studying the real one',
                  style: AppText.sans(
                    context,
                    size: 12,
                    spacing: 2,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
