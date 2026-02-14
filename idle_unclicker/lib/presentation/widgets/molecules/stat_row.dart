import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? modifier;
  final Color? modifierColor;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.modifier,
    this.modifierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (modifier != null) ...[
              const SizedBox(width: 4),
              Text(
                modifier!,
                style: TextStyle(
                  color: modifierColor ?? Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
