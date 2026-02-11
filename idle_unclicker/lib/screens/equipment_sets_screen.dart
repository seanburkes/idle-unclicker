import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/equipment_sets.dart';

/// EquipmentSetsScreen - UI for viewing and managing equipment sets
class EquipmentSetsScreen extends StatelessWidget {
  const EquipmentSetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final discoveredSets = game.discoveredSets;
        final activeSets = game.activeSets;
        final currentSynergy = game.currentSynergy;
        final hasCorruption = game.hasCorruptionEquipped;
        final corruptionDrain = game.totalCorruptionDrain;
        final activeBonuses = game.activeSetBonuses;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              if (hasCorruption) _buildCorruptionWarning(corruptionDrain),
              if (hasCorruption) const SizedBox(height: 12),
              _buildActiveBonusesSection(activeBonuses),
              const SizedBox(height: 16),
              if (currentSynergy != null) _buildSynergySection(currentSynergy),
              if (currentSynergy != null) const SizedBox(height: 16),
              _buildSetsGrid(discoveredSets, activeSets, game),
              const SizedBox(height: 16),
              _buildRecommendationsSection(game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(8),
        color: Colors.amber.withOpacity(0.1),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.amber, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EQUIPMENT SETS',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Collect sets for powerful bonuses. Mix sets for synergies.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorruptionWarning(double drain) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
        color: Colors.purple.withOpacity(0.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.purple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CORRUPTION ACTIVE',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Void Whisperers draining ${(drain * 100).toStringAsFixed(1)}% HP per tick',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBonusesSection(List<SetBonus> bonuses) {
    if (bonuses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No Active Set Bonuses',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
        color: Colors.green.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE BONUSES',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...bonuses.map((bonus) => _buildBonusRow(bonus)),
        ],
      ),
    );
  }

  Widget _buildBonusRow(SetBonus bonus) {
    final isCorrupted = bonus.isCorrupted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCorrupted ? Icons.local_fire_department : Icons.check_circle,
            color: isCorrupted ? Colors.purple : Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${bonus.bonusTypeName}: ${bonus.description}',
              style: TextStyle(
                color: isCorrupted ? Colors.purple : Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynergySection(SetSynergy synergy) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: synergy.isUnexpected ? Colors.pink : Colors.cyan,
        ),
        borderRadius: BorderRadius.circular(8),
        color: synergy.isUnexpected
            ? Colors.pink.withOpacity(0.1)
            : Colors.cyan.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                synergy.isUnexpected ? Icons.auto_awesome : Icons.merge_type,
                color: synergy.isUnexpected ? Colors.pink : Colors.cyan,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  synergy.isUnexpected
                      ? '★ UNEXPECTED SYNERGY ★'
                      : 'SET SYNERGY',
                  style: TextStyle(
                    color: synergy.isUnexpected ? Colors.pink : Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            synergy.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            synergy.description,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            synergy.synergyBonus.description,
            style: TextStyle(
              color: synergy.isUnexpected ? Colors.pink : Colors.cyan,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsGrid(
    List<EquipmentSet> sets,
    Map<SetName, ActiveSet> activeSets,
    GameProvider game,
  ) {
    if (sets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2, color: Colors.grey, size: 48),
              SizedBox(height: 12),
              Text(
                'No Sets Discovered',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Equipment sets will appear here as you find set pieces',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DISCOVERED SETS',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...sets.map((set) => _buildSetCard(set, activeSets[set.name], game)),
      ],
    );
  }

  Widget _buildSetCard(EquipmentSet set, ActiveSet? active, GameProvider game) {
    final piecesEquipped = active?.piecesEquipped ?? 0;
    final isComplete = piecesEquipped >= 6;
    final color = _parseColor(set.setColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isComplete ? color : color.withOpacity(0.5),
          width: isComplete ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(set.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set.displayName,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      set.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color),
                ),
                child: Text(
                  '$piecesEquipped/6',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (set.isCorrupted) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.purple,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'CORRUPTED',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(color: Colors.grey, height: 16),

          // Bonus tiers
          _buildBonusTier(set, 2, piecesEquipped),
          const SizedBox(height: 4),
          _buildBonusTier(set, 4, piecesEquipped),
          const SizedBox(height: 4),
          _buildBonusTier(set, 6, piecesEquipped),
        ],
      ),
    );
  }

  Widget _buildBonusTier(EquipmentSet set, int tier, int piecesEquipped) {
    final bonus = set.bonuses.firstWhere(
      (b) => b.piecesRequired == tier,
      orElse: () => SetBonus(
        type: SetBonusType.statBonus,
        piecesRequired: tier,
        magnitude: 0,
        description: 'No bonus at this tier',
      ),
    );
    final isUnlocked = piecesEquipped >= tier;

    return Row(
      children: [
        Icon(
          isUnlocked ? Icons.check_box : Icons.check_box_outline_blank,
          color: isUnlocked ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          '$tier pieces: ',
          style: TextStyle(
            color: isUnlocked ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            bonus.description.isNotEmpty
                ? bonus.description
                : bonus.bonusTypeName,
            style: TextStyle(
              color: isUnlocked ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(GameProvider game) {
    final activeSets = game.activeSets;
    final recommendations = <String>[];

    // Generate recommendations based on active sets
    for (final entry in activeSets.entries) {
      final setName = entry.key;
      final active = entry.value;

      if (active.piecesToNextBonus > 0) {
        recommendations.add(
          '${setName.toString().split('.').last}: ${active.piecesToNextBonus} more pieces for next bonus',
        );
      }
    }

    if (activeSets.length >= 2) {
      recommendations.add(
        'Mixing ${activeSets.length} sets - watch for synergies!',
      );
    }

    if (game.hasCorruptionEquipped) {
      recommendations.add(
        'Warning: Monitor HP regen to sustain corruption drain',
      );
    }

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AUTOMATION RECOMMENDATIONS',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.yellow, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}
