import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../data/profile_data.dart';

/// กราฟเส้นแสดง GPA ย้อนหลังแต่ละเทอม
///
/// วาดเองด้วย CustomPaint จะได้ไม่ต้องลง package กราฟเพิ่ม
/// (นี่คือเทคนิคนอกห้องเรียนที่ใช้ในโปรเจคนี้)
class GpaChart extends StatelessWidget {
  const GpaChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 110,
          width: double.infinity,
          child: CustomPaint(
            painter: _GpaChartPainter(
              values: ProfileData.gpaHistory,
              lineColor: AppColors.gold,
              gridColor: Theme.of(context).dividerColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in ProfileData.gpaTermLabels)
              Text(label, style: AppText.muted(context, size: 10)),
          ],
        ),
      ],
    );
  }
}

class _GpaChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color gridColor;

  _GpaChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  static const double _minGpa = 2.0;
  static const double _maxGpa = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return; // มีจุดเดียววาดเส้นไม่ได้

    // ---- เส้นตารางแนวนอน 3 เส้น ----
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ---- แปลงค่า GPA เป็นตำแหน่งจุดบนจอ ----
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      // ค่ายิ่งมาก y ยิ่งน้อย เพราะแกน y ของจอนับจากบนลงล่าง
      final ratio = (values[i] - _minGpa) / (_maxGpa - _minGpa);
      points.add(Offset(x, size.height - ratio * size.height));
    }

    // ---- ลากเส้นเชื่อมจุด ----
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // ---- ระบายสีจาง ๆ ใต้เส้น ----
    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = lineColor.withOpacity(0.12));

    // ---- จุดกลมบนเส้น ----
    for (final point in points) {
      canvas.drawCircle(point, 3, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
