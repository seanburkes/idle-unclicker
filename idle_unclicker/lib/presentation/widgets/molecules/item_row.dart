import 'package:flutter/material.dart';

class ItemRow extends StatelessWidget {
  final IconData? icon;
  final String name;
  final String? description;
  final int? count;
  final VoidCallback? onTap;
  final Color? borderColor;

  const ItemRow({
    super.key,
    this.icon,
    required this.name,
    this.description,
    this.count,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: borderColor ?? Colors.green, width: 3),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count! > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
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
