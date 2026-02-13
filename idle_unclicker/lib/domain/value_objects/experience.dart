/// Value object representing experience and leveling
/// Invariants: current >= 0, expToNext > 0
class Experience {
  final double current;
  final double expToNext;
  static const double baseExpForLevel = 100.0;
  static const double levelMultiplier = 1.16;

  const Experience({required this.current, required this.expToNext})
    : assert(current >= 0, 'Current experience cannot be negative'),
      assert(expToNext > 0, 'Experience to next level must be positive');

  /// Creates initial experience for level 1
  factory Experience.initial() =>
      const Experience(current: 0, expToNext: baseExpForLevel);

  /// Calculates experience required for a specific level
  static double calculateExpForLevel(int level) {
    return baseExpForLevel * (levelMultiplier * level);
  }

  /// Checks if enough experience to level up
  bool get canLevelUp => current >= expToNext;

  /// Progress percentage toward next level (0.0 to 1.0)
  double get progressPercentage => (current / expToNext).clamp(0.0, 1.0);

  /// Adds experience and returns new state + level ups
  /// Returns tuple of (newExperience, levelsGained)
  (Experience, int) gain(double amount) {
    double newCurrent = current + amount;
    int levelsGained = 0;
    double nextExpToLevel = expToNext;

    while (newCurrent >= nextExpToLevel) {
      newCurrent -= nextExpToLevel;
      levelsGained++;
      nextExpToLevel = calculateExpForLevel(levelsGained + 1);
    }

    return (
      Experience(current: newCurrent, expToNext: nextExpToLevel),
      levelsGained,
    );
  }

  /// Resets experience for a new level (used after level up)
  Experience forNextLevel() => Experience(
    current: current,
    expToNext: calculateExpForLevel((current ~/ expToNext) + 2),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Experience &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          expToNext == other.expToNext;

  @override
  int get hashCode => current.hashCode ^ expToNext.hashCode;

  @override
  String toString() =>
      'Experience(${current.toStringAsFixed(0)}/${expToNext.toStringAsFixed(0)})';
}

/// Value object representing skill experience
/// Similar to Experience but for individual skills
class SkillExperience {
  final int level;
  final int currentXP;

  const SkillExperience({this.level = 0, this.currentXP = 0})
    : assert(level >= 0, 'Skill level cannot be negative'),
      assert(currentXP >= 0, 'Skill XP cannot be negative');

  /// Creates initial skill at level 0
  factory SkillExperience.initial() =>
      const SkillExperience(level: 0, currentXP: 0);

  /// Calculates XP threshold for current level
  int get threshold => 50 * (level + 1);

  /// Checks if skill can level up
  bool get canLevelUp => currentXP >= threshold;

  /// Progress percentage toward next level
  double get progressPercentage => (currentXP / threshold).clamp(0.0, 1.0);

  /// Gains XP and returns new state + level ups
  /// Returns tuple of (newSkillXP, levelsGained)
  (SkillExperience, int) gain(int amount) {
    int newXP = currentXP + amount;
    int newLevel = level;

    while (newXP >= 50 * (newLevel + 1)) {
      newXP -= 50 * (newLevel + 1);
      newLevel++;
    }

    return (
      SkillExperience(level: newLevel, currentXP: newXP),
      newLevel - level,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillExperience &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          currentXP == other.currentXP;

  @override
  int get hashCode => level.hashCode ^ currentXP.hashCode;

  @override
  String toString() => 'SkillExperience(L$level, $currentXP XP)';
}
