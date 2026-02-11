import 'dart:math';
import '../models/boss_rush.dart';
import '../models/character.dart';
import '../utils/rpg_system.dart';

/// Service for managing Boss Rush and Rift content
class BossRiftService {
  final Random _random = Random();
  BossRushState _state;

  BossRiftService(this._state);

  // ============================================================================
  // Boss Generation
  // ============================================================================

  /// Generate a boss for a specific floor (every 5th floor)
  /// Returns null if not a boss floor or boss already defeated
  Boss? generateBoss(int floor) {
    return _state.generateBossForFloor(floor, _random);
  }

  /// Check if a floor should have a boss
  bool isBossFloor(int floor) {
    return floor % 5 == 0;
  }

  /// Get the current active boss
  Boss? get currentBoss => _state.currentBoss;

  /// Get all defeated bosses
  List<Boss> get defeatedBosses => _state.defeatedBosses;

  // ============================================================================
  // Rift Generation
  // ============================================================================

  /// Generate a new daily rift if needed
  Rift? generateDailyRift() {
    if (!_state.shouldGenerateNewRift) {
      return _state.dailyRift;
    }

    final rift = Rift.generateDaily(_random);
    _state.dailyRift = rift;
    _state.lastRiftDate = DateTime.now();
    return rift;
  }

  /// Get the current daily rift
  Rift? get dailyRift => _state.dailyRift;

  /// Check if daily rift is available and not completed
  bool get isRiftAvailable {
    return _state.dailyRift != null && !_state.dailyRift!.completed;
  }

  /// Get rift history
  List<Rift> get riftHistory => _state.riftHistory;

  // ============================================================================
  // Power Estimation
  // ============================================================================

  /// Calculate character power level based on stats
  /// Returns a composite score for comparison
  double calculatePowerLevel(Character character) {
    // Calculate DPS (damage per second)
    final weaponType =
        RPGSystem.weaponTypes[character.weaponType] ??
        RPGSystem.weaponTypes['balanced']!;
    final baseDamage = weaponType.baseDamage + (character.strength ~/ 4);
    final playerDamage = RPGSystem.calculateWeaponDamage(
      baseDamage,
      character.strength,
      weaponType.strRequirement,
    );

    // Estimate attack speed (simplified)
    final attackSpeed = 1.0 + (character.dexterity / 20);
    final dps = playerDamage * attackSpeed;

    // Calculate EHP (effective HP)
    final armorType =
        RPGSystem.armorTypes[character.armorType] ??
        RPGSystem.armorTypes['leather']!;
    final playerAC = armorType.armorClass + (character.armorSkill ~/ 3);
    final playerEvasion = RPGSystem.calculateEvasion(
      character.dexterity,
      character.dodgingSkill,
      armorType.encumbrance,
    );

    // EHP = HP * (1 + armor/100) * (1 + evasion/100)
    final armorMitigation = 1 + (playerAC / 100);
    final evasionMitigation = 1 + (playerEvasion / 100);
    final ehp = character.maxHealth * armorMitigation * evasionMitigation;

    // Composite power score
    return dps * ehp;
  }

  /// Calculate boss power level
  double calculateBossPower(Boss boss) {
    // Boss DPS
    final bossDPS = boss.damage * 1.0; // Bosses attack once per turn

    // Boss EHP (considering armor)
    final bossMitigation = 1 + (boss.armor / 100);
    final bossEHP = boss.maxHealth * bossMitigation;

    // Apply mechanic multipliers
    double mechanicMultiplier = 1.0;
    switch (boss.mechanic) {
      case BossMechanic.overgrowth:
        // Healing effectively increases EHP
        mechanicMultiplier = 1.3;
        break;
      case BossMechanic.timeLimit:
        // Enrage makes boss dangerous
        mechanicMultiplier = 1.4;
        break;
      case BossMechanic.minionSwarm:
        // Adds increase total damage
        mechanicMultiplier = 1.2;
        break;
      case BossMechanic.shieldPhases:
        // Invulnerability increases effective HP
        mechanicMultiplier = 1.25;
        break;
      case BossMechanic.reflective:
        // Reflective damage is dangerous
        mechanicMultiplier = 1.15;
        break;
      case BossMechanic.elementalShift:
        // Resistance rotation is moderate difficulty
        mechanicMultiplier = 1.1;
        break;
    }

    return bossDPS * bossEHP * mechanicMultiplier;
  }

