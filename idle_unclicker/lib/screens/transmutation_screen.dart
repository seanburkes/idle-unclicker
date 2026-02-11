import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/transmutation.dart';
import '../services/transmutation_service.dart';

class TransmutationScreen extends StatelessWidget {
  const TransmutationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final state = game.transmutationState;
        final service = game.transmutationService;

        if (state == null || service == null) {
          return const Center(
            child: Text(
              'Transmutation not available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final stats = state.getStats();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TRANSMUTATION',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildAutoToggle(context, game, state),
                ],
              ),
              const SizedBox(height: 12),

              // Stats Cards
              _buildStatsGrid(stats),
              const SizedBox(height: 16),

              // Miracle Chance Info
              _buildMiracleInfo(service),
              const SizedBox(height: 16),

              // Available Recipes
              _buildRecipesSection(service),
              const SizedBox(height: 16),

              // Recent History
              _buildHistorySection(state),
              const SizedBox(height: 16),

              // Auto Settings
              _buildAutoSettingsSection(context, game, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAutoToggle(
    BuildContext context,
    GameProvider game,
    TransmutationState state,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Auto:',
          style: TextStyle(
            color: state.autoTransmuteEnabled ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
        Switch(
          value: state.autoTransmuteEnabled,
          onChanged: (value) => game.toggleAutoTransmute(),
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildStatCard(
          'Total Transmuted',
          stats['totalTransmutations']?.toString() ?? '0',
          Colors.cyan,
        ),
        _buildStatCard(
          'Miracles',
          stats['totalMiracles']?.toString() ?? '0',
          Colors.yellow,
        ),
        _buildStatCard(
          'Legendary',
          stats['legendaryCount']?.toString() ?? '0',
          Colors.orange,
        ),
        _buildStatCard(
          'Volatile Rate',
          '${((stats['volatileSuccessRate'] ?? 0) * 100).toStringAsFixed(0)}%',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiracleInfo(TransmutationService service) {
    // Find epic → legendary recipe to show miracle chance
    final recipes = service.getRecipesForType(TransmutableItemType.equipment);
    final epicRecipe = recipes.firstWhere(
      (r) => r.fromTier == ItemTier.epic,
      orElse: () => TransmutationRecipe.standard(
        itemType: TransmutableItemType.equipment,
        fromTier: ItemTier.epic,
        toTier: ItemTier.legendary,
      ),
    );

    final miracleChance = service.calculateMiracleChance(epicRecipe);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ MIRACLE CHANCE ✨',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Epic → Legendary: ${(miracleChance * 100).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white),
          ),
          const Text(
            'Miracles grant bonus stats on legendary items!',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesSection(TransmutationService service) {
    final recipes = service.getRecipesForType(TransmutableItemType.equipment);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AVAILABLE RECIPES',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...recipes.take(4).map((recipe) => _buildRecipeCard(recipe)),
      ],
    );
  }

  Widget _buildRecipeCard(TransmutationRecipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recipe.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          if (recipe.miracleChance > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(recipe.miracleChance * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(TransmutationState state) {
    final history = state.recentHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT HISTORY',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          const Text(
            'No transmutations yet...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        else
          ...history.take(5).map((entry) => _buildHistoryEntry(entry)),
      ],
    );
  }

  Widget _buildHistoryEntry(TransmutationHistory entry) {
    final color = entry.result.success
        ? entry.result.wasMiracle
              ? Colors.orange
              : Colors.green
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${entry.recipe.displayName}: ${entry.result.message}',
        style: TextStyle(color: color, fontSize: 10),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAutoSettingsSection(
    BuildContext context,
    GameProvider game,
    TransmutationState state,
  ) {
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
            'AUTO-TRANSMUTE SETTINGS',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Threshold Tier:',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                state.autoTransmuteThreshold.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inventory Trigger:',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                '${state.inventoryFullThreshold}%',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
