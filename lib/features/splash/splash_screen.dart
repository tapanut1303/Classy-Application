import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../auth/login_screen.dart';
import '../main/main_navigation.dart';

/// หน้าเปิดแอป โชว์โลโก้ 2 วินาทีแล้วตรวจว่าผู้ใช้ login อยู่หรือไม่
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _checkAuthState);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkAuthState() {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final screen = user == null ? const LoginScreen() : const MainNavigation();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _checkAuthState,
        child: Container(
          decoration: const BoxDecoration(
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
