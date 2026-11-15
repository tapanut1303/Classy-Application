/// สมาชิกในกลุ่ม (ใช้ในหน้า About ที่อาจารย์สั่งให้มี)
class TeamMember {
  final String name;
  final String studentId;
  final String faculty;
  final String role;
  final String bio;
  final String imagePath;

  const TeamMember({
    required this.name,
    required this.studentId,
    required this.faculty,
    required this.role,
    required this.bio,
    required this.imagePath,
  });

  /// ตัวอักษรย่อของชื่อ ใช้แสดงในวงกลมแทนรูปโปรไฟล์
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1);
    return parts.first.substring(0, 1) + parts.last.substring(0, 1);
  }
}
