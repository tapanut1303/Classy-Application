import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_button.dart';
import '../../core/widgets/classy_text_field.dart';
import '../../data/local/app_database.dart';
import '../main/main_navigation.dart';

/// หน้าสมัครสมาชิก
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final text = _passwordController.text;
    if (text.isEmpty) return 0;
    var score = 0;
    if (text.length >= 8) score++;
    if (text.contains(RegExp(r'[A-Z]'))) score++;
    if (text.contains(RegExp(r'[0-9]'))) score++;
    return score;
  }

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final studentId = _studentIdController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    if (studentId.isEmpty) {
      setState(() => _error = 'กรุณากรอกรหัสนักศึกษา');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'ยืนยันรหัสผ่านไม่ตรงกับรหัสผ่าน');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await AppDatabase.instance.clearUserData();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _messageFromCode(e.code));
    } catch (_) {
      setState(() => _error = 'สร้างบัญชีไม่สำเร็จ กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _messageFromCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้งานแล้ว';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'weak-password':
        return 'รหัสผ่านอ่อนเกินไป';
      default:
        return 'สร้างบัญชีล้มเหลว กรุณาลองใหม่';
    }
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
      ),
      body: SingleChildScrollView(
        child: ResponsiveLayout(
          topPadding: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Let's do it",
                style: AppText.serif(context, size: 44)
                    .copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 28),

              ClassyTextField(
                label: 'ชื่อ-นามสกุล',
                hint: 'เช่น ปรีดา วัฒนกุล',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              ClassyTextField(
                label: 'รหัสนักศึกษา',
                hint: '6721402235',
                controller: _studentIdController,
              ),
              const SizedBox(height: 16),
              ClassyTextField(
                label: 'EMAIL',
                hint: 'user-classy@sc.th',
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              ClassyTextField(
                label: 'รหัสผ่าน',
                hint: 'อย่างน้อย 8 ตัวอักษร',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 10),
              _buildStrengthBar(),
              const SizedBox(height: 16),

              ClassyTextField(
                label: 'ยืนยันรหัสผ่าน',
                hint: 'พิมพ์รหัสผ่านอีกครั้ง',
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 16),

              if (_error != null) ...[
                Text(
                  _error!,
                  style: AppText.sans(context, size: 12, color: AppColors.brick),
                ),
                const SizedBox(height: 16),
              ],

              ClassyButton(
                label: _loading ? 'กำลังสร้างบัญชี...' : 'Sign up',
                color: AppColors.lime,
                textColor: AppColors.ink,
                onPressed: _loading ? () {} : _signup,
              ),
              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
                    style: AppText.sans(context, size: 13, color: AppColors.magenta),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthBar() {
    const colors = [AppColors.brick, AppColors.gold, AppColors.forest];
    const labels = ['อ่อนไป', 'พอใช้', 'แข็งแรงดี'];
    final score = _passwordStrength;

    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < score ? colors[score - 1] : Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        SizedBox(
          width: 64,
          child: Text(
            score == 0 ? '' : labels[score - 1],
            style: AppText.muted(context, size: 11),
          ),
        ),
      ],
    );
  }
}

