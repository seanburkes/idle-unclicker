import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';

class AscensionScreen extends StatelessWidget {
  const AscensionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '☆ ECHO SANCTUARY ☆',
          style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final gameState = game.gameState;
          if (gameState == null) {
            return const Center(
              child: Text('Loading...', style: TextStyle(color: Colors.grey)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Echo Shards display
                _buildShardsHeader(
                  gameState.echoShards,
                  gameState.totalEchoesCollected,
                ),
                const SizedBox(height: 24),

                // Ascension info
                if (game.ascensionAvailable) ...[
                  _buildAscensionOffer(game.pendingEchoShards, context),
                  const SizedBox(height: 24),
                ],

                // Meta-upgrades
                const Text(
                  'PERMANENT UPGRADES',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildUpgradeCard(
                  'Vital Echo',
                  '+5% Max HP per level',
                  gameState.startingHpBonus,
                  20,
                  50,
                  gameState.echoShards,
                  Colors.red,
                  () => _purchaseUpgrade(context, 'hp'),
                ),
                const SizedBox(height: 12),
                _buildUpgradeCard(
                  'Prepared Spirit',
                  '+1 Starting Potion per level',
                  gameState.startingPotionBonus,
                  10,
                  100,
                  gameState.echoShards,
                  Colors.purple,
                  () => _purchaseUpgrade(context, 'potion'),
                ),
                const SizedBox(height: 12),
                _buildUpgradeCard(
                  'Quick Learner',
                  '+10% XP Gain per level',
                  gameState.xpGainBonus,
                  20,
                  75,
                  gameState.echoShards,
                  Colors.blue,
                  () => _purchaseUpgrade(context, 'xp'),
                ),
                const SizedBox(height: 12),
                _buildUpgradeCard(
                  'Bold Descent',
                  '+1 Starting Depth per level',
                  gameState.startingDepthBonus,
                  10,
                  150,
                  gameState.echoShards,
                  Colors.orange,
                  () => _purchaseUpgrade(context, 'depth'),
                ),

                const SizedBox(height: 24),

                // Unlocks
                _buildUnlocksSection(gameState),

                const SizedBox(height: 24),

                // Stats
                _buildStatsSection(gameState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShardsHeader(int currentShards, int totalCollected) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan, width: 2),
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.cyan.withOpacity(0.1), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'ECHO SHARDS',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currentShards',
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Total Collected: $totalCollected',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAscensionOffer(int shards, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.amber.withOpacity(0.1),
      ),
      child: Column(
        children: [
          const Text(
            '☆ ASCENSION AVAILABLE ☆',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your current hero can ascend for $shards Echo Shards',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<GameProvider>().performAscension();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'ASCEND',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<GameProvider>().declineAscension();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('CONTINUE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(
    String name,
    String description,
    int currentLevel,
    int maxLevel,
    int cost,
    int availableShards,
    Color color,
    VoidCallback onPurchase,
  ) {
    final canAfford = availableShards >= cost;
    final isMaxed = currentLevel >= maxLevel;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: isMaxed ? Colors.grey : color, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: isMaxed ? Colors.grey[900] : Colors.black,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Level: ',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      '$currentLevel/$maxLevel',
                      style: TextStyle(
                        color: isMaxed ? Colors.grey : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!isMaxed) ...[
                      Icon(Icons.diamond, color: Colors.cyan, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$cost',
                        style: TextStyle(
                          color: canAfford ? Colors.cyan : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMaxed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'MAXED',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: canAfford ? onPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? color : Colors.grey[800],
                foregroundColor: Colors.black,
              ),
              child: const Text('UPGRADE'),
            ),
        ],
      ),
    );
  }

  Widget _buildUnlocksSection(GameState gameState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UNLOCKED CONTENT',
          style: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildUnlockCategory(
                'Races',
                gameState.unlockedRaces,
                Colors.yellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUnlockCategory(
                'Classes',
                gameState.unlockedClasses,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnlockCategory(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: color, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    item,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (items.length < 5) ...[
            const SizedBox(height: 4),
            Text(
              '${5 - items.length} more to unlock...',
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection(GameState gameState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LEGACY STATISTICS',
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatRow('Total Ascensions', '${gameState.totalAscensions}'),
          _buildStatRow('Echo Shards Available', '${gameState.echoShards}'),
          _buildStatRow('All-time Shards', '${gameState.totalEchoesCollected}'),
          const Divider(color: Colors.grey),
          _buildStatRow(
            'Current HP Bonus',
            '+${gameState.startingHpBonus * 5}%',
          ),
          _buildStatRow(
            'Starting Potions Bonus',
            '+${gameState.startingPotionBonus}',
          ),
          _buildStatRow('XP Gain Bonus', '+${gameState.xpGainBonus * 10}%'),
          _buildStatRow(
            'Starting Depth Bonus',
            '+${gameState.startingDepthBonus}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseUpgrade(BuildContext context, String type) {
    final game = context.read<GameProvider>();
    final gameState = game.gameState;

    if (gameState == null) return;

    if (gameState.purchaseUpgrade(type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Upgrade purchased!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
