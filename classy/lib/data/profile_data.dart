import 'package:firebase_auth/firebase_auth.dart';
import 'models/team_member.dart';

/// ข้อมูลโปรไฟล์ผู้ใช้จาก Firebase และข้อมูลสมาชิกทีมแบบคงที่
class ProfileData {
  ProfileData._();

  static User? get _user => FirebaseAuth.instance.currentUser;

  static String get userName {
    final name = _user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return _user?.email?.split('@').first ?? 'ผู้ใช้ใหม่';
  }

  static String get userFirstName => userName.split(RegExp(r'\s+')).first;
  static String get studentId => '';
  static String get faculty => '';

  static String get initials {
    final parts = userName.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  /// เกรดเฉลี่ยย้อนหลังแต่ละเทอม ใช้วาดกราฟในหน้า Grades
  static const List<double> gpaHistory = [4.00, 3.75, 3.79, 3.50, 3.00, 3.50];
  static const List<String> gpaTermLabels = [
    '1/66',
    '2/66',
    '1/67',
    '2/67',
    '1/68',
    '2/68'
  ];

  /// สมาชิกในกลุ่ม (ข้อกำหนดของอาจารย์: ต้องมีหน้าแสดงข้อมูลสมาชิก)
  static const List<TeamMember> team = [
    TeamMember(
      name: 'Kanokkorn Boottijak',
      studentId: '6721602253',
      faculty: 'Liberal Arts and Science',
      role: 'Design & Frontend',
      bio: 'ออกแบบดีไซน์',
      imagePath: 'assets/images/developers/kanokkorn.png',
    ),
    TeamMember(
      name: 'Tapanut Cheewasukthavorn',
      studentId: '6721602334',
      faculty: 'Liberal Arts and Science',
      role: 'Systems & Backend',
      bio: 'ทำโครงสร้างงานและระบบหลังบ้าน',
      imagePath: 'assets/images/developers/tapanut.png',
    ),
  ];
}
