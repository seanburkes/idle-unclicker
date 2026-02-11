import 'dart:math';
import '../models/infinite_spiral.dart';
import '../models/character.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';

/// SpiralService - Handles all infinite spiral logic and automation
class SpiralService {
  InfiniteSpiral _spiral;
  final Random _random = Random();

  SpiralService(this._spiral);

  InfiniteSpiral get spiral => _spiral;

  /// Initialize spiral for new game
  void initializeSpiral() {
    if (_spiral.state == SpiralState.ascending &&
        _spiral.currentLoop.loopNumber == 1) {
      // Already initialized
      return;
    }
    _spiral = InfiniteSpiral.create();
  }

  /// Check if floor 100 has been reached and trigger reset
  bool checkFloor100Trigger(GameState gameState, Character character) {
    if (character.dungeonDepth >= 100 && !_spiral.hasReachedFloor100) {
      // First time reaching floor 100
      _spiral.hasReachedFloor100 = true;
      _spiral.recordFloor100Reached(character);
      return true;
    }
    return false;
  }

  /// Execute the spiral reset (called when continuing past floor 100)
  /// This resets dungeon to floor 1 but keeps character progress
  List<String> executeSpiralReset(GameProvider gameProvider) {
    final actions = <String>[];
    final character = gameProvider.character;

    if (character == null) return actions;

    // Change state to resetting temporarily
    _spiral.state = SpiralState.resetting;

    actions.add('🌀 THE SPIRAL CONSUMES ALL 🌀');
    actions.add('Floor 100 reached! The dungeon resets...');
    actions.add('But your legend grows stronger.');

    // Save current loop to history
    _spiral.executeReset();

    // Reset dungeon depth to 1
    character.dungeonDepth = 1;

    // Keep character stats, equipment, everything
    // Just reset the dungeon progress

    actions.add('Loop ${_spiral.currentLoop.loopNumber} begun!');
    actions.add(
      'Enemies: +${((_spiral.enemyHpMultiplier - 1.0) * 100).toStringAsFixed(0)}% HP/Damage',
    );
    actions.add(
      'Rewards: +${((_spiral.goldMultiplier - 1.0) * 100).toStringAsFixed(0)}% Gold/XP',
    );

    _spiral.save();
    character.save();

    return actions;
  }

  /// Calculate enemy HP multiplier for current loop
  double calculateEnemyHpMultiplier(int loopNumber) {
    return 1.0 + (loopNumber * 0.1);
  }

  /// Calculate enemy damage multiplier for current loop
  double calculateEnemyDamageMultiplier(int loopNumber) {
    return 1.0 + (loopNumber * 0.1);
  }

  /// Calculate gold multiplier for current loop
  double calculateRewardMultipliers(int loopNumber) {
    return 1.0 + (loopNumber * 0.05);
  }

  /// Check if automation should auto-advance to next loop
  bool shouldAutoAdvance() {
    if (!_spiral.autoAdvanceEnabled) return false;
    if (_spiral.state != SpiralState.spiraling) return false;

    // Auto-advance when:
    // 1. Player has reached floor 100 again
    // 2. Player has reasonable health
    // 3. Player has potions

    // This is called externally when floor 100 is reached
    return true;
  }

  /// Update tale progress based on game state changes
  List<String> checkTaleProgress(GameProvider gameProvider) {
    final actions = <String>[];
    final character = gameProvider.character;
    if (character == null) return actions;

    // Check all tale completions
    final completed = _spiral.checkAllTaleCompletions(character);

    for (final taleType in completed) {
      actions.add('★ TALE COMPLETED: ${taleType.displayName} ★');
      actions.add('  ${taleType.bonus.description}');
      actions.add('  ${taleType.bonus.formattedMagnitude} permanent bonus!');
    }

    // Check if became Legend
    if (_spiral.tales.isLegend && _spiral.tales.becameLegendAt != null) {
      // Check if this is a new Legend status (within last minute)
      final timeSinceLegend = DateTime.now().difference(
        _spiral.tales.becameLegendAt!,
      );
      if (timeSinceLegend.inMinutes < 1) {
        actions.add('');
        actions.add('╔════════════════════════════════════╗');
        actions.add('║    ★ YOU HAVE BECOME A LEGEND ★   ║');
        actions.add('╚════════════════════════════════════╝');
        actions.add('');
        actions.add('All 20 tales complete! You are eternal.');
        actions.add(
          'Legend Mode unlocked: Can equip 2 legendaries of same type!',
        );
      }
    }

    return actions;
  }

