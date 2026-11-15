import 'package:flutter/material.dart';

/// วิชาเรียน 1 วิชา
///
/// คลาสนี้ทำหน้าที่ 2 อย่าง
///   1. เก็บข้อมูลให้หน้าจอเอาไปแสดง
///   2. แปลงไป-กลับระหว่าง object กับ Map เพื่อเก็บลงฐานข้อมูล
///      (toMap = ก่อนบันทึก, fromMap = หลังอ่านขึ้นมา)
class Subject {
  final int? id; // เลขประจำแถวในฐานข้อมูล ยังไม่บันทึก = null
  final String code; // รหัสวิชา เช่น HCI 5021
  final String name; // ชื่อวิชา
  final String lecturer; // ชื่ออาจารย์
  final String room; // ห้องเรียน
  final int credits; // หน่วยกิต
  final String grade; // เกรดที่ได้ เช่น A, B+
  final int colorValue; // สีประจำวิชา เก็บเป็นตัวเลขเพราะ SQLite เก็บ Color ไม่ได้
  final List<int> days; // วันที่เรียน 1 = จันทร์ ... 7 = อาทิตย์
  final String startTime; // เวลาเริ่ม เช่น 13:00
  final String endTime; // เวลาเลิก เช่น 15:30

  const Subject({
    this.id,
    required this.code,
    required this.name,
    required this.lecturer,
    required this.room,
    required this.credits,
    required this.grade,
    required this.colorValue,
    required this.days,
    required this.startTime,
    required this.endTime,
  });

  /// แปลงตัวเลขกลับเป็นสีให้หน้าจอใช้
  Color get color => Color(colorValue);

  /// ช่วงเวลาเรียนแบบพร้อมแสดงผล เช่น "13:00 - 15:30"
  String get timeRange => '$startTime - $endTime';

  /// แปลงเกรดตัวอักษรเป็นตัวเลข ไว้ใช้คำนวณ GPA
  double get gradePoint => gradePoints[grade] ?? 0.0;

  static const Map<String, double> gradePoints = {
    'A': 4.0, 'B+': 3.5, 'B': 3.0, 'C+': 2.5,
    'C': 2.0, 'D+': 1.5, 'D': 1.0, 'F': 0.0,
  };

  // ---------------- ส่วนที่คุยกับฐานข้อมูล ----------------

  /// แปลงเป็น Map เพื่อบันทึกลงตาราง subjects
  ///
  /// days เป็น List ซึ่ง SQLite เก็บไม่ได้ เลยต่อเป็นข้อความคั่นด้วยจุลภาค
  /// [1, 3] -> "1,3"
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'lecturer': lecturer,
      'room': room,
      'credits': credits,
      'grade': grade,
      'color_value': colorValue,
      'days': days.join(','),
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  /// สร้าง object จากแถวที่อ่านมาจากฐานข้อมูล
  factory Subject.fromMap(Map<String, Object?> map) {
    final rawDays = (map['days'] as String?) ?? '';

    return Subject(
      id: map['id'] as int?,
      code: map['code'] as String,
      name: map['name'] as String,
      lecturer: map['lecturer'] as String,
      room: map['room'] as String,
      credits: map['credits'] as int,
      grade: map['grade'] as String,
      colorValue: map['color_value'] as int,
      // "1,3" -> [1, 3]
      days: rawDays.isEmpty
          ? <int>[]
          : rawDays.split(',').map(int.parse).toList(),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
    );
  }

  /// ก๊อปตัวเองแล้วเปลี่ยนบางค่า ใช้ตอนแก้ไขข้อมูล
  /// (object ตัวนี้เป็น final หมด แก้ค่าตรง ๆ ไม่ได้)
  Subject copyWith({
    int? id,
    String? code,
    String? name,
    String? lecturer,
    String? room,
    int? credits,
    String? grade,
    int? colorValue,
    List<int>? days,
    String? startTime,
    String? endTime,
  }) {
    return Subject(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      lecturer: lecturer ?? this.lecturer,
      room: room ?? this.room,
      credits: credits ?? this.credits,
      grade: grade ?? this.grade,
      colorValue: colorValue ?? this.colorValue,
      days: days ?? this.days,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
