import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../models/character.dart';
import '../../models/game_state.dart';
import '../../utils/procedural_generator.dart';
import '../../utils/rpg_system.dart';

/// Manages character state, progression, and persistence
///
/// This provider handles:
/// - Character stats and vitals
/// - Leveling and experience
/// - Skill progression
/// - Character creation and respawning
/// - Equipment (weapon/armor types)
class CharacterProvider extends ChangeNotifier {
  final Box<Character> _characterBox;
  final GameState? _gameState;

  Character? _character;
  final Random _random = Random();

  CharacterProvider(this._characterBox, {GameState? gameState})
    : _gameState = gameState;

  // ============ Getters ============

  Character? get character => _character;
  bool get hasCharacter => _character != null;
  bool get isAlive => _character?.isAlive ?? false;

  // Stats
  int get level => _character?.level ?? 1;
  int get currentHealth => _character?.currentHealth ?? 0;
  int get maxHealth => _character?.maxHealth ?? 0;
  int get currentMana => _character?.currentMana ?? 0;
  int get maxMana => _character?.maxMana ?? 0;
  int get unallocatedPoints => _character?.unallocatedPoints ?? 0;

  // Attributes
  int get strength => _character?.strength ?? 10;
  int get dexterity => _character?.dexterity ?? 10;
  int get constitution => _character?.constitution ?? 10;
  int get intelligence => _character?.intelligence ?? 10;
  int get wisdom => _character?.wisdom ?? 10;
  int get charisma => _character?.charisma ?? 10;

  // Skills
  int get weaponSkill => _character?.weaponSkill ?? 0;
  int get fightingSkill => _character?.fightingSkill ?? 0;
  int get armorSkill => _character?.armorSkill ?? 0;
  int get dodgingSkill => _character?.dodgingSkill ?? 0;

  // Resources
  int get gold => _character?.gold ?? 0;
  int get healthPotions => _character?.healthPotions ?? 0;
  int get dungeonDepth => _character?.dungeonDepth ?? 1;
  int get totalDeaths => _character?.totalDeaths ?? 0;

  // Equipment
  String get weaponType => _character?.weaponType ?? 'balanced';
  String get armorType => _character?.armorType ?? 'leather';

  // Derived
  bool get isAtCriticalHealth => _character?.isAtCriticalHealth ?? false;
  double get experienceProgress {
    if (_character == null) return 0.0;
    return _character!.experience / _character!.experienceToNextLevel;
  }

  String get characterName => _character?.name ?? 'Hero';
  String get race => _character?.race ?? 'Human';
  String get characterClass => _character?.characterClass ?? 'Adventurer';
  double get experience => _character?.experience ?? 0.0;
  double get expToNext => _character?.experienceToNextLevel ?? 100.0;

  // ============ Loading & Creation ============

  Future<void> loadCharacter() async {
    _character = _characterBox.get('main');

    if (_character == null) {
      await _createNewCharacterWithBonuses();
    }

    notifyListeners();
  }

  Future<void> _createNewCharacterWithBonuses() async {
    final bonuses =
        _gameState?.getStartingBonuses() ??
        {
          'hpMultiplier': 1.0,
          'bonusPotions': 0,
          'xpMultiplier': 1.0,
          'startingDepth': 1,
        };

    final race = ProceduralGenerator.generateRace();
    final characterClass = ProceduralGenerator.generateClass();

    _character = Character.create('Hero', race, characterClass);

    // Apply meta-bonuses
    final hpMult = bonuses['hpMultiplier'] as double;
    _character!.maxHealth = (_character!.maxHealth * hpMult).round();
    _character!.currentHealth = _character!.maxHealth;

    _character!.healthPotions += bonuses['bonusPotions'] as int;
    _character!.dungeonDepth = bonuses['startingDepth'] as int;

    await _characterBox.put('main', _character!);
  }

