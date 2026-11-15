import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/theme/app_colors.dart';

/// ตัวจัดการฐานข้อมูล SQLite ของแอป
///
/// หน้าที่มีแค่ 3 อย่าง
///   1. เปิดไฟล์ฐานข้อมูล (สร้างให้อัตโนมัติถ้ายังไม่มี)
///   2. สร้างตารางตอนเปิดครั้งแรก
///   3. ใส่ข้อมูลตัวอย่างให้ ตอนเปิดแอปครั้งแรกจะได้ไม่ว่างเปล่า
///
/// หน้าจอไม่ต้องเรียกคลาสนี้ตรง ๆ ให้เรียกผ่าน repository แทน
class AppDatabase {
  AppDatabase._(); // ห้ามสร้างใหม่จากข้างนอก

  /// ใช้ตัวเดียวทั้งแอป (singleton) เพราะเปิดไฟล์ฐานข้อมูลซ้ำ ๆ ไม่ดี
  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  /// จุดเดียวที่ repository ทุกตัวเรียกเพื่อขอฐานข้อมูล
  Future<Database> get database async {
    // ??= แปลว่า "ถ้ายังเป็น null ค่อยสร้าง" เปิดครั้งเดียวพอ
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    // ที่เก็บไฟล์ฐานข้อมูลของแต่ละเครื่อง (Android กับ iOS คนละที่)
    final folder = await getDatabasesPath();
    final path = join(folder, 'classy.db');

    return openDatabase(
      path,
      version: 1, // เพิ่มเลขนี้เมื่อแก้โครงสร้างตาราง แล้วเขียน onUpgrade
      onCreate: _onCreate, // ทำงานเฉพาะครั้งแรกที่ยังไม่มีไฟล์
    );
  }

  /// สร้างตารางทั้งหมด แล้วใส่ข้อมูลตัวอย่าง
  Future<void> _onCreate(Database db, int version) async {
    // INTEGER PRIMARY KEY AUTOINCREMENT = ให้ SQLite แจกเลข id เองอัตโนมัติ
    await db.execute('''
      CREATE TABLE subjects (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        code        TEXT    NOT NULL,
        name        TEXT    NOT NULL,
        lecturer    TEXT    NOT NULL,
        room        TEXT    NOT NULL,
        credits     INTEGER NOT NULL,
        grade       TEXT    NOT NULL,
        color_value INTEGER NOT NULL,
        days        TEXT    NOT NULL,
        start_time  TEXT    NOT NULL,
        end_time    TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        title    TEXT    NOT NULL,
        subject  TEXT    NOT NULL,
        due_date TEXT    NOT NULL,
        done     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE exams (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        subject  TEXT    NOT NULL,
        date     TEXT    NOT NULL,
        time     TEXT    NOT NULL,
        room     TEXT    NOT NULL,
        seat     TEXT    NOT NULL,
        is_final INTEGER NOT NULL DEFAULT 0
      )
    ''');

  }

  Future<void> clearUserData() async {
    final db = await database;
    await db.delete('subjects');
    await db.delete('tasks');
    await db.delete('exams');
  }

