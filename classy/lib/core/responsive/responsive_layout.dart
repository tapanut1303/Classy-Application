import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// ครอบเนื้อหาของหน้าให้อยู่กลางจอ และจำกัดความกว้างไม่ให้ยืดเกินไป
///
/// บนมือถือแทบไม่เห็นความต่าง แต่บนแท็บเล็ต/จอใหญ่
/// เนื้อหาจะไม่แผ่กว้างจนอ่านยาก
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double topPadding;
  final double bottomPadding;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.topPadding = 16,
    this.bottomPadding = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            topPadding,
            context.pagePadding,
            bottomPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// เรียงการ์ดเป็นคอลัมน์ตามขนาดจอ
///   มือถือ 1 คอลัมน์ / แท็บเล็ต 2 / จอใหญ่ 3
///
/// ใช้ LayoutBuilder เพื่อรู้ความกว้างจริงที่วิดเจ็ตนี้ได้รับ
/// แล้วคำนวณความกว้างของการ์ดแต่ละใบเอง
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveGrid({super.key, required this.children, this.spacing = 12});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = context.columnCount;

        // ความกว้างการ์ด = (ความกว้างทั้งหมด - ช่องว่างระหว่างการ์ด) / จำนวนคอลัมน์
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