  /// Check if character can handle a boss
  /// Returns confidence score 0-100%
  double canAttemptBoss(Character character, Boss boss) {
    final playerPower = calculatePowerLevel(character);
    final bossPower = calculateBossPower(boss);

    if (bossPower == 0) return 100.0;

    // Power ratio
    final ratio = playerPower / bossPower;

    // Convert to confidence percentage
    // ratio >= 1.5 = 100% confidence
    // ratio = 0.7 = 70% confidence (minimum threshold)
    // ratio < 0.5 = 0% confidence

    if (ratio >= 1.5) return 100.0;
    if (ratio >= 1.0) return 70.0 + (ratio - 1.0) * 60.0;
    if (ratio >= 0.5) return ratio * 70.0;
    return 0.0;
  }

  /// Check if character should attempt a rift
  /// Similar to boss but considers modifier
  double shouldAttemptRift(Character character, Rift rift) {
    // Base difficulty estimation - depth determines difficulty
    final playerPower = calculatePowerLevel(character);
    final playerEstimatedDepth = playerPower / 10.0;

    double baseConfidence = 100.0;
    if (playerEstimatedDepth < rift.depth) {
      baseConfidence = (playerEstimatedDepth / rift.depth) * 100;
    }

    // Apply modifier adjustments
    switch (rift.modifier) {
      case RiftModifier.ironman:
        // High risk - reduce confidence significantly
        baseConfidence *= 0.7;
        break;
      case RiftModifier.glassCannon:
        // Risky for low health characters
        if (character.maxHealth < 50) {
          baseConfidence *= 0.8;
        }
        break;
      case RiftModifier.noPotions:
        // Risky if character relies on potions
        if (character.healthPotions < 3) {
          baseConfidence *= 0.85;
        }
        break;
      case RiftModifier.berserker:
        // More dangerous
        baseConfidence *= 0.9;
        break;
      default:
        break;
    }

    return baseConfidence.clamp(0.0, 100.0);
  }

  // ============================================================================
  // Echo Leaderboard
  // ============================================================================

  /// Generate fake echo entries for leaderboard
  List<EchoEntry> generateEchoEntries(int targetFloor, int count) {
    final entries = <EchoEntry>[];
    for (int i = 0; i < count; i++) {
      entries.add(EchoEntry.generateFake(targetFloor, _random));
    }
    entries.sort((a, b) => b.floorReached.compareTo(a.floorReached));
    return entries;
  }

  /// Update rift leaderboard with player result
  void updateRiftLeaderboard(Rift rift, Character character, int floorReached) {
    final entry = EchoEntry.fromCharacter(character, floorReached);
    rift.updateLeaderboard(entry);

    if (floorReached >= rift.depth) {
      _state.recordRiftCompleted(rift);
    }
  }

  // ============================================================================
  // Essence Rewards
  // ============================================================================

  /// Award essences for defeating a boss
  List<EssenceType> awardEssences(Boss boss) {
    final essences = boss.defeat();
    _state.addEssences(essences);
    _state.recordBossDefeated(boss);
    return essences;
  }

  /// Get essence inventory
  Map<EssenceType, int> get essenceInventory => _state.essenceInventory;

  /// Get total essence count
  int get totalEssences => _state.totalEssences;

  /// Use essences for crafting
  bool useEssences(EssenceType type, int amount) {
    return _state.useEssences(type, amount);
  }

  // ============================================================================
  // Automation Integration
  // ============================================================================

