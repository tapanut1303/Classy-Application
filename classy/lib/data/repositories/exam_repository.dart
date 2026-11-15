import '../local/app_database.dart';
import '../models/exam.dart';

/// ตัวกลางระหว่างหน้าจอกับตาราง exams
class ExamRepository {
  final _db = AppDatabase.instance;

  /// อ่านตารางสอบทั้งหมด เรียงตามวันสอบ
  Future<List<Exam>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('exams', orderBy: 'date ASC');
    return rows.map(Exam.fromMap).toList();
  }

  /// อ่านเฉพาะกลางภาค หรือเฉพาะปลายภาค
  Future<List<Exam>> getByType({required bool isFinal}) async {
    final db = await _db.database;

    final rows = await db.query(
      'exams',
      where: 'is_final = ?',
      whereArgs: [isFinal ? 1 : 0],
      orderBy: 'date ASC',
    );

    return rows.map(Exam.fromMap).toList();
  }

  /// อ่านวิชาที่จะสอบเร็ว ๆ นี้ ใช้โชว์การ์ดนับถอยหลังในหน้าแรก
  Future<List<Exam>> getUpcoming({int limit = 2}) async {
    final db = await _db.database;

    final rows = await db.query(
      'exams',
      where: 'date >= ?',
      whereArgs: [DateTime.now().toIso8601String()],
      orderBy: 'date ASC',
      limit: limit,
    );

    return rows.map(Exam.fromMap).toList();
  }

  Future<int> insert(Exam exam) async {
    final db = await _db.database;

    final data = exam.toMap();
    data.remove('id');

    return db.insert('exams', data);
  }

  Future<int> update(Exam exam) async {
    final db = await _db.database;
    return db.update('exams', exam.toMap(), where: 'id = ?', whereArgs: [exam.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('exams', where: 'id = ?', whereArgs: [id]);
  }
}
