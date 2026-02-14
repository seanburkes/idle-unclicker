import 'package:flutter/material.dart';

enum GameTextStyle { sectionHeader, statLabel }

class GameTextStyles extends StatelessWidget {
  final String text;
  final GameTextStyle style;

  const GameTextStyles({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: _getStyle());
  }

  TextStyle _getStyle() {
    switch (style) {
      case GameTextStyle.sectionHeader:
        return const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        );
      case GameTextStyle.statLabel:
        return const TextStyle(color: Colors.grey, fontSize: 12);
    }
  }
}