  /// Execute boss fight with automation decision
  /// Returns action log
  List<String> executeBossFight(
    Character character,
    Boss boss, {
    required Function(List<String>) onCombatTick,
    required Function(List<EssenceType>) onVictory,
    required Function() onDefeat,
  }) {
    final actions = <String>[];

    final confidence = canAttemptBoss(character, boss);

    if (confidence < 70.0) {
      actions.add(
        'AUTO: Boss ${boss.name} detected but confidence too low (${confidence.toStringAsFixed(0)}%)',
      );
      actions.add('AUTO: Fleeing to fight another day...');
      return actions;
    }

    actions.add(
      'AUTO: Engaging boss ${boss.name}! (Confidence: ${confidence.toStringAsFixed(0)}%)',
    );
    actions.add(
      'AUTO: Boss mechanic: ${boss.mechanic.displayName} - ${boss.mechanic.description}',
    );

    // Combat would be handled by GameProvider's combat loop
    // This just makes the decision to fight

    return actions;
  }

  /// Execute rift attempt with automation decision
  List<String> executeRiftAttempt(
    Character character,
    Rift rift, {
    required Function() onEnter,
    required Function() onSkip,
  }) {
    final actions = <String>[];

    final confidence = shouldAttemptRift(character, rift);

    // Special handling for ironman modifier - risk averse
    if (rift.modifier == RiftModifier.ironman && confidence < 85.0) {
      actions.add(
        'AUTO: Daily Rift "${rift.name}" available but Ironman is risky',
      );
      actions.add(
        'AUTO: Confidence ${confidence.toStringAsFixed(0)}% - skipping for safety',
      );
      onSkip();
      return actions;
    }

    if (confidence < 70.0) {
      actions.add(
        'AUTO: Daily Rift "${rift.name}" available but confidence too low',
      );
      actions.add('AUTO: Modifier: ${rift.modifier.displayName}');
      actions.add('AUTO: Skipping rift attempt');
      onSkip();
      return actions;
    }

    actions.add('AUTO: Entering Rift "${rift.name}"!');
    actions.add(
      'AUTO: Modifier: ${rift.modifier.displayName} - ${rift.modifier.description}',
    );
    actions.add('AUTO: Target: ${rift.depth} floors');
    onEnter();

    return actions;
  }

  // ============================================================================
  // Boss Combat Helpers
  // ============================================================================

  /// Process boss mechanic at start of turn
  void processBossMechanicStart(Boss boss) {
    boss.applyMechanicStartOfTurn();
  }

  /// Get reflected damage from boss
  int getReflectedDamage(Boss boss, int damageDealt) {
    return boss.calculateReflectedDamage(damageDealt);
  }

  /// Check if boss should spawn minions
  bool shouldSpawnMinions(Boss boss) {
    return boss.shouldSpawnMinions;
  }

  /// Check if boss is shielded (invulnerable)
  bool isBossShielded(Boss boss) {
    return boss.isShielded;
  }

  /// Check if boss is enraged
  bool isBossEnraged(Boss boss) {
    return boss.isEnraged;
  }

  /// Get spawnable minion stats for minionSwarm mechanic
  Map<String, int> generateMinionStats(Boss boss) {
    // Minions are weak versions based on boss level
    return {
      'health': (boss.maxHealth * 0.1).round(),
      'damage': (boss.damage * 0.3).round(),
      'armor': (boss.armor * 0.5).round(),
      'evasion': (boss.evasion * 0.5).round(),
    };
  }

  // ============================================================================
  // State Management
  // ============================================================================

  BossRushState get state => _state;

  void updateState(BossRushState newState) {
    _state = newState;
  }

  /// Get statistics summary
  Map<String, dynamic> getSummary() {
    return {
      'totalBossesDefeated': _state.totalBossesDefeated,
      'totalRiftsCompleted': _state.totalRiftsCompleted,
      'totalEssences': _state.totalEssences,
      'currentBossName': _state.currentBoss?.name,
      'currentBossFloor': _state.currentBoss?.floor,
      'dailyRiftName': _state.dailyRift?.name,
      'dailyRiftModifier': _state.dailyRift?.modifier.displayName,
    };
  }
}
