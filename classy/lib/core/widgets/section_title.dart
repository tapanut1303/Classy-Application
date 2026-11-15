import 'package:flutter/material.dart';
import '../theme/app_text.dart';

/// หัวข้อของแต่ละส่วนในหน้าจอ เช่น "Up Next" "Due Soon"
/// มีปุ่มข้อความเล็ก ๆ ด้านขวาให้ใส่ได้ (เช่น "VIEW ALL")
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: AppText.serif(context, size: 22)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: AppText.label(context)),
          ),
      ],
    );
  }
}
