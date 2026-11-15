import 'package:flutter/material.dart';

/// จุดตัดขนาดหน้าจอ ใช้ตัดสินใจว่าจะจัดหน้าแบบไหน
///
/// ตัวเลขนี้อ้างอิงจาก Material Design
///   มือถือ    ต่ำกว่า 600
///   แท็บเล็ต  600 - 1023
///   จอใหญ่    1024 ขึ้นไป
class Breakpoints {
  Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  /// ความกว้างสูงสุดของเนื้อหา
  /// จอกว้างมาก ๆ ถ้าปล่อยให้ข้อความยืดเต็มจอจะอ่านยาก เลยจำกัดไว้
  static const double maxContentWidth = 900;
}

/// ตัวช่วยเรียกสั้น ๆ  เช่น  if (context.isTablet) { ... }
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  bool get isMobile => screenWidth < Breakpoints.tablet;
  bool get isTablet => screenWidth >= Breakpoints.tablet && screenWidth < Breakpoints.desktop;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// ระยะขอบซ้ายขวาของหน้า จอใหญ่เว้นเยอะกว่า
  double get pagePadding => isMobile ? 22 : 40;

  /// จำนวนคอลัมน์ที่เหมาะกับหน้าจอนี้
  int get columnCount {
    if (isDesktop) return 3;
    if (isTablet) return 2;
    return 1;
  }

  /// เลือกค่าตามขนาดจอ  เช่น  context.pick(mobile: 24, tablet: 30, desktop: 36)
  T pick<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (!isMobile && tablet != null) return tablet;
    return mobile;
  }
}
