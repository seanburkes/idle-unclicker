import 'package:flutter/material.dart';
import '../molecules/game_card.dart';
import '../molecules/stat_row.dart';

class CombatStatsPanel extends StatelessWidget {
  final int health;
  final int maxHealth;
  final int mana;
  final int maxMana;
  final int attack;
  final int defense;

  const CombatStatsPanel({
    super.key,
    required this.health,
    required this.maxHealth,
    required this.mana,
    required this.maxMana,
    required this.attack,
    required this.defense,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      borderColor: Colors.red,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMBAT STATS',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          StatRow(label: 'Health', value: '75/100', valueColor: Colors.red),
          SizedBox(height: 8),
          StatRow(label: 'Mana', value: '50/100', valueColor: Colors.blue),
          SizedBox(height: 8),
          Divider(color: Colors.grey),
          SizedBox(height: 8),
          StatRow(label: 'Attack', value: '25', valueColor: Colors.red),
          SizedBox(height: 8),
          StatRow(label: 'Defense', value: '15', valueColor: Colors.blue),
        ],
      ),
    );
  }
}
