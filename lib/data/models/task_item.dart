import '../../core/utils/thai_date.dart';

/// งานที่ต้องส่ง 1 ชิ้น
class TaskItem {
  final int? id;
  final String title; // ชื่องาน
  final String subject; // วิชาที่สั่ง
  final DateTime dueDate; // กำหนดส่ง
  final bool done; // ทำเสร็จหรือยัง

  const TaskItem({
    this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.done = false,
  });

  /// เลยกำหนดส่งแล้วหรือยัง (งานที่ทำเสร็จแล้วไม่นับว่าเลยกำหนด)
  bool get isOverdue => !done && dueDate.isBefore(DateTime.now());

  /// ครบกำหนดวันนี้ไหม
  bool get isToday => ThaiDate.daysUntil(dueDate) == 0;

  /// ข้อความกำหนดส่งแบบอ่านง่าย เช่น "พรุ่งนี้ 17:00"
  String get dueLabel => ThaiDate.dueLabel(dueDate);

  // ---------------- ส่วนที่คุยกับฐานข้อมูล ----------------

  /// SQLite ไม่มีชนิด bool กับ DateTime
  ///   bool     -> เก็บเป็น 1 / 0
  ///   DateTime -> เก็บเป็นข้อความรูปแบบ ISO เช่น "2026-09-21T23:59:00.000"
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'due_date': dueDate.toIso8601String(),
      'done': done ? 1 : 0,
    };
  }

  factory TaskItem.fromMap(Map<String, Object?> map) {
    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      subject: map['subject'] as String,
      dueDate: DateTime.parse(map['due_date'] as String),
      done: (map['done'] as int) == 1,
    );
  }

  TaskItem copyWith({
    int? id,
    String? title,
    String? subject,
    DateTime? dueDate,
    bool? done,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      done: done ?? this.done,
    );
  }
}
