import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

/// รวมธีมสว่าง / ธีมมืด ไว้ที่เดียว
///
/// เวลาเขียนหน้าจอ ให้ดึงสีจากธีมแบบนี้ เดี๋ยวมันสลับ dark mode ให้เอง:
///   Theme.of(context).colorScheme.onSurface         -> สีตัวหนังสือหลัก
///   Theme.of(context).colorScheme.onSurfaceVariant  -> สีตัวหนังสือจาง
///   Theme.of(context).cardColor                     -> สีพื้นการ์ด
///   Theme.of(context).dividerColor                  -> สีเส้น
class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppFonts.sans,
    scaffoldBackgroundColor: AppColors.cream,
    cardColor: AppColors.card,
    dividerColor: AppColors.line,
    colorScheme: const ColorScheme.light(
      primary: AppColors.gold,
      onPrimary: Colors.white,
      secondary: AppColors.lime,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkSoft,
      outline: AppColors.line,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppFonts.sans,
    scaffoldBackgroundColor: AppColors.darkBg,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkLine,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: Colors.black,
      secondary: AppColors.lime,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkInk,
      onSurfaceVariant: AppColors.darkInkSoft,
      outline: AppColors.darkLine,
    ),
  );
}
