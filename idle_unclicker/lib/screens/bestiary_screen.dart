import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bestiary.dart';
import '../providers/game_provider.dart';

class BestiaryScreen extends StatelessWidget {
  const BestiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'BESTIARY',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final bestiary = game.bestiary;
          if (bestiary == null) {
            return const Center(
              child: Text(
                'Bestiary initializing...',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final bonuses = bestiary.getTotalBonuses();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats header
                _buildStatsHeader(bestiary),
                const SizedBox(height: 24),

                // Knowledge bonuses
                if (bonuses.isNotEmpty) ...[
                  const Text(
                    'KNOWLEDGE BONUSES',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBonusesList(bonuses),
                  const SizedBox(height: 24),
                ],

                // Known monsters
                const Text(
                  'KNOWN CREATURES',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildKnownMonstersList(bestiary),

                const SizedBox(height: 24),

                // Unknown monsters
                const Text(
                  'UNKNOWN CREATURES',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUnknownMonstersList(bestiary),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(Bestiary bestiary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Total Kills', '${bestiary.totalKills}'),
              _buildStatColumn(
                'Unique Types',
                '${bestiary.totalUniqueMonsters}',
              ),
              _buildStatColumn('Known', '${bestiary.unlockedEntries.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _buildBonusesList(Map<String, double> bonuses) {
    final bonusDescriptions = {
      'damage': 'Damage vs Known Monsters',
      'evasion': 'Evasion vs Known Monsters',
      'loot': 'Loot from Known Monsters',
      'critChance': 'Critical Chance',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: bonuses.entries.map((entry) {
        final percent = (entry.value * 100).toStringAsFixed(0);
        final desc = bonusDescriptions[entry.key] ?? entry.key;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$desc: +$percent%',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKnownMonstersList(Bestiary bestiary) {
    final knownTypes = bestiary.unlockedEntries;

    if (knownTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No creatures studied yet.\nKill monsters to learn about them!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: knownTypes.map((type) {
        final kills = bestiary.getKillCount(type);
        final level = bestiary.getKnowledgeLevel(type);
        final data = BestiaryData.monsterTypes[type] ?? {};
        final visuals = BestiaryData.getVisuals(type);
        final milestones = bestiary.getMilestones(type);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Color(visuals['color'])),
            borderRadius: BorderRadius.circular(8),
            color: Color(visuals['color']).withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(visuals['icon'], style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? type,
                          style: TextStyle(
                            color: Color(visuals['color']),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data['description'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$kills kills',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          4,
                          (i) => Icon(
                            Icons.star,
                            size: 14,
                            color: i < level
                                ? Color(visuals['color'])
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Milestones
              ...milestones.map(
                (m) => Row(
                  children: [
                    Icon(
                      m['reached'] ? Icons.check_circle : Icons.circle_outlined,
                      size: 14,
                      color: m['reached']
                          ? Color(visuals['color'])
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${m['kills']}: ${m['bonus']}',
                      style: TextStyle(
                        color: m['reached'] ? Colors.white : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Weakness info at max level
              if (level >= 4) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.warning_amber, size: 14, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Weakness: ${data['weakness'] ?? 'Unknown'}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnknownMonstersList(Bestiary bestiary) {
    final allTypes = BestiaryData.monsterTypes.keys.toList();
    final knownTypes = bestiary.unlockedEntries;
    final unknownTypes = allTypes
        .where((t) => !knownTypes.contains(t))
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: unknownTypes.map((type) {
        final visuals = BestiaryData.getVisuals(type);
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(visuals['icon'], style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                '???',
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
