import 'package:flutter/material.dart';
import '../molecules/game_card.dart';
import '../molecules/item_row.dart';
import '../atoms/game_icon.dart';

class InventoryPanel extends StatelessWidget {
  final String title;
  final List<InventoryItem> items;
  final Color borderColor;

  const InventoryPanel({
    super.key,
    this.title = 'INVENTORY',
    required this.items,
    this.borderColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GameIcon(
                icon: Icons.inventory_2,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ItemRow(
                name: item.name,
                description: item.description,
                count: item.count,
                icon: item.icon,
                borderColor: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryItem {
  final String name;
  final String? description;
  final int? count;
  final IconData? icon;

  const InventoryItem({
    required this.name,
    this.description,
    this.count,
    this.icon,
  });
}
