import 'package:flutter/material.dart';

class ItemGrid extends StatelessWidget {
  final List<GridItem> items;
  final int crossAxisCount;
  final double spacing;
  final Color borderColor;

  const ItemGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 4,
    this.spacing = 8,
    this.borderColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _GridItemTile(item: item, borderColor: borderColor);
        },
      ),
    );
  }
}

class GridItem {
  final String name;
  final IconData? icon;
  final int? count;
  final bool isSelected;

  const GridItem({
    required this.name,
    this.icon,
    this.count,
    this.isSelected = false,
  });
}

class _GridItemTile extends StatelessWidget {
  final GridItem item;
  final Color borderColor;

  const _GridItemTile({required this.item, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: item.isSelected
              ? Colors.green
              : borderColor.withValues(alpha: 0.5),
          width: item.isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
        color: item.isSelected
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (item.icon != null)
            Icon(item.icon, color: Colors.white70, size: 24),
          if (item.count != null)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.count! > 99 ? '99+' : item.count.toString(),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
