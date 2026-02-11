import 'package:flutter/material.dart' hide MaterialType;
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/professions.dart';

/// ProfessionsScreen - UI for managing gathering professions and crafting
class ProfessionsScreen extends StatelessWidget {
  const ProfessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(game),
              const SizedBox(height: 16),
              _buildAutoCraftToggle(game),
              const SizedBox(height: 16),
              _buildProfessionsList(game),
              const SizedBox(height: 16),
              _buildAstralSection(game),
              const SizedBox(height: 16),
              _buildInventoryGrid(game),
              const SizedBox(height: 16),
              _buildRecipesList(game),
              const SizedBox(height: 16),
              _buildRecentGatherLog(game),
              const SizedBox(height: 16),
              _buildBonusesSummary(game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(GameProvider game) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown),
        borderRadius: BorderRadius.circular(8),
        color: Colors.brown.withOpacity(0.1),
      ),
      child: Row(
        children: [
          const Icon(Icons.work, color: Colors.brown, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROFESSIONS',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Auto-gather materials in combat, craft in town',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${game.totalCraftsCompleted} crafts',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                '${game.professionInventoryValue}💰 value',
                style: const TextStyle(color: Colors.amber, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCraftToggle(GameProvider game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_mode, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Auto-Craft',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: game.professionAutoCraftEnabled,
            onChanged: (value) => game.toggleProfessionAutoCraft(),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionsList(GameProvider game) {
    final professions = game.professions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR PROFESSIONS',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...professions.map((profession) => _buildProfessionCard(profession)),
      ],
    );
  }

  Widget _buildProfessionCard(Profession profession) {
    if (!profession.isUnlocked) {
      return const SizedBox.shrink();
    }

    final progressColor = _parseColor(profession.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: progressColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(profession.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profession.name,
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      profession.description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Lv.${profession.level}',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Level progress bar
          LinearProgressIndicator(
            value: profession.levelProgress,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP: ${profession.experience}/${profession.experienceToNextLevel}',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Text(
                'Gather Rate: ${profession.gatherRate.toStringAsFixed(2)}/tick',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAstralSection(GameProvider game) {
    final astralCount = game.astralMaterialCount;

    if (astralCount == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.purple.withOpacity(0.05),
        ),
        child: Row(
          children: [
            const Icon(Icons.star_border, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ASTRAL MATERIALS',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Reach 80%+ Focus to find rare astral materials',
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
          Row(
            children: [
              const Icon(Icons.star, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'ASTRAL MATERIALS',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$astralCount items',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Show astral materials
          Wrap(
            spacing: 8,
            children: game.professionInventory.entries
                .where((e) => e.key.isAstral && e.value > 0)
                .map((e) => _buildMaterialChip(e.key, e.value, isAstral: true))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid(GameProvider game) {
    final materialsByProfession = game.materialsByProfession;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MATERIAL INVENTORY',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...materialsByProfession.entries.map((entry) {
          final professionType = entry.key;
          final materials = entry.value;

          if (materials.isEmpty || materials.every((m) => m['quantity'] == 0)) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      professionType.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      professionType.displayName.toUpperCase(),
                      style: TextStyle(
                        color: _parseColor(professionType.color),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: materials
                      .where((m) => m['quantity'] as int > 0)
                      .map(
                        (m) => _buildMaterialChip(
                          m['type'] as MaterialType,
                          m['quantity'] as int,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMaterialChip(
    MaterialType type,
    int quantity, {
    bool isAstral = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAstral
            ? Colors.purple.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: isAstral ? Colors.purple : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            type.displayName,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            'x$quantity',
            style: TextStyle(
              color: isAstral ? Colors.purple : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList(GameProvider game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CRAFTABLE ITEMS',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...CraftedItemType.values.map((itemType) {
          final canCraft = game.canCraftItem(itemType);
          final currentCount =
              game.professionState?.getCraftedItemQuantity(itemType) ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: canCraft ? Colors.green : Colors.grey.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
              color: canCraft ? Colors.green.withOpacity(0.05) : Colors.black,
            ),
            child: Row(
              children: [
                Text(itemType.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemType.displayName,
                        style: TextStyle(
                          color: canCraft ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        itemType.description,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      // Show required materials
                      Wrap(
                        spacing: 4,
                        children: itemType.requiredMaterials.entries.map((e) {
                          final hasEnough =
                              (game.professionInventory[e.key] ?? 0) >= e.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: hasEnough
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${e.key.displayName} x${e.value}',
                              style: TextStyle(
                                color: hasEnough ? Colors.green : Colors.red,
                                fontSize: 9,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'x$currentCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 28,
                      child: Builder(
                        builder: (buttonContext) => ElevatedButton(
                          onPressed: canCraft
                              ? () {
                                  final result = game.craftItem(itemType);
                                  ScaffoldMessenger.of(buttonContext).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message,
                                        style: TextStyle(
                                          color: result.success
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      backgroundColor: Colors.black,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canCraft
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            foregroundColor:
                                canCraft ? Colors.green : Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Craft', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }


  Widget _buildRecentGatherLog(GameProvider game) {
    final recentLog = game.recentGatherLog;

    if (recentLog.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT GATHERING',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...recentLog.reversed
              .take(5)
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_right,
                        color: Colors.grey,
                        size: 16,
                      ),
                      Expanded(
                        child: Text(
                          entry,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
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

  Widget _buildBonusesSummary(GameProvider game) {
    final professions = game.professions.where((p) => p.isUnlocked).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown),
        borderRadius: BorderRadius.circular(8),
        color: Colors.brown.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROFESSION BONUSES',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...professions.map((profession) {
            final bonus = (profession.getGatherBonus() - 1.0) * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(profession.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    profession.name,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '+${bonus.toStringAsFixed(0)}% gather',
                    style: TextStyle(
                      color: _parseColor(profession.color),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
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
