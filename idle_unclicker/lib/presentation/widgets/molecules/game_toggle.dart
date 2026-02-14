import 'package:flutter/material.dart';

class GameToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const GameToggle({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        GestureDetector(
          onTap: onChanged != null ? () => onChanged!(!value) : null,
          child: Container(
            width: 48,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value ? (activeColor ?? Colors.green) : Colors.grey,
              ),
              color: value
                  ? (activeColor ?? Colors.green).withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? (activeColor ?? Colors.green) : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
