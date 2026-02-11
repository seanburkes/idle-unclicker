import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/legendary_items.dart';
import '../services/legendary_item_service.dart';
import '../providers/game_provider.dart';

class LegendaryItemsScreen extends StatelessWidget {
  const LegendaryItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final legendaryService = game.legendaryItemService;
        final collection = legendaryService?.collection;

        if (collection == null) {
          return const Center(
            child: Text(
              'Loading legendary items...',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final stats = legendaryService!.getCollectionStats();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCollectionHeader(stats),
              const SizedBox(height: 16),
              _buildDropChanceIndicator(game),
              const SizedBox(height: 16),
              _buildOwnedLegendaries(legendaryService),
              const SizedBox(height: 16),
              _buildUndiscoveredLegendaries(legendaryService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCollectionHeader(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('👑', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'LEGENDARY COLLECTION',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Owned', '${stats['totalOwned']}', Colors.green),
              _buildStatColumn(
                'Discovered',
                '${stats['totalDiscovered']}',
                Colors.blue,
              ),
              _buildStatColumn(
                'Awakened',
                '${stats['awakenedCount']}',
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (stats['completionPercent'] as double) / 100,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            'Collection: ${(stats['completionPercent'] as double).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildDropChanceIndicator(GameProvider game) {
    final currentFloor = game.character?.dungeonDepth ?? 1;
    final isBossFloor = currentFloor % 5 == 0;

    if (!isBossFloor) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info, color: Colors.grey, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Legendary items only drop from bosses (floors 5, 10, 15, etc.)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    final legendaryService = game.legendaryItemService;
    final dropChance =
        legendaryService?.getDropChanceDisplay(currentFloor) ?? '5.0%';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.withOpacity(0.1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BOSS FLOOR - LEGENDARY DROP CHANCE',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Current chance: $dropChance',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnedLegendaries(LegendaryItemService service) {
    final owned = service.ownedLegendaries;

    if (owned.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          children: [
            Icon(Icons.search, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text(
              'No Legendary Items Yet',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Defeat bosses to find legendary items!',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OWNED LEGENDARIES',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...owned.map((item) => _buildLegendaryCard(item, service)),
      ],
    );
  }

  Widget _buildLegendaryCard(LegendaryItem item, LegendaryItemService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: item.isAwakened ? Colors.purple : Colors.amber,
          width: item.isAwakened ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: ExpansionTile(
        leading: Text(item.typeIcon, style: const TextStyle(fontSize: 24)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  color: item.isAwakened ? Colors.purple : Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (item.isAwakened)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '★ AWAKENED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              '${item.effect.type.icon} ${item.effect.type.displayName}',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            if (item.reforgeCount > 0) ...[
              const SizedBox(width: 8),
              Text(
                '⚒️ ${item.reforgeCount}/10',
                style: const TextStyle(color: Colors.cyan, fontSize: 11),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '"${item.lore}"',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildEffectDisplay(item),
                const SizedBox(height: 12),
                _buildStatsDisplay(item),
                if (item.hasSentience) ...[
                  const SizedBox(height: 12),
                  _buildSentienceDisplay(item, service),
                ],
                if (item.canReforge) ...[
                  const SizedBox(height: 12),
                  _buildReforgeButton(item, service),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectDisplay(LegendaryItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: Colors.amber.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LEGENDARY EFFECT',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.effect.type.icon} ${item.effect.formattedDescription}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (item.isAwakened)
            Text(
              '★ Awakened: Effect is 50% stronger!',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsDisplay(LegendaryItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BASE STATS',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        ...item.baseStats.map(
          (stat) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '• ${stat.displayString}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentienceDisplay(
    LegendaryItem item,
    LegendaryItemService service,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: Colors.purple.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.purple, size: 14),
              const SizedBox(width: 4),
              const Text(
                'SENTIENCE',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.sentience!.displayName,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            item.sentience!.desireDescription,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: item.sentiencePercent,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            minHeight: 6,
          ),
          const SizedBox(height: 4),
          Text(
            'Progress: ${item.sentienceProgress}%',
            style: TextStyle(
              color: item.isAwakened ? Colors.purple : Colors.grey,
              fontSize: 11,
              fontWeight: item.isAwakened ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReforgeButton(LegendaryItem item, LegendaryItemService service) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final canAfford =
            game.character != null &&
            game.character!.gold >= LegendaryItemService.reforgeGoldCost;

        return ElevatedButton.icon(
          onPressed: canAfford
              ? () => _showReforgeConfirmation(context, item, game)
              : null,
          icon: const Icon(Icons.auto_fix_high, size: 16),
          label: Text(
            'Reforge (${LegendaryItemService.reforgeGoldCost} gold + 1 Essence)',
            style: const TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.grey[800],
            disabledForegroundColor: Colors.grey,
          ),
        );
      },
    );
  }

  void _showReforgeConfirmation(
    BuildContext context,
    LegendaryItem item,
    GameProvider game,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Reforge Legendary?',
          style: TextStyle(color: Colors.amber, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reforge ${item.name}?',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Keeps legendary effect',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Text(
              '• Rerolls base stats',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Text(
              '• Improves stat potential',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              'Cost: ${LegendaryItemService.reforgeGoldCost} gold + 1 Essence',
              style: const TextStyle(color: Colors.amber, fontSize: 12),
            ),
            Text(
              'Current reforges: ${item.reforgeCount}/10',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Get total essences from boss rush state
              final totalEssences = game.bossRushState?.totalEssences ?? 0;

              final result = game.legendaryItemService?.reforgeLegendary(
                item,
                game.character!.gold,
                totalEssences,
              );

              Navigator.pop(context);

              if (result != null) {
                // Deduct costs
                game.character!.gold -= LegendaryItemService.reforgeGoldCost;
                // Would deduct essence here too

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} reforged successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to reforge. Check resources.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.black,
            ),
            child: const Text('Reforge'),
          ),
        ],
      ),
    );
  }

  Widget _buildUndiscoveredLegendaries(LegendaryItemService service) {
    final undiscovered = service.undiscoveredLegendaries;

    if (undiscovered.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UNDISCOVERED (${undiscovered.length})',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: undiscovered.map((id) {
            final definition = LegendaryDefinitions.getDefinition(id);
            if (definition == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[800]!),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[900],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    definition.typeIcon,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '???',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
