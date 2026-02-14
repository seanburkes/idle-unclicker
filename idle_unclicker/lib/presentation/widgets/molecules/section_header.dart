import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  final double? fontSize;

  const SectionHeader({
    super.key,
    required this.title,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: color ?? Colors.green,
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
