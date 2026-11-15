/// ตัวช่วยจัดรูปแบบวันที่เป็นภาษาไทย
///
/// เขียนเองแทนการลงไลบรารี intl เพราะต้องการแค่ไม่กี่รูปแบบ
class ThaiDate {
  ThaiDate._();

  static const _months = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  static const _weekdays = [
    'วันจันทร์', 'วันอังคาร', 'วันพุธ', 'วันพฤหัสบดี',
    'วันศุกร์', 'วันเสาร์', 'วันอาทิตย์',
  ];

  static const _monthsShort = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  /// เช่น "วันจันทร์ที่ 21 กันยายน"
  static String full(DateTime date) {
    return '${_weekdays[date.weekday - 1]}ที่ ${date.day} ${_months[date.month - 1]}';
  }

  /// เช่น "กันยายน 2026"
  static String monthYear(DateTime date) => '${_months[date.month - 1]} ${date.year}';

  /// เช่น "OCT"
  static String monthShort(DateTime date) => _monthsShort[date.month - 1];

  /// เช่น "21/09 17:00"
  static String shortWithTime(DateTime date) {
    return '${_two(date.day)}/${_two(date.month)} ${_two(date.hour)}:${_two(date.minute)}';
  }

  /// นับว่าอีกกี่วันถึงวันนั้น (นับเป็นวัน ไม่สนเวลา)
  static int daysUntil(DateTime date) {
    final today = DateTime.now();
    final a = DateTime(today.year, today.month, today.day);
    final b = DateTime(date.year, date.month, date.day);
    return b.difference(a).inDays;
  }

  /// แปลงจำนวนวันเป็นข้อความอ่านง่าย เช่น "วันนี้" "พรุ่งนี้" "เลยกำหนด 2 วัน"
  static String dueLabel(DateTime date) {
    final days = daysUntil(date);
    if (days < 0) return 'เลยกำหนด ${-days} วัน';
    if (days == 0) return 'วันนี้ ${_two(date.hour)}:${_two(date.minute)}';
    if (days == 1) return 'พรุ่งนี้ ${_two(date.hour)}:${_two(date.minute)}';
    return 'อีก $days วัน';
  }

  /// เติมเลข 0 ข้างหน้าให้ครบ 2 หลัก  5 -> "05"
  static String _two(int value) => value.toString().padLeft(2, '0');
}
