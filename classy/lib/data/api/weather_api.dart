import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

/// เรียก API พยากรณ์อากาศจาก Open-Meteo
///
/// เลือกเจ้านี้เพราะ **ไม่ต้องสมัครและไม่ต้องใช้ API key** ใช้ได้ฟรีเลย
/// เอกสาร: https://open-meteo.com/en/docs
///
/// ตัวอย่าง URL ที่ยิงไป
/// https://api.open-meteo.com/v1/forecast?latitude=13.75&longitude=100.5
///   &current=temperature_2m,weather_code&timezone=Asia/Bangkok
class WeatherApi {
  static const String _host = 'api.open-meteo.com';
  static const String _path = '/v1/forecast';

  /// พิกัดกรุงเทพฯ ถ้าอยากใช้ตำแหน่งจริงให้ลง package geolocator เพิ่ม
  static const double _defaultLat = 13.7563;
  static const double _defaultLon = 100.5018;

  /// ดึงอากาศปัจจุบัน
  ///
  /// คืนค่าเป็น null ถ้าเน็ตล่มหรือ API มีปัญหา
  /// หน้าจอจะได้เลือกแสดงข้อความ "โหลดอากาศไม่สำเร็จ" แทนที่จะแอปแครช
  Future<Weather?> fetchCurrentWeather({
    double latitude = _defaultLat,
    double longitude = _defaultLon,
    String city = 'Bangkok, Thailand',
  }) async {
    // Uri.https ช่วยใส่ ? และ & ให้เอง ปลอดภัยกว่าต่อ string เอง
    final url = Uri.https(_host, _path, {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'temperature_2m,weather_code',
      'timezone': 'Asia/Bangkok',
    });

    try {
      // ตั้ง timeout ไว้ ไม่งั้นเน็ตช้าแล้วแอปจะค้างรอไม่รู้จบ
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      // 200 = สำเร็จ ถ้าได้เลขอื่นแปลว่ามีปัญหา
      if (response.statusCode != 200) return null;

      // แปลงข้อความ JSON ให้เป็น Map ที่ Dart ใช้ได้
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return Weather.fromJson(json, city);
    } catch (error) {
      // เน็ตหลุด / timeout / JSON ผิดรูป มารวมกันที่นี่หมด
      return null;
    }
  }
}
