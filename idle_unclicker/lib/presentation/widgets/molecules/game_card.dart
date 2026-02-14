import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const GameCard({
    super.key,
    required this.child,
    this.borderColor = Colors.green,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
