import 'package:flutter/material.dart';

class GameProgressBar extends StatelessWidget {
  final double current;
  final double max;
  final Color color;
  final double height;

  const GameProgressBar({
    super.key,
    required this.current,
    required this.max,
    required this.color,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    final progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(color: color),
            ),
            Center(
              child: Text(
                '${current.toInt()}/${max.toInt()}',
                style: TextStyle(
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
