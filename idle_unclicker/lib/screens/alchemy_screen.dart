import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/alchemy.dart';
import '../services/alchemy_service.dart';

class AlchemyScreen extends StatelessWidget {
  const AlchemyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final state = game.alchemyState;
        final service = game.alchemyService;

        if (state == null || service == null) {
          return const Center(
            child: Text(
              'Alchemy not available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Update brewing progress
        service.updateBrewingProgress();

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
                    'ALCHEMY LAB',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildAutoToggle(context, game, state),
                ],
              ),
              const SizedBox(height: 12),

              // Brewing Slots
              _buildBrewingSlots(service, state),
              const SizedBox(height: 16),

              // Active Effects
              _buildActiveEffects(state),
              const SizedBox(height: 16),

              // Potion Inventory
              _buildPotionInventory(state),
              const SizedBox(height: 16),

              // Available Recipes
              _buildRecipesSection(service, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAutoToggle(
    BuildContext context,
    GameProvider game,
    AlchemyState state,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Auto:',
          style: TextStyle(
            color: state.autoBrewEnabled ? Colors.purple : Colors.grey,
            fontSize: 12,
          ),
        ),
        Switch(
          value: state.autoBrewEnabled,
          onChanged: (value) => game.toggleAutoBrew(),
          activeColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildBrewingSlots(AlchemyService service, AlchemyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BREWING SLOTS',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: state.brewingSlots
              .map(
                (slot) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildSlotCard(slot),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSlotCard(BrewingSlot slot) {
    Color statusColor;
    String statusText;
    IconData icon;

    if (slot.isAvailable) {
      statusColor = Colors.grey;
      statusText = 'Empty';
      icon = Icons.add;
    } else if (slot.isComplete) {
      statusColor = Colors.green;
      statusText = 'Ready!';
      icon = Icons.check_circle;
    } else {
      statusColor = Colors.orange;
      statusText =
          '${slot.remainingSeconds ~/ 60}m ${slot.remainingSeconds % 60}s';
      icon = Icons.hourglass_top;
    }

    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: statusColor),
          const SizedBox(height: 4),
          if (slot.recipe != null) ...[
            Text(
              slot.recipe!.potionType.displayName.split(' ').last,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
          ],
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 10)),
          if (slot.isBrewing) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: slot.progressPercent,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveEffects(AlchemyState state) {
    final effects = state.activeEffects
        .where((e) => e.isActive && !e.hasExpired)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVE EFFECTS',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (effects.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'No active effects. Use buff potions to gain temporary bonuses.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          )
        else
          ...effects.map((effect) => _buildEffectCard(effect)),
      ],
    );
  }

  Widget _buildEffectCard(PotionEffect effect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(int.parse(effect.type.color.replaceFirst('#', '0xFF'))),
        ),
        borderRadius: BorderRadius.circular(6),
        color: Color(
          int.parse(effect.type.color.replaceFirst('#', '0xFF')),
        ).withOpacity(0.1),
      ),
      child: Row(
        children: [
          Text(effect.type.icon),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effect.type.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '+${(effect.magnitude * 100).toStringAsFixed(0)}% ${effect.type.description.split(' ').last}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            effect.remainingTimeDisplay,
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotionInventory(AlchemyState state) {
    final healingCount = state.healingPotionCount;
    final manaCount = state.manaPotionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POTION INVENTORY',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPotionCountCard(
                '🧪 Healing',
                healingCount,
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPotionCountCard('💙 Mana', manaCount, Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Buff potions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.inventory.entries
              .where((e) => e.key.isBuff || e.key.isSpecial)
              .map((e) => _buildBuffPotionChip(e.key, e.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPotionCountCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'x$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuffPotionChip(PotionType type, int count) {
    final color = Color(int.parse(type.color.replaceFirst('#', '0xFF')));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type.icon),
          const SizedBox(width: 4),
          Text(
            type.displayName.split(' ').last,
            style: TextStyle(color: color, fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            'x$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesSection(AlchemyService service, AlchemyState state) {
    final recipes = state.availableRecipes;

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
        ...recipes
            .where((r) => r.potionType.isHealing)
            .take(3)
            .map((recipe) => _buildRecipeCard(recipe, service)),
        ...recipes
            .where((r) => r.potionType.isBuff)
            .take(3)
            .map((recipe) => _buildRecipeCard(recipe, service)),
        if (state.alchemyLevel >= 5)
          ...recipes
              .where((r) => r.potionType.isSpecial)
              .take(1)
              .map((recipe) => _buildRecipeCard(recipe, service)),
      ],
    );
  }

  Widget _buildRecipeCard(AlchemyRecipe recipe, AlchemyService service) {
    final canBrew = service.canBrew(recipe);
    final color = Color(int.parse(recipe.color.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: canBrew ? color : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(6),
        color: canBrew ? color.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          Text(recipe.icon),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.displayName,
                  style: TextStyle(
                    color: canBrew ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${recipe.brewTimeDisplay} • ${recipe.goldCost}g',
                  style: TextStyle(
                    color: canBrew ? Colors.grey : Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (canBrew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ready',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Icon(Icons.lock, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}
