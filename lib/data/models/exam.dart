import '../../core/utils/thai_date.dart';

/// ตารางสอบ 1 วิชา
class Exam {
  final int? id;
  final String subject; // ชื่อวิชาที่สอบ
  final DateTime date; // วันสอบ
  final String time; // ช่วงเวลาสอบ เช่น "09:00 - 11:00"
  final String room; // ห้องสอบ
  final String seat; // เลขที่นั่ง
  final bool isFinal; // true = ปลายภาค, false = กลางภาค

  const Exam({
    this.id,
    required this.subject,
    required this.date,
    required this.time,
    required this.room,
    required this.seat,
    this.isFinal = false,
  });

  /// เหลืออีกกี่วันถึงวันสอบ คำนวณสด ไม่ต้องเก็บในฐานข้อมูล
  int get daysLeft => ThaiDate.daysUntil(date);

  /// ตัวย่อเดือน เช่น "OCT"
  String get monthShort => ThaiDate.monthShort(date);

  /// ป้ายสถานะตามจำนวนวันที่เหลือ
  String get urgencyLabel {
    if (daysLeft <= 7) return 'IMMINENT';
    if (daysLeft <= 14) return 'APPROACHING';
    return 'FAR AWAY';
  }

  // ---------------- ส่วนที่คุยกับฐานข้อมูล ----------------

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'subject': subject,
      'date': date.toIso8601String(),
      'time': time,
      'room': room,
      'seat': seat,
      'is_final': isFinal ? 1 : 0,
    };
  }

  factory Exam.fromMap(Map<String, Object?> map) {
    return Exam(
      id: map['id'] as int?,
      subject: map['subject'] as String,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
      room: map['room'] as String,
      seat: map['seat'] as String,
      isFinal: (map['is_final'] as int) == 1,
    );
  }
}
