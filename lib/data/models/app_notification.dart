/// การแจ้งเตือน 1 รายการ
///
/// ไม่ได้เก็บในฐานข้อมูล สร้างสด ๆ จากงานและตารางสอบตอนเปิดหน้าแจ้งเตือน
class AppNotification {
  final String title; // หัวข้อ
  final String body; // รายละเอียด
  final String time; // ข้อความบอกเวลา เช่น "อีก 3 วัน"
  final bool isUrgent; // เร่งด่วนไหม (โชว์จุดสีแดงแทนสีทอง)

  const AppNotification({
    required this.title,
    required this.body,
    required this.time,
    this.isUrgent = false,
  });
}
