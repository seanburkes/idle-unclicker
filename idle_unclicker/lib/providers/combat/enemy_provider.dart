import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/bestiary.dart';
import '../../utils/procedural_generator.dart';
import '../../utils/rpg_system.dart';

/// Manages enemy encounters and bestiary progression
///
/// This provider handles:
/// - Current enemy state
/// - Enemy generation
/// - Bestiary tracking
/// - Monster knowledge progression
class EnemyProvider extends ChangeNotifier {
  final Bestiary? _bestiary;
  final Random _random = Random();

  // Current enemy state
  String _currentEnemy = '';
  String _currentEnemyType = '';
  int _enemyHealth = 0;
  int _enemyMaxHealth = 0;
  int _enemyAttack = 0;
  int _enemyEvasion = 0;
  int _enemyArmor = 0;

  bool _inCombat = false;
  int _dungeonDepth = 1;

  EnemyProvider({Bestiary? bestiary}) : _bestiary = bestiary;

  // ============ Getters ============

  bool get inCombat => _inCombat;
  String get currentEnemy => _currentEnemy;
  String get currentEnemyType => _currentEnemyType;
  int get enemyHealth => _enemyHealth;
  int get enemyMaxHealth => _enemyMaxHealth;
  int get enemyAttack => _enemyAttack;
  int get enemyEvasion => _enemyEvasion;
  int get enemyArmor => _enemyArmor;
  double get enemyHealthPercent =>
      _enemyMaxHealth > 0 ? _enemyHealth / _enemyMaxHealth : 0.0;

  Bestiary? get bestiary => _bestiary;
  Map<String, int> get monsterKills => _bestiary?.monsterKills ?? {};
  int get totalUniqueMonsters => _bestiary?.totalUniqueMonsters ?? 0;
  int get totalKills => _bestiary?.totalKills ?? 0;

  // ============ Enemy Generation ============

  void generateEnemy(
    int dungeonDepth,
    int playerLevel, {
    Map<String, dynamic>? spiralMultipliers,
  }) {
    _dungeonDepth = dungeonDepth;

    final template = RPGSystem.generateMonster(dungeonDepth, playerLevel);

    _currentEnemy = ProceduralGenerator.generateMonster(playerLevel);

    // Assign a random monster type for bestiary tracking
    final types = BestiaryData.monsterTypes.keys.toList();
    _currentEnemyType = types[_random.nextInt(types.length)];

    // Apply spiral multipliers if provided
    if (spiralMultipliers != null) {
      _enemyMaxHealth =
          (template.health * (spiralMultipliers['healthMultiplier'] ?? 1.0))
              .round();
      _enemyHealth = _enemyMaxHealth;
      _enemyAttack =
          (template.damage * (spiralMultipliers['damageMultiplier'] ?? 1.0))
              .round();
    } else {
      _enemyMaxHealth = template.health;
      _enemyHealth = template.health;
      _enemyAttack = template.damage;
    }

    _enemyEvasion = template.evasion;
    _enemyArmor = template.armor;
    _inCombat = true;

    notifyListeners();
  }

  void startCombat(
    String name,
    String type,
    int health,
    int attack,
    int evasion,
    int armor,
  ) {
    _currentEnemy = name;
    _currentEnemyType = type;
    _enemyMaxHealth = health;
    _enemyHealth = health;
    _enemyAttack = attack;
    _enemyEvasion = evasion;
    _enemyArmor = armor;
    _inCombat = true;
    notifyListeners();
  }

  // ============ Combat Actions ============

  void dealDamage(int damage) {
    if (!_inCombat) return;

    _enemyHealth = max(0, _enemyHealth - damage);
    notifyListeners();
  }

  bool isEnemyDefeated() {
    return _enemyHealth <= 0;
  }

  void endCombat() {
    _inCombat = false;
    _currentEnemy = '';
    _enemyHealth = 0;
    _enemyMaxHealth = 0;
    notifyListeners();
  }

  void flee() {
    _inCombat = false;
    _currentEnemy = '';
    notifyListeners();
  }

  // ============ Bestiary ============

  bool recordKill(String monsterType, String monsterName) {
    if (_bestiary == null) return false;

    final wasNew = _bestiary!.recordKill(monsterType, monsterName);
    if (wasNew) {
      _bestiary!.save();
    }
    return wasNew;
  }

  int getKillCount(String monsterType) {
    return _bestiary?.monsterKills[monsterType] ?? 0;
  }

  bool hasKnowledge(String monsterType) {
    return _bestiary?.unlockedEntries.contains(monsterType) ?? false;
  }

  // ============ Utility ============

  int calculateDamageToEnemy(int playerAttack, int playerAccuracy) {
    final hitChance = RPGSystem.getHitChance(playerAccuracy, _enemyEvasion);
    if (!RPGSystem.attemptHit(playerAccuracy, _enemyEvasion)) {
      return 0; // Miss
    }

    return RPGSystem.applyArmorReduction(playerAttack, _enemyArmor);
  }

  int calculateDamageToPlayer(int playerEvasion, int playerArmor) {
    final hitChance = RPGSystem.getHitChance(_enemyAttack + 10, playerEvasion);
    if (!RPGSystem.attemptHit(_enemyAttack + 10, playerEvasion)) {
      return 0; // Miss
    }

    return RPGSystem.applyArmorReduction(_enemyAttack, playerArmor);
  }
}
