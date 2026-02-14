import 'package:flutter/material.dart';
import '../molecules/game_card.dart';

class CharacterHeader extends StatelessWidget {
  final String name;
  final String characterClass;
  final int level;
  final IconData? portraitIcon;

  const CharacterHeader({
    super.key,
    required this.name,
    required this.characterClass,
    required this.level,
    this.portraitIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      borderColor: Colors.green,
      child: Row(
        children: [
          // Portrait
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              portraitIcon ?? Icons.person,
              color: Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      characterClass,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Lv. $level',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
