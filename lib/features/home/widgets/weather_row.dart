import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../data/models/weather.dart';

/// แถบอากาศวันนี้ ข้อมูลมาจาก API ของ Open-Meteo
///
/// weather เป็น null ได้ แปลว่าโหลดไม่สำเร็จ (เน็ตหลุด / API ล่ม)
/// กรณีนั้นแสดงข้อความบอกผู้ใช้แทน ไม่ปล่อยให้จอว่าง
class WeatherRow extends StatelessWidget {
  final Weather? weather;

  const WeatherRow({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return Row(
        children: [
          Icon(Icons.cloud_off_outlined,
              size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'โหลดข้อมูลอากาศไม่สำเร็จ ลองดึงหน้าจอลงเพื่อโหลดใหม่',
              style: AppText.muted(context),
            ),
          ),
        ],
      );
    }

    final data = weather!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // toStringAsFixed(0) = ปัดเป็นจำนวนเต็ม 30.2 -> "30"
        Text('${data.temperature.toStringAsFixed(0)}°C',
            style: AppText.serif(context, size: 32)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.description,
                  style: AppText.sans(context, size: 13, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(data.city, style: AppText.muted(context, size: 11)),
              const SizedBox(height: 6),
              Text(data.advice, style: AppText.muted(context)),
            ],
          ),
        ),
      ],
    );
  }
}
