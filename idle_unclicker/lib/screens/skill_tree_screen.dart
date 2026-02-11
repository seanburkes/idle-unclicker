import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skill_tree.dart';
import '../providers/game_provider.dart';

class SkillTreeScreen extends StatelessWidget {
  const SkillTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'SKILL TREE',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final skillTree = game.skillTree;
          if (skillTree == null) {
            return const Center(
              child: Text(
                'Skill system initializing...',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final unlocked = skillTree.getUnlockedNodes();
          final bonuses = skillTree.getTotalBonuses();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                _buildProgressBar(skillTree),
                const SizedBox(height: 16),

                // Playstyle indicator
                _buildPlaystyleIndicator(skillTree),
                const SizedBox(height: 24),

                // Active bonuses
                if (bonuses.isNotEmpty) ...[
                  const Text(
                    'ACTIVE BONUSES',
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

                // Skill tree grid
                const Text(
                  'SKILL TREE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSkillTreeGrid(skillTree),
                const SizedBox(height: 24),

                // Recently unlocked
                if (unlocked.isNotEmpty) ...[
                  const Text(
                    'RECENTLY UNLOCKED',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...unlocked.reversed
                      .take(3)
                      .map((node) => _buildUnlockedNode(node)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(SkillTree skillTree) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Next Skill Unlock',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${skillTree.progressPercent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: skillTree.unlockProgress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 12,
          ),
          const SizedBox(height: 8),
          Text(
            'Skills unlock as you play (${skillTree.totalPlaytimeMinutes} min played)',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaystyleIndicator(SkillTree skillTree) {
    final branchColors = {
      'combat': Colors.red,
      'survival': Colors.green,
      'wealth': Colors.amber,
      null: Colors.grey,
    };

    final branchIcons = {
      'combat': Icons.sports_kabaddi,
      'survival': Icons.shield,
      'wealth': Icons.attach_money,
      null: Icons.help,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: branchColors[skillTree.preferredBranch]!),
        borderRadius: BorderRadius.circular(8),
        color: branchColors[skillTree.preferredBranch]!.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(
            branchIcons[skillTree.preferredBranch],
            color: branchColors[skillTree.preferredBranch],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detected Playstyle: ${skillTree.playstyle.toUpperCase()}',
                  style: TextStyle(
                    color: branchColors[skillTree.preferredBranch],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  skillTree.preferredBranch != null
                      ? 'Focusing on ${skillTree.preferredBranch} branch'
                      : 'Balanced progression across all branches',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusesList(Map<String, double> bonuses) {
    final bonusDescriptions = {
      'damage': 'Damage Dealt',
      'attackSpeed': 'Attack Speed',
      'critChance': 'Critical Chance',
      'damageTaken': 'Damage Taken',
      'lifeSteal': 'Life Steal',
      'berserkDamage': 'Berserk Damage',
      'execute': 'Execute Threshold',
      'damageReduction': 'Damage Reduction',
      'hpRegen': 'HP Regeneration',
      'evasion': 'Evasion',
      'maxHp': 'Max HP',
      'secondWind': 'Second Wind',
      'statusImmunity': 'Status Immunity',
      'resurrection': 'Resurrection',
      'goldFind': 'Gold Find',
      'potionDrop': 'Potion Drop Rate',
      'shopDiscount': 'Shop Discount',
      'itemQuality': 'Item Quality',
      'xpGain': 'XP Gain',
      'goldPerKill': 'Gold Per Kill',
      'goldInterest': 'Gold Interest',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: bonuses.entries.map((entry) {
        final isPositive = entry.value > 0;
        final percent = (entry.value * 100).toStringAsFixed(0);
        final desc = bonusDescriptions[entry.key] ?? entry.key;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$desc: ${isPositive ? '+' : ''}$percent%',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillTreeGrid(SkillTree skillTree) {
    return Column(
      children: [
        // Combat branch
        _buildBranchSection(
          'COMBAT',
          Colors.red,
          Icons.sports_kabaddi,
          SkillTreeData.combatNodes,
          skillTree.unlockedNodes,
        ),
        const SizedBox(height: 16),

        // Survival branch
        _buildBranchSection(
          'SURVIVAL',
          Colors.green,
          Icons.shield,
          SkillTreeData.survivalNodes,
          skillTree.unlockedNodes,
        ),
        const SizedBox(height: 16),

        // Wealth branch
        _buildBranchSection(
          'WEALTH',
          Colors.amber,
          Icons.attach_money,
          SkillTreeData.wealthNodes,
          skillTree.unlockedNodes,
        ),
      ],
    );
  }

  Widget _buildBranchSection(
    String name,
    Color color,
    IconData icon,
    List<SkillNode> nodes,
    List<String> unlockedIds,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${nodes.where((n) => unlockedIds.contains(n.id)).length}/${nodes.length}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: nodes
                .map(
                  (node) =>
                      _buildNodeHex(node, unlockedIds.contains(node.id), color),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeHex(SkillNode node, bool isUnlocked, Color branchColor) {
    return Tooltip(
      message: '${node.name}\n${node.description}',
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isUnlocked ? branchColor.withOpacity(0.3) : Colors.grey[900],
          border: Border.all(
            color: isUnlocked ? branchColor : Colors.grey[700]!,
            width: isUnlocked ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isUnlocked
              ? Icon(Icons.check, color: branchColor, size: 24)
              : Icon(Icons.lock, color: Colors.grey[700], size: 16),
        ),
      ),
    );
  }

  Widget _buildUnlockedNode(SkillNode node) {
    final branchColors = {
      'combat': Colors.red,
      'survival': Colors.green,
      'wealth': Colors.amber,
    };

    final color = branchColors[node.branch] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                Text(
                  node.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
