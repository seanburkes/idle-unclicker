import 'aggregate_root.dart';
import '../events/character_events.dart';
import '../value_objects/character_identity.dart';
import '../value_objects/vitals.dart';
import '../value_objects/experience.dart';
import '../value_objects/stats.dart';

/// Aggregate Root: Character
///
/// The central entity representing a player character.
/// Enforces all character invariants and business rules.
///
/// Invariants:
/// - Health.current must be between 0 and max
/// - Experience.current must be >= 0
/// - Stats must be between 3-18
/// - When health reaches 0, character dies
/// - Death increments totalDeaths and sets isAlive=false
class Character extends AggregateRoot {
  final CharacterId id;
  final CharacterIdentity identity;
  int level;
  Experience experience;
  CharacterStats stats;
  Health health;
  Mana mana;
  int unallocatedPoints;
  bool isAlive;
  int totalDeaths;
  int dungeonDepth;
  int healthPotions;
  int gold;
  String weaponType;
  String armorType;

  // Skills
  SkillExperience weaponSkill;
  SkillExperience fightingSkill;
  SkillExperience armorSkill;
  SkillExperience dodgingSkill;

  Character({
    required this.id,
    required this.identity,
    this.level = 1,
    required this.experience,
    required this.stats,
    required this.health,
    required this.mana,
    this.unallocatedPoints = 0,
    this.isAlive = true,
    this.totalDeaths = 0,
    this.dungeonDepth = 1,
    this.healthPotions = 3,
    this.gold = 0,
    this.weaponType = 'balanced',
    this.armorType = 'leather',
    required this.weaponSkill,
    required this.fightingSkill,
    required this.armorSkill,
    required this.dodgingSkill,
  });

  /// Factory method to create a new character
  factory Character.create({
    required String name,
    required String race,
    required String characterClass,
    required CharacterStats stats,
    int startingGold = 0,
  }) {
    final id = CharacterId.fromNameAndTime(name, DateTime.now());
    final identity = CharacterIdentity(
      name: name,
      race: race,
      characterClass: characterClass,
    );

    // Calculate derived stats
    final conBonus = stats.constitutionBonus;
    final maxHealth = conBonus > -8 ? 8 + conBonus : 1;
    final maxMana = stats.baseMaxMana;

    return Character(
      id: id,
      identity: identity,
      level: 1,
      experience: Experience.initial(),
      stats: stats,
      health: Health.full(maxHealth),
      mana: Mana.full(maxMana),
      unallocatedPoints: 0,
      isAlive: true,
      totalDeaths: 0,
      dungeonDepth: 1,
      healthPotions: 3,
      gold: startingGold,
      weaponType: 'balanced',
      armorType: 'leather',
      weaponSkill: SkillExperience.initial(),
      fightingSkill: SkillExperience.initial(),
      armorSkill: SkillExperience.initial(),
      dodgingSkill: SkillExperience.initial(),
    );
  }

  // === Domain Behaviors ===

  /// Takes damage and handles death if health reaches 0
  void takeDamage(int damage) {
    final newHealth = health.takeDamage(damage);

    recordEvent(
      CharacterDamaged(
        characterId: id.value,
        damage: damage,
        currentHealth: newHealth?.current ?? 0,
        maxHealth: health.max,
      ),
    );

    if (newHealth == null) {
      // Character died
      _die();
    } else {
      health = newHealth;
    }
  }

  /// Heals the character
  void heal(int amount) {
    final newHealth = health.heal(amount);

    recordEvent(
      CharacterHealed(
        characterId: id.value,
        amount: amount,
        currentHealth: newHealth.current,
        maxHealth: newHealth.max,
      ),
    );

    health = newHealth;
  }

  /// Uses a health potion if available
  /// Returns true if potion was used
  bool useHealthPotion() {
    if (healthPotions <= 0) return false;

    healthPotions--;
    heal(health.max ~/ 2);
    return true;
  }

  /// Rests to recover health
  void rest() {
    heal(health.max ~/ 4);
  }

  /// Gains experience and handles level ups
  /// Returns number of levels gained
  int gainExperience(double amount) {
    recordEvent(
      ExperienceGained(
        characterId: id.value,
        amount: amount,
        currentExp: experience.current,
        expToNextLevel: experience.expToNext,
      ),
    );

    final (newExp, levelsGained) = experience.gain(amount);
    experience = newExp;

    if (levelsGained > 0) {
      for (int i = 0; i < levelsGained; i++) {
        _levelUp();
      }
    }

    return levelsGained;
  }

  /// Gains skill XP and handles skill level ups
  void gainSkillXP(String skill, int amount) {
    SkillExperience skillExp;
    switch (skill.toLowerCase()) {
      case 'weapon':
        skillExp = weaponSkill;
        break;
      case 'fighting':
        skillExp = fightingSkill;
        break;
      case 'armor':
        skillExp = armorSkill;
        break;
      case 'dodging':
        skillExp = dodgingSkill;
        break;
      default:
        return;
    }

    final (newSkill, levelsGained) = skillExp.gain(amount);

    recordEvent(
      SkillExperienceGained(
        characterId: id.value,
        skillName: skill,
        amount: amount,
        currentSkillXP: newSkill.currentXP,
        currentSkillLevel: newSkill.level,
      ),
    );

    // Update the appropriate skill
    switch (skill.toLowerCase()) {
      case 'weapon':
        weaponSkill = newSkill;
        break;
      case 'fighting':
        fightingSkill = newSkill;
        break;
      case 'armor':
        armorSkill = newSkill;
        break;
      case 'dodging':
        dodgingSkill = newSkill;
        break;
    }

    if (levelsGained > 0) {
      recordEvent(
        SkillLeveledUp(
          characterId: id.value,
          skillName: skill,
          newLevel: newSkill.level,
        ),
      );
    }
  }

  /// Allocates a stat point
  /// Returns true if successful
  bool allocateStatPoint(String stat) {
    if (unallocatedPoints <= 0) return false;

    final newStats = stats.allocatePoint(stat);
    if (newStats == null) return false;

    stats = newStats;
    unallocatedPoints--;
    return true;
  }

  /// Resurrects the character after death
  void resurrect() {
    isAlive = true;
    health = Health.full(health.max);
    mana = Mana.full(mana.max);
  }

  // === Private Methods ===

  void _die() {
    isAlive = false;
    totalDeaths++;
    health = Health(current: 0, max: health.max);

    recordEvent(CharacterDied(characterId: id.value, totalDeaths: totalDeaths));
  }

  void _levelUp() {
    level++;
    unallocatedPoints += 3;

    // Increase max health/mana and restore
    health = health.increaseMax(10).restoreFull();
    mana = mana.increaseMax(5).restoreFull();

    // Give bonus potion
    healthPotions++;

    recordEvent(
      CharacterLeveledUp(
        characterId: id.value,
        newLevel: level,
        unallocatedPoints: unallocatedPoints,
      ),
    );
  }

  // === Derived Properties ===

  /// Checks if at critical health (< 25%)
  bool get isAtCriticalHealth => health.isCritical;

  /// Attack power for combat calculations
  int get attackPower => stats.baseAttackPower + (weaponSkill.level ~/ 2);

  /// Defense for combat calculations
  int get defense => stats.baseDefense + (armorSkill.level ~/ 3);

  /// Experience progress percentage
  double get experienceProgress => experience.progressPercentage;

  @override
  String toString() =>
      'Character(${identity.name}, L$level, ${health.current}/${health.max} HP)';
}
