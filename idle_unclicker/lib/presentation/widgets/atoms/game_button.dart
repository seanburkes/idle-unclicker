import 'package:flutter/material.dart';

enum GameButtonVariant { primary, secondary }

class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final GameButtonVariant variant;
  final IconData? icon;

  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = GameButtonVariant.primary,
    this.icon,
  });

  factory GameButton.icon({
    required IconData icon,
    required VoidCallback onPressed,
    Key? key,
  }) {
    return GameButton(
      key: key,
      label: '',
      onPressed: onPressed,
      variant: GameButtonVariant.primary,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == GameButtonVariant.secondary) {
      return TextButton(
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.green)),
      );
    }

    if (icon != null) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.green,
        side: const BorderSide(color: Colors.green),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
