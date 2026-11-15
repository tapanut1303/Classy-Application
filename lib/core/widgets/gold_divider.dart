import 'package:flutter/material.dart';

/// เส้นคั่นบาง ๆ ใช้คั่นระหว่างรายการ
class GoldDivider extends StatelessWidget {
  final double top;
  final double bottom;

  const GoldDivider({super.key, this.top = 12, this.bottom = 12});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: Container(height: 1, color: Theme.of(context).dividerColor),
    );
  }
}