  Future<void> createCustomCharacter({
    required String name,
    required String race,
    required String characterClass,
    required Map<String, int> stats,
  }) async {
    // Create base character
    _character = Character.create(name, race, characterClass);

    // Apply rolled stats
    if (stats.containsKey('STR')) {
      _character!.strength = stats['STR']!;
    }
    if (stats.containsKey('DEX')) {
      _character!.dexterity = stats['DEX']!;
    }
    if (stats.containsKey('CON')) {
      _character!.constitution = stats['CON']!;
      final conBonus = (_character!.constitution - 10) ~/ 2;
      _character!.maxHealth = (8 + conBonus).clamp(1, 999);
      _character!.currentHealth = _character!.maxHealth;
    }
    if (stats.containsKey('INT')) {
      _character!.intelligence = stats['INT']!;
      _updateMaxMana();
    }
    if (stats.containsKey('WIS')) {
      _character!.wisdom = stats['WIS']!;
      _updateMaxMana();
    }
    if (stats.containsKey('CHA')) {
      _character!.charisma = stats['CHA']!;
    }

    // Apply meta-bonuses
    await _applyMetaBonuses();

    await _characterBox.put('main', _character!);
    notifyListeners();
  }

  void _updateMaxMana() {
    if (_character != null) {
      _character!.maxMana = (_character!.intelligence + _character!.wisdom)
          .clamp(0, 999);
      _character!.currentMana = _character!.maxMana;
    }
  }

  Future<void> _applyMetaBonuses() async {
    final bonuses =
        _gameState?.getStartingBonuses() ??
        {
          'hpMultiplier': 1.0,
          'bonusPotions': 0,
          'xpMultiplier': 1.0,
          'startingDepth': 1,
        };

    final hpMult = bonuses['hpMultiplier'] as double;
    _character!.maxHealth = (_character!.maxHealth * hpMult).round();
    _character!.currentHealth = _character!.maxHealth;

    _character!.healthPotions += bonuses['bonusPotions'] as int;
    _character!.dungeonDepth = bonuses['startingDepth'] as int;
  }

  // ============ Combat Actions ============

  void takeDamage(int damage) {
    if (_character == null) return;

    _character!.currentHealth = max(0, _character!.currentHealth - damage);
    if (_character!.currentHealth == 0) {
      _character!.isAlive = false;
      _character!.totalDeaths++;
    }

    _save();
    notifyListeners();
  }

  void heal(int amount) {
    if (_character == null) return;

    _character!.currentHealth = min(
      _character!.maxHealth,
      _character!.currentHealth + amount,
    );

    _save();
    notifyListeners();
  }

  bool useHealthPotion() {
    if (_character == null) return false;
    if (_character!.healthPotions <= 0) return false;
    if (_character!.currentHealth >= _character!.maxHealth) return false;

    _character!.healthPotions--;
    heal(_character!.maxHealth ~/ 2);
    return true;
  }

  void restoreMana(int amount) {
    if (_character == null) return;

    _character!.currentMana = min(
      _character!.maxMana,
      _character!.currentMana + amount,
    );

    _save();
    notifyListeners();
  }

  void fullyRestore() {
    if (_character == null) return;

    _character!.currentHealth = _character!.maxHealth;
    _character!.currentMana = _character!.maxMana;

    _save();
    notifyListeners();
  }

  // ============ Progression ============

  void gainExperience(double amount) {
    if (_character == null) return;

    // Apply XP multiplier from game state
    final multiplier = _gameState?.effectiveMultiplier ?? 1.0;
    final adjustedAmount = amount * multiplier;

    _character!.gainExperience(adjustedAmount);

    _save();
    notifyListeners();
  }

  void gainSkillXP(String skill, int amount) {
    if (_character == null) return;

    _character!.gainSkillXP(skill, amount);

    _save();
    notifyListeners();
  }

  void levelUp() {
    if (_character == null) return;
    if (_character!.unallocatedPoints == 0) return;

    _character!.levelUp();

    _save();
    notifyListeners();
  }

  void allocateStat(String stat, int points) {
    if (_character == null) return;
    if (_character!.unallocatedPoints < points) return;

    switch (stat.toLowerCase()) {
      case 'strength':
        _character!.strength += points;
        break;
      case 'dexterity':
        _character!.dexterity += points;
        break;
      case 'intelligence':
        _character!.intelligence += points;
        break;
      case 'constitution':
        _character!.constitution += points;
        _character!.maxHealth += points * 5;
        _character!.currentHealth += points * 5;
        break;
    }

    _character!.unallocatedPoints -= points;

    _save();
    notifyListeners();
  }

  // ============ Economy ============

  void addGold(int amount) {
    if (_character == null || amount <= 0) return;

    _character!.gold += amount;

    _save();
    notifyListeners();
  }

  bool spendGold(int amount) {
    if (_character == null) return false;
    if (_character!.gold < amount) return false;

    _character!.gold -= amount;

    _save();
    notifyListeners();
    return true;
  }

