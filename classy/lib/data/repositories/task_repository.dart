import '../local/app_database.dart';
import '../models/task_item.dart';

/// ตัวกลางระหว่างหน้าจอกับตาราง tasks
class TaskRepository {
  final _db = AppDatabase.instance;

  /// อ่านงานทั้งหมด เรียงตามกำหนดส่งที่ใกล้ที่สุดก่อน
  Future<List<TaskItem>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('tasks', orderBy: 'due_date ASC');
    return rows.map(TaskItem.fromMap).toList();
  }

  /// อ่านเฉพาะงานที่ยังไม่เสร็จ
  ///
  /// รอบนี้กรองด้วย SQL เลย (done = 0) เร็วกว่าอ่านมาทั้งหมดแล้วค่อยกรอง
  Future<List<TaskItem>> getPending({int? limit}) async {
    final db = await _db.database;

    final rows = await db.query(
      'tasks',
      where: 'done = ?',
      whereArgs: [0],
      orderBy: 'due_date ASC',
      limit: limit,
    );

    return rows.map(TaskItem.fromMap).toList();
  }

  /// บันทึกงานใหม่
  Future<int> insert(TaskItem task) async {
    final db = await _db.database;

    final data = task.toMap();
    data.remove('id');

    return db.insert('tasks', data);
  }

  /// แก้ไขงาน
  Future<int> update(TaskItem task) async {
    final db = await _db.database;

    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// สลับสถานะเสร็จ / ยังไม่เสร็จ
  ///
  /// copyWith สร้าง object ใหม่ที่เหมือนเดิมทุกอย่าง ยกเว้น done
  Future<void> toggleDone(TaskItem task) async {
    await update(task.copyWith(done: !task.done));
  }

  /// ลบงานตาม id
  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// ลบงานที่ทำเสร็จแล้วทั้งหมดรวดเดียว
  Future<int> deleteCompleted() async {
    final db = await _db.database;
    return db.delete('tasks', where: 'done = ?', whereArgs: [1]);
  }
}