  /// Award a tale directly (for special cases)
  bool awardTale(TaleType taleType, Character character) {
    final tale = _spiral.tales.allTales.firstWhere((t) => t.type == taleType);
    if (tale.isCompleted) return false;

    tale.complete(character);
    _spiral.tales.totalTalesCompleted++;

    if (_spiral.tales.totalTalesCompleted >= 20 &&
        _spiral.tales.becameLegendAt == null) {
      _spiral.tales.becameLegendAt = DateTime.now();
    }

    return true;
  }

  /// Get all active tale bonuses
  Map<String, double> getActiveTaleBonuses() {
    return _spiral.getActiveBonuses();
  }

  /// Calculate total power multiplier from all tale effects
  double calculateTotalPowerMultiplier() {
    return _spiral.tales.totalBonusMultiplier;
  }

  /// Execute automation for spiral logic
  /// Called periodically by GameProvider
  List<String> executeAutomation(GameProvider gameProvider) {
    final actions = <String>[];
    final character = gameProvider.character;
    if (character == null) return actions;

    // Check for floor 100 trigger
    if (character.dungeonDepth >= 100) {
      if (_spiral.autoAdvanceEnabled) {
        final resetActions = executeSpiralReset(gameProvider);
        actions.addAll(resetActions);
      } else if (!_spiral.hasReachedFloor100) {
        // First time reaching floor 100
        checkFloor100Trigger(gameProvider.gameState!, character);
        actions.add('🌀 Floor 100 reached! The Spiral awaits...');
        actions.add('Enable auto-advance to continue into the infinite loop.');
      }
    }

    // Check tale progress
    final taleActions = checkTaleProgress(gameProvider);
    if (taleActions.isNotEmpty) {
      actions.addAll(taleActions);
    }

    // Add loop time tracking
    _spiral.addLoopTime(300); // 5 minutes per automation tick

    _spiral.save();
    return actions;
  }

  /// Toggle auto-advance setting
  void toggleAutoAdvance() {
    _spiral.autoAdvanceEnabled = !_spiral.autoAdvanceEnabled;
    _spiral.save();
  }

  /// Get current loop display info
  Map<String, dynamic> getCurrentLoopInfo() {
    return {
      'loopNumber': _spiral.currentLoop.loopNumber,
      'state': _spiral.state.displayName,
      'stateIcon': _spiral.state.icon,
      'highestFloor': _spiral.currentLoop.highestFloorReached,
      'enemyHpMultiplier': _spiral.enemyHpMultiplier,
      'enemyDamageMultiplier': _spiral.enemyDamageMultiplier,
      'goldMultiplier': _spiral.goldMultiplier,
      'xpMultiplier': _spiral.xpMultiplier,
      'timeInLoop': _spiral.currentLoop.formattedDuration,
      'autoAdvance': _spiral.autoAdvanceEnabled,
    };
  }

  /// Get spiral statistics
  Map<String, dynamic> getSpiralStatistics() {
    return {
      'totalLoops': _spiral.totalLoopsCompleted,
      'currentLoop': _spiral.currentLoop.loopNumber,
      'totalTime': _spiral.formattedTotalTime,
      'talesCompleted': _spiral.tales.totalTalesCompleted,
      'talesTotal': 20,
      'isLegend': _spiral.tales.isLegend,
      'legendProgress': _spiral.tales.legendProgress,
      'firstSpiralDate': _spiral.firstSpiralDate,
    };
  }

  /// Get loop history
  List<Map<String, dynamic>> getLoopHistory() {
    return _spiral.loopHistory
        .map(
          (loop) => {
            'loopNumber': loop.loopNumber,
            'highestFloor': loop.highestFloorReached,
            'duration': loop.formattedDuration,
            'enemyMult': loop.enemyHpMultiplier,
          },
        )
        .toList();
  }