  /// ข้อมูลตัวอย่างชุดแรก
  ///
  /// ใช้ batch เพื่อยิงหลายคำสั่งรวดเดียว เร็วกว่าเรียก insert ทีละครั้ง
  Future<void> _insertSampleData(Database db) async {
    final batch = db.batch();
    final today = DateTime.now();

    // ---- วิชาเรียน ----
    batch.insert('subjects', {
      'code': 'ARCH 4012',
      'name': 'Advanced Architecture Studio',
      'lecturer': 'Dr. Harrison Vance',
      'room': 'Studio 301',
      'credits': 4,
      'grade': 'A',
      'color_value': AppColors.subjectPalette[0].value,
      'days': '1,3',
      'start_time': '10:30',
      'end_time': '13:30',
    });
    batch.insert('subjects', {
      'code': 'PHIL 3021',
      'name': 'Philosophy & Rhetoric IV',
      'lecturer': 'Prof. Clara Sterling',
      'room': 'Hall B',
      'credits': 3,
      'grade': 'A',
      'color_value': AppColors.subjectPalette[3].value,
      'days': '2,4',
      'start_time': '14:00',
      'end_time': '16:00',
    });
    batch.insert('subjects', {
      'code': 'CS 3310',
      'name': 'Database Systems Architecture',
      'lecturer': 'Dr. Anon Pontam',
      'room': 'Grand Hall A',
      'credits': 3,
      'grade': 'B+',
      'color_value': AppColors.subjectPalette[1].value,
      'days': '1,5',
      'start_time': '09:00',
      'end_time': '11:30',
    });
    batch.insert('subjects', {
      'code': 'MATH 2201',
      'name': 'Linear Algebra & Applications',
      'lecturer': 'Dr. Evelyn Starling',
      'room': 'Room 104',
      'credits': 3,
      'grade': 'B',
      'color_value': AppColors.subjectPalette[2].value,
      'days': '3',
      'start_time': '13:30',
      'end_time': '15:30',
    });

    // ---- งานที่ต้องส่ง ----
    // กำหนดส่งอิงจากวันที่เปิดแอปครั้งแรก จะได้เห็นทั้งงานวันนี้และงานเลยกำหนด
    batch.insert('tasks', {
      'title': 'Complete design synthesis outline',
      'subject': 'Advanced Architecture Studio',
      'due_date': DateTime(today.year, today.month, today.day, 23, 59).toIso8601String(),
      'done': 0,
    });
    batch.insert('tasks', {
      'title': 'Submit database schema prototype',
      'subject': 'Database Systems Architecture',
      'due_date': today.add(const Duration(days: 1)).toIso8601String(),
      'done': 0,
    });
    batch.insert('tasks', {
      'title': 'Read philosophy treatise chapter 4-6',
      'subject': 'Philosophy & Rhetoric IV',
      'due_date': today.add(const Duration(days: 3)).toIso8601String(),
      'done': 0,
    });
    batch.insert('tasks', {
      'title': 'Weekly math homework checklist',
      'subject': 'Linear Algebra & Applications',
      'due_date': today.subtract(const Duration(days: 2)).toIso8601String(),
      'done': 0,
    });
    batch.insert('tasks', {
      'title': 'Peer review studio presentation',
      'subject': 'Advanced Architecture Studio',
      'due_date': today.subtract(const Duration(days: 1)).toIso8601String(),
      'done': 1,
    });

    // ---- ตารางสอบ ----
    batch.insert('exams', {
      'subject': 'Database Systems',
      'date': today.add(const Duration(days: 12)).toIso8601String(),
      'time': '09:00 - 11:00',
      'room': 'Grand Hall A',
      'seat': 'A-21',
      'is_final': 0,
    });
    batch.insert('exams', {
      'subject': 'Linear Algebra II',
      'date': today.add(const Duration(days: 15)).toIso8601String(),
      'time': '13:30 - 15:30',
      'room': 'Room 104',
      'seat': 'C-08',
      'is_final': 0,
    });
    batch.insert('exams', {
      'subject': 'Architectural Synthesis',
      'date': today.add(const Duration(days: 19)).toIso8601String(),
      'time': '10:00 - 13:00',
      'room': 'Studio 28',
      'seat': 'S-02',
      'is_final': 0,
    });
    batch.insert('exams', {
      'subject': 'Philosophy & Rhetoric IV',
      'date': today.add(const Duration(days: 78)).toIso8601String(),
      'time': '09:00 - 12:00',
      'room': 'Hall B',
      'seat': 'B-14',
      'is_final': 1,
    });
    batch.insert('exams', {
      'subject': 'Database Systems',
      'date': today.add(const Duration(days: 84)).toIso8601String(),
      'time': '13:00 - 16:00',
      'room': 'Grand Hall A',
      'seat': 'A-21',
      'is_final': 1,
    });

    await batch.commit(noResult: true);
  }

  /// ลบข้อมูลทั้งหมดแล้วใส่ตัวอย่างใหม่ (ปุ่ม "รีเซ็ตข้อมูล" ในหน้าโปรไฟล์)
  Future<void> resetToSampleData() async {
    final db = await database;
    await db.delete('subjects');
    await db.delete('tasks');
    await db.delete('exams');
    await _insertSampleData(db);
  }
}
