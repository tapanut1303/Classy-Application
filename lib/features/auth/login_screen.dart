import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_button.dart';
import '../../core/widgets/classy_text_field.dart';
import '../main/main_navigation.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'กรุณากรอกอีเมลและรหัสผ่าน');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      setState(() => _error = error.code == 'user-not-found'
          ? 'ไม่พบบัญชีนี้ในระบบ'
          : 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveLayout(
            topPadding: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('welcome to', style: AppText.sans(context, size: 14)),
                Text('Classy', style: AppText.serif(context, size: 48)
                    .copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: 6),
                Text('Without study the soul will sick', style: AppText.muted(context)),
                const SizedBox(height: 44),
                ClassyTextField(
                  label: 'EMAIL',
                  hint: 'user-classy@sc.th',
                  controller: _emailController,
                ),
                const SizedBox(height: 18),
                ClassyTextField(
                  label: 'PASSWORD',
                  hint: 'ใส่รหัสผ่าน',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 10),
                if (_error != null) ...[
                  Text(_error!, style: AppText.sans(context, size: 12, color: AppColors.brick)),
                  const SizedBox(height: 10),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPassword(context),
                    child: Text('ลืมรหัสผ่าน?', style: AppText.muted(context)),
                  ),
                ),
                const SizedBox(height: 20),
                ClassyButton(
                  label: _loading ? 'กำลังเข้าสู่ระบบ...' : 'Join',
                  icon: Icons.arrow_forward,
                  color: AppColors.lime,
                  textColor: AppColors.ink,
                  onPressed: _loading ? () {} : _login,
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: Text('ยังไม่มีบัญชี? สมัครสมาชิก',
                        style: AppText.sans(context, size: 13, color: AppColors.magenta)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลืมรหัสผ่าน'),
        content: const Text('กรุณาติดต่อผู้ดูแลระบบเพื่อรีเซ็ตรหัสผ่าน'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