  void addHealthPotions(int amount) {
    if (_character == null || amount <= 0) return;

    _character!.healthPotions += amount;

    _save();
    notifyListeners();
  }

  // ============ Dungeon ============

  void setDungeonDepth(int depth) {
    if (_character == null) return;

    _character!.dungeonDepth = depth;

    _save();
    notifyListeners();
  }

  void descendDeeper() {
    if (_character == null) return;

    _character!.dungeonDepth++;

    _save();
    notifyListeners();
  }

  void resetToSurface() {
    if (_character == null) return;

    _character!.dungeonDepth = 1;
    _character!.currentHealth = max(1, _character!.currentHealth ~/ 2);

    _save();
    notifyListeners();
  }

  // ============ Death & Respawn ============

  void die() {
    if (_character == null) return;

    _character!.isAlive = false;
    _character!.totalDeaths++;

    _save();
    notifyListeners();
  }

  Future<void> respawn() async {
    if (_character == null) return;

    _character!.isAlive = true;
    _character!.currentHealth = 1;
    _character!.healthPotions = max(3, _character!.healthPotions);

    await _save();
    notifyListeners();
  }

  // ============ Equipment ============

  void upgradeWeapon() {
    if (_character == null) return;

    final maxTier = RPGSystem.maxGearTierForLevel(_character!.level);
    final weapons = RPGSystem.weaponProgression;
    final current = max(0, weapons.indexOf(_character!.weaponType));
    final target = min(maxTier, weapons.length - 1);

    if (current < target) {
      _character!.weaponType = weapons[current + 1];
      _save();
      notifyListeners();
    }
  }

  void upgradeArmor() {
    if (_character == null) return;

    final maxTier = RPGSystem.maxGearTierForLevel(_character!.level);
    final armors = RPGSystem.armorProgression;
    final current = max(0, armors.indexOf(_character!.armorType));
    final target = min(maxTier, armors.length - 1);

    if (current < target) {
      _character!.armorType = armors[current + 1];
      _save();
      notifyListeners();
    }
  }

  void setWeaponType(String type) {
    if (_character == null) return;
    if (!RPGSystem.weaponTypes.containsKey(type)) return;

    _character!.weaponType = type;
    _save();
    notifyListeners();
  }

  void setArmorType(String type) {
    if (_character == null) return;
    if (!RPGSystem.armorTypes.containsKey(type)) return;

    _character!.armorType = type;
    _save();
    notifyListeners();
  }

  // ============ Combat Stats ============

  int calculateAttackPower() {
    if (_character == null) return 0;

    final weaponType =
        RPGSystem.weaponTypes[_character!.weaponType] ??
        RPGSystem.weaponTypes['balanced']!;
    final baseDamage = weaponType.baseDamage + (_character!.strength ~/ 4);

    return RPGSystem.calculateWeaponDamage(
      baseDamage,
      _character!.strength,
      weaponType.strRequirement,
    );
  }

  int calculateDefense() {
    if (_character == null) return 0;

    final armorType =
        RPGSystem.armorTypes[_character!.armorType] ??
        RPGSystem.armorTypes['leather']!;

    return armorType.armorClass + (_character!.armorSkill ~/ 3);
  }

  int calculateEvasion() {
    if (_character == null) return 0;

    final armorType =
        RPGSystem.armorTypes[_character!.armorType] ??
        RPGSystem.armorTypes['leather']!;

    return RPGSystem.calculateEvasion(
      _character!.dexterity,
      _character!.dodgingSkill,
      armorType.encumbrance,
    );
  }

  int calculateAccuracy() {
    if (_character == null) return 0;

    final weaponType =
        RPGSystem.weaponTypes[_character!.weaponType] ??
        RPGSystem.weaponTypes['balanced']!;

    return RPGSystem.calculateAccuracy(
          _character!.weaponSkill,
          _character!.fightingSkill,
          _character!.dexterity,
        ) +
        weaponType.accuracyBonus;
  }

  // ============ Utility ============

  Future<void> save() async {
    await _save();
  }

  Future<void> _save() async {
    if (_character != null) {
      await _characterBox.put('main', _character!);
    }
  }

  /// For death/ascension - calculate potential echo shards
  int calculateEchoShards() {
    if (_character == null) return 0;

    return _gameState?.calculateEchoShards(
          _character!.experience,
          _character!.level,
          _character!.totalDeaths,
        ) ??
        0;
  }
}
