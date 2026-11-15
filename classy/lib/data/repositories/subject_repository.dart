import 'package:flutter/foundation.dart';
import '../local/app_database.dart';
import '../models/subject.dart';
import '../api/firestore_database.dart';

/// ตัวกลางระหว่างหน้าจอกับตาราง subjects
///
/// หน้าจอเรียกแค่ 4 เมธอดนี้ ไม่ต้องรู้จัก SQL เลย
///   getAll()  อ่านทั้งหมด
///   insert()  บันทึกใหม่
///   update()  แก้ไข
///   delete()  ลบ
class SubjectRepository {
  static final dataChanged = ValueNotifier<int>(0);
  final _db = AppDatabase.instance;

  /// อ่านวิชาทั้งหมด เรียงตามเวลาเริ่มเรียน
  Future<List<Subject>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('subjects', orderBy: 'start_time ASC');

    // rows คือ List<Map> แปลงทีละแถวให้เป็น object
    return rows.map(Subject.fromMap).toList();
  }

  /// อ่านเฉพาะวิชาที่เรียนในวันที่ระบุ (1 = จันทร์ ... 7 = อาทิตย์)
  ///
  /// คอลัมน์ days เก็บเป็นข้อความ "1,3" เลยกรองฝั่ง Dart แทนการเขียน SQL ซับซ้อน
  Future<List<Subject>> getByDay(int weekday) async {
    final all = await getAll();
    return all.where((subject) => subject.days.contains(weekday)).toList();
  }

  /// บันทึกวิชาใหม่ คืนค่า id ที่ฐานข้อมูลแจกให้
  Future<int> insert(Subject subject) async {
    await FirestoreDatabase.instance.saveSubject(subject);

    final db = await _db.database;
    final data = subject.toMap();
    data.remove('id'); // เอา id ออก ให้ SQLite แจกเลขเอง
    final id = await db.insert('subjects', data);
    dataChanged.value++;
    return id;
  }

  /// แก้ไขวิชาเดิม
  ///
  /// where กับ whereArgs ต้องเขียนคู่กันเสมอ ห้ามเอาค่ามาต่อ string ตรง ๆ
  /// เพราะเสี่ยงโดน SQL injection
  Future<int> update(Subject subject, {Subject? previous}) async {
    await FirestoreDatabase.instance.updateSubject(subject, previous: previous);

    final db = await _db.database;

    final count = await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
    dataChanged.value++;
    return count;
  }

  /// ลบวิชาตาม id
  Future<int> delete(int id, {Subject? subject}) async {
    if (subject != null) {
      await FirestoreDatabase.instance.deleteSubject(subject);
    }

    final db = await _db.database;
    final count = await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
    dataChanged.value++;
    return count;
  }

  /// รวมหน่วยกิตทั้งหมด
  Future<int> totalCredits() async {
    final subjects = await getAll();
    return subjects.fold<int>(0, (sum, subject) => sum + subject.credits);
  }

  /// คำนวณเกรดเฉลี่ย
  /// สูตร: ผลรวม(แต้มเกรด x หน่วยกิต) หารด้วย ผลรวมหน่วยกิต
  Future<double> calculateGpa() async {
    final subjects = await getAll();
    if (subjects.isEmpty) return 0;

    var totalPoints = 0.0;
    var totalCredits = 0;

    for (final subject in subjects) {
      totalPoints += subject.gradePoint * subject.credits;
      totalCredits += subject.credits;
    }

    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }
}
