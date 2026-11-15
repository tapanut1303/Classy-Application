import 'package:firebase_auth/firebase_auth.dart';
import 'models/team_member.dart';

/// ข้อมูลโปรไฟล์ผู้ใช้ที่อ่านจาก Firebase Auth แทนค่าคงที่
///
/// นี่เป็นการยกเลิก mock profile data ให้แสดงข้อมูลที่เกี่ยวกับบัญชีที่ login จริง
class ProfileData {
  ProfileData._();

  static User? get _user => FirebaseAuth.instance.currentUser;

  static String get userName {
    final displayName = _user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = _user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      final beforeAt = email.split('@').first;
      return beforeAt.replaceAll('.', ' ').trim();
    }

      return 'ผู้ใช้ใหม่';
  }

  static String get userFirstName {
    final name = userName;
    final parts = name.split(RegExp(r'\s+'));
      return parts.isNotEmpty ? parts.first : 'ผู้ใช้ใหม่';
  }

  static String get studentId {
    final uid = _user?.uid ?? '';
    if (uid.isEmpty) return 'STU-00000000';
    return 'STU-${uid.substring(0, uid.length > 8 ? 8 : uid.length).toUpperCase()}';
  }

  static String get faculty => 'Faculty of Engineering';

  static String get initials {
    final name = userName;
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  /// เกรดเฉลี่ยย้อนหลังแต่ละเทอม ใช้วาดกราฟในหน้า Grades
  static const List<double> gpaHistory = [2.95, 3.18, 3.40, 3.32, 3.58, 3.67];
  static const List<String> gpaTermLabels = ['1/66', '2/66', '1/67', '2/67', '1/68', '2/68'];

  /// สมาชิกในกลุ่ม (ข้อกำหนดของอาจารย์: ต้องมีหน้าแสดงข้อมูลสมาชิก)
  static const List<TeamMember> team = [
    TeamMember(
      name: 'Anya Visser',
      studentId: 'STU-6530001188',
      faculty: 'Faculty of Engineering',
      role: 'Design & Frontend',
      bio: 'ดูแลระบบดีไซน์ กริด ตัวอักษร และทุกจังหวะการใช้งานให้ลงตัว',
    ),
    TeamMember(
      name: 'Preeda Wattanakul',
      studentId: 'STU-6530001224',
      faculty: 'Faculty of Engineering',
      role: 'Systems & Backend',
      bio: 'ดูแลอัลกอริทึม โครงสร้างฐานข้อมูล และการเชื่อมต่อคลาวด์',
    ),
  ];
}