  /// Get tales collection info for UI
  Map<String, dynamic> getTalesInfo() {
    final completed = _spiral.tales.completedTales;
    final inProgress = _spiral.tales.inProgressTales;

    return {
      'completed': completed
          .map(
            (t) => {
              'type': t.type,
              'title': t.title,
              'icon': t.type.icon,
              'earnedAt': t.earnedAt,
              'characterName': t.characterName,
              'bonus': t.bonus?.description,
            },
          )
          .toList(),
      'inProgress': inProgress
          .map(
            (t) => {
              'type': t.type,
              'title': t.title,
              'icon': t.type.icon,
              'progress': _spiral.tales.getProgress(t.type),
              'target': t.type.targetAmount,
              'percent':
                  _spiral.tales.getProgress(t.type) / t.type.targetAmount,
            },
          )
          .toList(),
      'locked': _spiral.tales.allTales
          .where(
            (t) => !t.isCompleted && _spiral.tales.getProgress(t.type) == 0,
          )
          .map(
            (t) => {
              'type': t.type,
              'title': t.title,
              'icon': t.type.icon,
              'description': t.description,
            },
          )
          .toList(),
      'totalBonus': _spiral.tales.totalBonusMultiplier,
      'isLegend': _spiral.tales.isLegend,
    };
  }

  // Progress tracking helper methods - called by GameProvider

  void onDragonKilled() => _spiral.recordDragonKill();
  void onBossDefeated() => _spiral.recordBossDefeated();
  void onGoldFound(int amount) => _spiral.recordGoldFound(amount);
  void onCriticalSurvival() => _spiral.recordCriticalSurvival();
  void onLegendaryCollected() => _spiral.recordLegendaryCollected();
  void onItemEnchanted() => _spiral.recordItemEnchanted();
  void onSetCompleted() => _spiral.recordSetCompleted();
  void onCompanionJoined() => _spiral.recordCompanionJoined();
  void onTransmute() => _spiral.recordTransmute();
  void onPotionBrewed() => _spiral.recordPotionBrewed();
  void onAscension() => _spiral.recordAscension();
  void onAttackDodged() => _spiral.recordAttackDodged();
  void onDeath() => _spiral.recordDeath();
  void onLegendaryAwakened() => _spiral.recordLegendaryAwakened();
  void onReforge() => _spiral.recordReforge();
  void onItemCollected() => _spiral.recordItemCollected();
  void onKill() => _spiral.recordKill();

  /// Record floor progression
  void onFloorReached(int floor) {
    _spiral.recordFloor(floor);
  }

  /// Apply spiral multipliers to monster stats
  Map<String, int> applySpiralMultipliers(int baseHealth, int baseDamage) {
    final hpMult = _spiral.getCombinedMultiplier('enemyHp');
    final dmgMult = _spiral.getCombinedMultiplier('enemyDamage');

    return {
      'health': (baseHealth * hpMult).round(),
      'damage': (baseDamage * dmgMult).round(),
    };
  }

  /// Apply spiral multipliers to rewards
  Map<String, double> applyRewardMultipliers(double baseXp, double baseGold) {
    final xpMult = _spiral.getCombinedMultiplier('xp');
    final goldMult = _spiral.getCombinedMultiplier('gold');

    return {'xp': baseXp * xpMult, 'gold': baseGold * goldMult};
  }

  /// Get automation decision context for PlayerAutomaton
  Map<String, dynamic> getAutomatonContext() {
    return {
      'isInSpiral': _spiral.isInSpiral,
      'currentLoop': _spiral.currentLoop.loopNumber,
      'enemyMultiplier': _spiral.enemyHpMultiplier,
      'taleBonuses': getActiveTaleBonuses(),
      'incompleteTales': _spiral.tales.allTales
          .where((t) => !t.isCompleted)
          .map((t) => t.type)
          .toList(),
      'isLegend': _spiral.tales.isLegend,
    };
  }

  /// Check if player can equip dual legendaries (Legend Mode)
  bool get canEquipDualLegendary => _spiral.tales.isLegend;

  /// Save spiral state
  Future<void> save() async {
    await _spiral.save();
  }
}
