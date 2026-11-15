import 'package:flutter/material.dart';
import '../theme/app_text.dart';

/// ปุ่มหลักของแอป (ปุ่มยาวเต็มความกว้าง)
///
/// ใช้ได้ 2 แบบ:
///   ClassyButton(label: 'Join', onPressed: ...)                 -> ปุ่มทึบ
///   ClassyButton(label: 'ยกเลิก', outlined: true, onPressed: ...) -> ปุ่มขอบ
class ClassyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final bool outlined;
  final IconData? icon;

  const ClassyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: outlined ? Colors.transparent : mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: outlined ? BorderSide(color: mainColor, width: 1.4) : BorderSide.none,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppText.sans(
                  context,
                  size: 15,
                  weight: FontWeight.w600,
                  color: outlined ? mainColor : (textColor ?? Colors.white),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18, color: outlined ? mainColor : (textColor ?? Colors.white)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
