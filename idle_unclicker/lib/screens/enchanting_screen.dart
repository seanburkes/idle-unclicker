import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/enchanting.dart';

/// EnchantingScreen - UI for managing equipment enchanting, gems, and sockets
class EnchantingScreen extends StatelessWidget {
  const EnchantingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final enchantedEquipment = game.enchantedEquipment;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildRiskInfo(),
              const SizedBox(height: 16),
              if (enchantedEquipment.isEmpty)
                _buildEmptyState()
              else
                _buildEquipmentList(context, game, enchantedEquipment),
              const SizedBox(height: 16),
              _buildEnchantmentHistory(game),
              const SizedBox(height: 16),
              _buildTotalBonuses(game),
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
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
        color: Colors.purple.withOpacity(0.1),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_fix_high, color: Colors.purple, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENCHANTING',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Socket gems and enchant items for powerful bonuses',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.withOpacity(0.1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'RISK WARNING',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Base 5% chance to destroy item when enchanting',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            '• Risk increases by 1% per enchant attempt (max 20%)',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            '• Legendary items are NEVER auto-enchanted',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            '• Cursed enchantments: +25-35% bonus but -10-15% drawback',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              'No Enchanted Equipment',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Equipment will appear here as you acquire items with sockets',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentList(
    BuildContext context,
    GameProvider game,
    List<EnchantedEquipment> equipment,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR EQUIPMENT',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...equipment.map((item) => _buildEquipmentCard(context, game, item)),
      ],
    );
  }

  Widget _buildEquipmentCard(
    BuildContext context,
    GameProvider game,
    EnchantedEquipment equipment,
  ) {
    final isLegendary = equipment.baseEquipment.isLegendary;
    final risk = game.getEnchantmentRisk(equipment);
    final canEnchant = !isLegendary && game.inTown;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isLegendary ? Colors.amber : Colors.purple.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                equipment.baseEquipment.slot == 'weapon'
                    ? Icons.sports_martial_arts
                    : Icons.shield,
                color: _parseColor(equipment.rarityColor),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.displayName,
                      style: TextStyle(
                        color: _parseColor(equipment.rarityColor),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${equipment.rarityName} • Lv.${equipment.baseEquipment.level}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (equipment.isCursed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CURSED',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(color: Colors.grey, height: 16),

          // Sockets
          if (equipment.socketCount > 0) ...[
            const Text(
              'SOCKETS',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(equipment.socketCount, (index) {
                final socket = equipment.sockets[index];
                return _buildSocketIndicator(socket, index);
              }),
            ),
            const SizedBox(height: 12),
          ],

          // Enchantment info
          if (equipment.isEnchanted) ...[
            const Text(
              'ENCHANTMENT',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 8),
            _buildEnchantmentInfo(equipment),
            const SizedBox(height: 12),
          ],

          // Stats
          _buildStatsRow(equipment),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: canEnchant
                      ? () => _showEnchantDialog(context, game, equipment)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    isLegendary
                        ? 'Legendary (Locked)'
                        : 'Enchant (Risk: $risk)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocketIndicator(Socket socket, int index) {
    if (socket.hasGem && socket.gem != null) {
      final gem = socket.gem!;
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _parseColor(gem.color).withOpacity(0.2),
          border: Border.all(color: _parseColor(gem.color)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(gem.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '+${(gem.bonusPercent * 100).round()}%',
              style: TextStyle(
                color: _parseColor(gem.color),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (socket.isLocked) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.lock, color: Colors.grey, size: 16),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.add_circle_outline,
          color: Colors.grey,
          size: 16,
        ),
      );
    }
  }

  Widget _buildEnchantmentInfo(EnchantedEquipment equipment) {
    if (equipment.enchantment == null) return const SizedBox.shrink();

    final enchantment = equipment.enchantment!;
    final bonuses = enchantment.getBonuses();
    final penalties = enchantment.getCursePenalties();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...bonuses.entries.map((entry) {
          final value = (entry.value * 100).round();
          return Text(
            '+$value% ${entry.key.capitalize()}',
            style: const TextStyle(color: Colors.green, fontSize: 12),
          );
        }),
        if (enchantment.isCursed) ...[
          const SizedBox(height: 4),
          ...penalties.entries.map((entry) {
            final value = (entry.value * 100).round();
            return Text(
              '$value% ${entry.key.capitalize()}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildStatsRow(EnchantedEquipment equipment) {
    return Row(
      children: [
        if (equipment.effectiveAttackBonus > 0)
          _buildStatChip(
            'ATK',
            '+${equipment.effectiveAttackBonus}',
            Colors.red,
          ),
        if (equipment.effectiveDefenseBonus > 0)
          _buildStatChip(
            'DEF',
            '+${equipment.effectiveDefenseBonus}',
            Colors.blue,
          ),
        if (equipment.effectiveHealthBonus > 0)
          _buildStatChip(
            'HP',
            '+${equipment.effectiveHealthBonus}',
            Colors.green,
          ),
        if (equipment.effectiveManaBonus > 0)
          _buildStatChip('MP', '+${equipment.effectiveManaBonus}', Colors.cyan),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEnchantmentHistory(GameProvider game) {
    // Collect all history entries from enchanted equipment
    final allHistory = <String>[];
    for (final equipment in game.enchantedEquipment) {
      allHistory.addAll(equipment.historyEntries);
    }

    if (allHistory.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT HISTORY',
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...allHistory
              .take(5)
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• $entry',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTotalBonuses(GameProvider game) {
    final totalBonuses = game.getTotalEnchantmentBonuses();

    if (totalBonuses.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
        color: Colors.purple.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL BONUSES',
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: totalBonuses.entries.map((entry) {
              final value = (entry.value * 100).round();
              final color = value >= 0 ? Colors.green : Colors.red;
              final sign = value >= 0 ? '+' : '';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$sign$value% ${entry.key.capitalize()}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showEnchantDialog(
    BuildContext context,
    GameProvider game,
    EnchantedEquipment equipment,
  ) {
    final risk = game.getEnchantmentRisk(equipment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Enchant Item?',
          style: TextStyle(color: Colors.purple),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item: ${equipment.baseEquipment.name}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Destruction Risk: $risk',
              style: const TextStyle(color: Colors.orange, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '70% chance: Normal enchantment (+10-20%)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Text(
              '25% chance: Cursed enchantment (+25-35% with drawback)',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            const Text(
              '5% chance: Item destroyed!',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (equipment.enchantAttempts > 0)
              Text(
                'Previous enchant attempts: ${equipment.enchantAttempts}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
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
              final result = game.enchantItem(equipment);
              Navigator.pop(context);

              // Show result
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.message,
                    style: TextStyle(
                      color: result.destroyed
                          ? Colors.red
                          : result.success
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  backgroundColor: Colors.black,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enchant'),
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

// StringExtension is imported from enchanting.dart
