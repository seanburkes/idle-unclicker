import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/character.dart';
import '../../models/skill_tree.dart';
import '../../utils/rpg_system.dart';
import '../core/character_provider.dart';
import 'enemy_provider.dart';

/// Manages combat state and turn resolution
///
/// This provider handles:
/// - Combat state (in/out of combat)
/// - Turn resolution
/// - Player attack/defense calculations
/// - Victory/defeat handling
/// - Combat rewards
class CombatProvider extends ChangeNotifier {
  final CharacterProvider _characterProvider;
  final EnemyProvider _enemyProvider;
  final SkillTree? _skillTree;

  bool _inCombat = false;
  bool _isAutoAdventure = false;

  // Boss fight state
  bool _isBossFight = false;
  int _bossCombatTurns = 0;

  CombatProvider({
    required CharacterProvider characterProvider,
    required EnemyProvider enemyProvider,
    SkillTree? skillTree,
  }) : _characterProvider = characterProvider,
       _enemyProvider = enemyProvider,
       _skillTree = skillTree;

  // ============ Getters ============

  bool get inCombat => _inCombat;
  bool get isBossFight => _isBossFight;
  int get bossCombatTurns => _bossCombatTurns;
  bool get isAutoAdventure => _isAutoAdventure;

  bool get canAttack => _inCombat && _characterProvider.isAlive;
  bool get isPlayerAlive => _characterProvider.isAlive;

  // ============ Combat Control ============

  void startCombat() {
    _inCombat = true;
    _isResting = false;
    notifyListeners();
  }

  void endCombat() {
    _inCombat = false;
    _isBossFight = false;
    _bossCombatTurns = 0;
    notifyListeners();
  }

  void setAutoAdventure(bool value) {
    _isAutoAdventure = value;
    notifyListeners();
  }

  void toggleAutoAdventure() {
    _isAutoAdventure = !_isAutoAdventure;
    notifyListeners();
  }

  // ============ Turn Resolution ============

  /// Resolve a full combat turn
  /// Returns true if combat ended (victory or defeat)
  bool resolveTurn() {
    if (!_inCombat) return false;
    if (!_characterProvider.isAlive) {
      _handleDefeat();
      return true;
    }

    // Player attacks
    final playerDamage = _calculatePlayerAttack();
    if (playerDamage > 0) {
      _enemyProvider.dealDamage(playerDamage);
      _characterProvider.gainSkillXP('weapon', 1);

      // Check for victory
      if (_enemyProvider.isEnemyDefeated()) {
        _handleVictory();
        return true;
      }
    }

    // Enemy attacks
    final enemyDamage = _calculateEnemyAttack();
    if (enemyDamage > 0) {
      _characterProvider.takeDamage(enemyDamage);
      _characterProvider.gainSkillXP('armor', 1);
      _characterProvider.gainSkillXP('dodging', 1);

      // Check for defeat
      if (!_characterProvider.isAlive) {
        _handleDefeat();
        return true;
      }
    } else {
      // Enemy missed - bonus dodge XP
      _characterProvider.gainSkillXP('dodging', 2);
    }

    // General fighting XP
    _characterProvider.gainSkillXP('fighting', 1);

    notifyListeners();
    return false;
  }

  int _calculatePlayerAttack() {
    final attack = _characterProvider.calculateAttackPower();
    final accuracy = _characterProvider.calculateAccuracy();

    return _enemyProvider.calculateDamageToEnemy(attack, accuracy);
  }

  int _calculateEnemyAttack() {
    final evasion = _characterProvider.calculateEvasion();
    final armor = _characterProvider.calculateDefense();

    return _enemyProvider.calculateDamageToPlayer(evasion, armor);
  }

  // ============ Victory / Defeat ============

  void _handleVictory() {
    // Calculate rewards
    final depth = _characterProvider.dungeonDepth;
    final baseXP = (10 + _randomDice(10) + (depth * 2)).toDouble();
    final baseGold = _randomDice(20) + depth;

    // Apply multipliers
    final xpGain = baseXP;
    final goldGain = baseGold;

    // Award rewards
    _characterProvider.gainExperience(xpGain);
    _characterProvider.addGold(goldGain);

    // Skill tree tracking
    _skillTree?.recordKill();
    _skillTree?.recordGold(goldGain);

    // Bestiary tracking
    _enemyProvider.recordKill(
      _enemyProvider.currentEnemyType,
      _enemyProvider.currentEnemy,
    );

    // Potion drop chance
    if (_randomPercent(30)) {
      _characterProvider.addHealthPotions(1);
    }

    // Equipment upgrade chance
    if (_randomPercent(15)) {
      _upgradeEquipment();
    }

    _inCombat = false;
    _enemyProvider.endCombat();
    notifyListeners();
  }

  void _handleDefeat() {
    _inCombat = false;
    _isBossFight = false;
    _enemyProvider.endCombat();
    notifyListeners();
  }

  void _upgradeEquipment() {
    if (_randomPercent(50)) {
      _characterProvider.upgradeWeapon();
    } else {
      _characterProvider.upgradeArmor();
    }
  }

  // ============ Boss Combat ============

  void startBossFight(
    String bossName,
    int bossHealth,
    int bossAttack,
    int bossEvasion,
    int bossArmor,
  ) {
    _isBossFight = true;
    _bossCombatTurns = 0;
    _inCombat = true;

    _enemyProvider.startCombat(
      bossName,
      'Boss',
      bossHealth,
      bossAttack,
      bossEvasion,
      bossArmor,
    );

    notifyListeners();
  }

  bool resolveBossTurn() {
    if (!_isBossFight) return resolveTurn();

    _bossCombatTurns++;

    // Process boss mechanics here if needed

    return resolveTurn();
  }

  void endBossFight(bool victory) {
    if (victory) {
      _handleVictory();
    } else {
      _handleDefeat();
    }
    _isBossFight = false;
    _bossCombatTurns = 0;
  }

  // ============ Auto Combat ============

  void processAutoCombatTick() {
    if (!_isAutoAdventure) return;
    if (!_inCombat && _characterProvider.isAlive) {
      // Auto adventure will trigger new combat via GameTimerProvider
      return;
    }

    if (_inCombat) {
      // Use potion if needed
      if (_characterProvider.isAtCriticalHealth &&
          _characterProvider.healthPotions > 0) {
        _characterProvider.useHealthPotion();
      }

      // Resolve turn
      resolveTurn();
    }
  }

  // ============ Utility ============

  int _randomDice(int sides) {
    return Random().nextInt(sides) + 1;
  }

  bool _randomPercent(int percent) {
    return Random().nextInt(100) < percent;
  }

  // Rest state (for UI)
  bool _isResting = false;
  bool get isResting => _isResting;

  void setResting(bool value) {
    _isResting = value;
    notifyListeners();
  }
}
