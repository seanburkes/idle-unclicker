import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/boss_rush.dart';
import '../providers/game_provider.dart';

class BossRushScreen extends StatelessWidget {
  const BossRushScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'BOSS RUSH & RIFTS',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final currentBoss = game.currentBoss;
          final dailyRift = game.dailyRift;
          final defeatedBosses = game.defeatedBosses;
          final essenceInventory = game.essenceInventory;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Essence Inventory Section
                _buildEssenceInventory(essenceInventory),
                const SizedBox(height: 24),

                // Current Boss Section
                if (currentBoss != null && !currentBoss.isDefeated) ...[
                  _buildCurrentBossSection(currentBoss, game),
                  const SizedBox(height: 24),
                ],

                // Daily Rift Section
                _buildDailyRiftSection(dailyRift, game),
                const SizedBox(height: 24),

                // Boss History
                _buildBossHistory(defeatedBosses),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEssenceInventory(Map<EssenceType, int> inventory) {
    final total = inventory.values.fold(0, (sum, count) => sum + count);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.diamond, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              const Text(
                'ESSENCE INVENTORY',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Total: $total',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EssenceType.values.map((essence) {
              final count = inventory[essence] ?? 0;
              final color = Color(essence.colorValue);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(4),
                  color: color.withOpacity(0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(essence.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${essence.displayName}: $count',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBossSection(Boss boss, GameProvider game) {
    final confidence =
        game.bossRiftService?.canAttemptBoss(game.character!, boss) ?? 0.0;

    Color confidenceColor;
    if (confidence >= 70) {
      confidenceColor = Colors.green;
    } else if (confidence >= 50) {
      confidenceColor = Colors.orange;
    } else {
      confidenceColor = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.red.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text(
                'CURRENT BOSS',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Floor ${boss.floor}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            boss.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(boss.mechanic.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boss.mechanic.displayName,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      boss.mechanic.description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBossStatRow('Health', '${boss.maxHealth}', Colors.red),
          _buildBossStatRow('Damage', '${boss.damage}', Colors.orange),
          _buildBossStatRow('Armor', '${boss.armor}', Colors.blue),
          _buildBossStatRow('Evasion', '${boss.evasion}', Colors.green),
          const Divider(color: Colors.grey, height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Power Estimation',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${confidence.toStringAsFixed(0)}% Confidence',
                      style: TextStyle(
                        color: confidenceColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (game.inTown) ...[
                ElevatedButton(
                  onPressed: confidence >= 70
                      ? () => game.startBossFight()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('FIGHT'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => game.skipBoss(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SKIP'),
                ),
              ] else ...[
                Text(
                  game.isBossFight ? 'In Combat!' : 'Enter town to fight',
                  style: TextStyle(
                    color: game.isBossFight ? Colors.red : Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBossStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRiftSection(Rift? rift, GameProvider game) {
    if (rift == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text(
              'DAILY RIFT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'No rift available. Check back tomorrow!',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final isCompleted = rift.completed;
    final confidence =
        game.bossRiftService?.shouldAttemptRift(game.character!, rift) ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCompleted ? Colors.grey : Colors.cyan,
          width: isCompleted ? 1 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isCompleted ? Colors.transparent : Colors.cyan.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.videogame_asset,
                color: isCompleted ? Colors.grey : Colors.cyan,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'DAILY RIFT',
                style: TextStyle(
                  color: isCompleted ? Colors.grey : Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'COMPLETED',
                        style: TextStyle(color: Colors.green, fontSize: 10),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AVAILABLE',
                    style: TextStyle(color: Colors.cyan, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rift.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rift.description,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(4),
              color: Colors.orange.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Text(rift.modifier.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rift.modifier.displayName,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        rift.modifier.description,
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildRiftStat('Depth', '${rift.depth} floors', Colors.purple),
              const SizedBox(width: 16),
              _buildRiftStat(
                'Best Floor',
                '${rift.playerBestFloor}/${rift.depth}',
                Colors.green,
              ),
            ],
          ),
          if (!isCompleted && game.inTown) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confidence: ${confidence.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: confidence >= 70
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: confidence >= 70
                      ? () => game.attemptDailyRift()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('ENTER RIFT'),
                ),
              ],
            ),
          ],
          if (rift.echoLeaderboard.isNotEmpty) ...[
            const Divider(color: Colors.grey, height: 24),
            const Text(
              'ECHO LEADERBOARD',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...rift.echoLeaderboard
                .take(5)
                .map((entry) => _buildLeaderboardEntry(entry)),
          ],
        ],
      ),
    );
  }

  Widget _buildRiftStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(EchoEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            entry.isPlayer ? Icons.person : Icons.smart_toy,
            color: entry.isPlayer ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.isPlayer ? '${entry.echoName} (You)' : entry.echoName,
              style: TextStyle(
                color: entry.isPlayer ? Colors.green : Colors.grey[300],
                fontSize: 12,
              ),
            ),
          ),
          Text(
            'Lv.${entry.level}',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          const SizedBox(width: 8),
          Text(
            'Floor ${entry.floorReached}',
            style: TextStyle(
              color: entry.isPlayer ? Colors.green : Colors.cyan,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBossHistory(List<Boss> defeatedBosses) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEFEATED BOSSES',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (defeatedBosses.isEmpty)
            const Text(
              'No bosses defeated yet. They appear every 5th floor!',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          else
            ...defeatedBosses
                .take(5)
                .map((boss) => _buildDefeatedBossEntry(boss)),
          if (defeatedBosses.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${defeatedBosses.length - 5} more...',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefeatedBossEntry(Boss boss) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(boss.mechanic.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boss.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Floor ${boss.floor} • ${boss.mechanic.displayName}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 4,
            children: boss.essencesDropped
                .map((e) => Text(e.icon, style: const TextStyle(fontSize: 12)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Helper extension for Color since we're in a different file
extension ColorHelper on EssenceType {
  Color get color {
    switch (this) {
      case EssenceType.fire:
        return const Color(0xFFFF4444);
      case EssenceType.ice:
        return const Color(0xFF44AAFF);
      case EssenceType.lightning:
        return const Color(0xFFFFDD44);
      case EssenceType.shadow:
        return const Color(0xFF6644AA);
      case EssenceType.nature:
        return const Color(0xFF44AA44);
      case EssenceType.arcane:
        return const Color(0xFFAA44AA);
      case EssenceType.divine:
        return const Color(0xFFFFD700);
      case EssenceType.chaos:
        return const Color(0xFFFF00FF);
    }
  }
}
