import 'package:flutter/material.dart';
import '../theme/app_text.dart';

/// ช่องกรอกข้อความของแอป มีหัวข้อเล็ก ๆ อยู่ข้างบน
///
/// ถ้าเป็นรหัสผ่าน ใส่ isPassword: true จะมีปุ่มรูปตาให้กดดูรหัสเอง
class ClassyTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

  const ClassyTextField({
    super.key,
    required this.label,
    this.hint = '',
    this.isPassword = false,
    this.controller,
  });

  @override
  State<ClassyTextField> createState() => _ClassyTextFieldState();
}

class _ClassyTextFieldState extends State<ClassyTextField> {
  // ซ่อนรหัสผ่านไว้ก่อนเป็นค่าเริ่มต้น
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppText.label(context, color: colors.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _hidden,
          style: AppText.sans(context, size: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppText.muted(context, size: 14),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.4),
            ),
            // ปุ่มรูปตา โผล่เฉพาะตอนเป็นช่องรหัสผ่าน
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
