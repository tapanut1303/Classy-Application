import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_button.dart';
import 'login_screen.dart';

/// หน้าบอกลาหลังออกจากระบบ มีปุ่มกลับไปเข้าสู่ระบบอีกครั้ง
class GoodbyeScreen extends StatelessWidget {
  const GoodbyeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B4423), Color(0xFF2A1A0E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                Text('Bye',
                    style: AppText.serif(context, size: 56, color: const Color(0xFFF6EBD9))
                        .copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text('See you soon',
                    style: AppText.sans(context, size: 14, spacing: 2, color: AppColors.gold)),
                const Spacer(),
                ClassyButton(
                  label: 'sign in again',
                  color: const Color(0xFFF6EBD9),
                  textColor: AppColors.ink,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
