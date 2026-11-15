import 'package:flutter/material.dart';

/// การ์ดสีครีมขอบมน ที่ใช้ซ้ำแทบทุกหน้าในแอป
///
/// แทนที่จะก๊อป Container + BoxDecoration ไปทุกหน้า ก็เรียกตัวนี้แทน
class ClassyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const ClassyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: child,
      ),
    );
  }
}
