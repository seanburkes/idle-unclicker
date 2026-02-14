import 'package:flutter/material.dart';

class GameIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const GameIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: size);
  }
}
