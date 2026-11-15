/// ข้อมูลอากาศที่ได้จาก API
///
/// ไม่ต้องมี toMap เพราะไม่ได้เก็บลงฐานข้อมูล ดึงสดทุกครั้งที่เปิดแอป
class Weather {
  final double temperature; // อุณหภูมิ องศาเซลเซียส
  final int weatherCode; // รหัสสภาพอากาศตามมาตรฐาน WMO
  final String city; // ชื่อเมือง

  const Weather({
    required this.temperature,
    required this.weatherCode,
    required this.city,
  });

  /// แปลงรหัสสภาพอากาศเป็นข้อความภาษาไทย
  ///
  /// รหัสมาจากมาตรฐาน WMO ที่ Open-Meteo ใช้
  /// เอาเฉพาะกลุ่มที่เจอบ่อยในไทย
  String get description {
    if (weatherCode == 0) return 'ท้องฟ้าแจ่มใส';
    if (weatherCode <= 3) return 'มีเมฆบางส่วน';
    if (weatherCode <= 48) return 'มีหมอก';
    if (weatherCode <= 57) return 'ฝนละออง';
    if (weatherCode <= 67) return 'ฝนตก';
    if (weatherCode <= 77) return 'หิมะตก';
    if (weatherCode <= 82) return 'ฝนตกหนัก';
    return 'พายุฝนฟ้าคะนอง';
  }

  /// คำแนะนำสั้น ๆ ให้ผู้ใช้
  String get advice {
    if (weatherCode >= 51) return 'ฝนมาแน่ อย่าลืมพกร่มไปเรียน';
    if (temperature >= 33) return 'อากาศร้อนมาก พกน้ำไปด้วย';
    return 'อากาศกำลังดี เหมาะกับการไปเรียน';
  }

  /// แปลง JSON ที่ API ส่งกลับมาให้เป็น object
  ///
  /// หน้าตา JSON ที่ได้:
  /// { "current": { "temperature_2m": 30.2, "weather_code": 3 } }
  factory Weather.fromJson(Map<String, dynamic> json, String city) {
    final current = json['current'] as Map<String, dynamic>;

    return Weather(
      // API อาจส่งมาเป็น int หรือ double เลยแปลงให้ชัวร์ด้วย toDouble()
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      city: city,
    );
  }
}
