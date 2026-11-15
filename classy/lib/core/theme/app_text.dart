import 'package:flutter/material.dart';
import 'app_fonts.dart';

/// ตัวช่วยสร้างสไตล์ตัวหนังสือ จะได้ไม่ต้องพิมพ์ TextStyle ยาว ๆ ทุกที่
///
/// วิธีใช้:  Text('สวัสดี', style: AppText.serif(context, size: 28))
class AppText {
  AppText._();

  /// ตัวหนังสือแบบมีเชิง ใช้กับหัวข้อ ชื่อหน้า ตัวเลขเด่น ๆ
  static TextStyle serif(
    BuildContext context, {
    double size = 22,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// ตัวหนังสือธรรมดา ใช้กับเนื้อหาทั่วไป
  static TextStyle sans(
    BuildContext context, {
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.4,
    double spacing = 0,
  }) {
    return TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// ตัวหนังสือจาง ๆ ตัวเล็ก ใช้กับคำอธิบายใต้หัวข้อ
  static TextStyle muted(BuildContext context, {double size = 12}) {
    return sans(
      context,
      size: size,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  /// ป้ายกำกับเล็ก ๆ สีทอง เช่น "UP NEXT" "DUE SOON"
  static TextStyle label(BuildContext context, {Color? color}) {
    return sans(
      context,
      size: 10,
      weight: FontWeight.w600,
      spacing: 1.6,
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
