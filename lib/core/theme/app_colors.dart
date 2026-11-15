import 'package:flutter/material.dart';

/// สีทั้งหมดของแอปอยู่ที่ไฟล์นี้ไฟล์เดียว
/// อยากเปลี่ยนโทนสีแอป แก้ที่นี่ที่เดียวพอ
class AppColors {
  AppColors._(); // กันไม่ให้ใครเผลอสร้าง object จากคลาสนี้

  // ---------------- โหมดสว่าง ----------------
  static const cream = Color(0xFFF5EEE0); // พื้นหลังหน้าจอ
  static const card = Color(0xFFFFFCF6); // พื้นหลังการ์ด
  static const ink = Color(0xFF3B2E22); // ตัวหนังสือหลัก (น้ำตาลเข้ม)
  static const inkSoft = Color(0xFF8C7C69); // ตัวหนังสือรอง (จาง ๆ)
  static const line = Color(0xFFE4D9C4); // เส้นขอบ / เส้นคั่น

  // ---------------- โหมดมืด ----------------
  static const darkBg = Color(0xFF151210);
  static const darkCard = Color(0xFF221C16);
  static const darkInk = Color(0xFFF0E7D6);
  static const darkInkSoft = Color(0xFF9C8C77);
  static const darkLine = Color(0xFF342A20);

  // ---------------- สีเน้น (ใช้ร่วมกันทั้ง 2 โหมด) ----------------
  static const gold = Color(0xFFBFA265); // สีทอง จุดเด่นของแบรนด์
  static const lime = Color(0xFFC6DA6C); // ปุ่ม Join / Sign up
  static const magenta = Color(0xFFD1176B); // ปุ่มยืนยันออกจากระบบ
  static const brick = Color(0xFFB4553C); // ปุ่มลบ / งานเลยกำหนด
  static const forest = Color(0xFF5E7C55); // งานที่ทำเสร็จแล้ว

  /// สีประจำวิชา ให้ผู้ใช้เลือกตอนเพิ่มวิชา
  static const subjectPalette = <Color>[
    Color(0xFF7A6A55),
    Color(0xFFB4553C),
    Color(0xFF5E7C55),
    Color(0xFF4A5E8C),
    Color(0xFF8C5B8E),
    Color(0xFFBFA265),
  ];
}
