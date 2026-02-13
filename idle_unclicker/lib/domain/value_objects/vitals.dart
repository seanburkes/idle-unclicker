import '../events/character_events.dart';

/// Value object representing health points
/// Invariants: current >= 0, current <= max
class Health {
  final int current;
  final int max;

  const Health({required this.current, required this.max})
    : assert(current >= 0, 'Current health cannot be negative'),
      assert(max > 0, 'Max health must be positive'),
      assert(current <= max, 'Current health cannot exceed max');

  /// Creates initial health at maximum
  factory Health.full(int max) => Health(current: max, max: max);

  /// Checks if character is at critical health (< 25%)
  bool get isCritical => current <= (max * 0.25).floor();

  /// Checks if health is zero
  bool get isZero => current == 0;

  /// Calculates percentage of health remaining
  double get percentage => current / max;

  /// Takes damage and returns new Health state
  /// Returns null if character dies
  Health? takeDamage(int damage) {
    final newCurrent = (current - damage).clamp(0, max);
    if (newCurrent <= 0) return null;
    return Health(current: newCurrent, max: max);
  }

  /// Heals and returns new Health state
  Health heal(int amount) {
    final newCurrent = (current + amount).clamp(0, max);
    return Health(current: newCurrent, max: max);
  }

  /// Restores to full health
  Health restoreFull() => Health(current: max, max: max);

  /// Increases max health
  Health increaseMax(int amount) =>
      Health(current: current + amount, max: max + amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Health &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          max == other.max;

  @override
  int get hashCode => current.hashCode ^ max.hashCode;

  @override
  String toString() => 'Health($current/$max)';
}

/// Value object representing mana points
/// Invariants: current >= 0, current <= max
class Mana {
  final int current;
  final int max;

  const Mana({required this.current, required this.max})
    : assert(current >= 0, 'Current mana cannot be negative'),
      assert(max >= 0, 'Max mana cannot be negative'),
      assert(current <= max, 'Current mana cannot exceed max');

  /// Creates initial mana at maximum
  factory Mana.full(int max) => Mana(current: max, max: max);

  /// Consumes mana and returns new state
  /// Returns null if insufficient mana
  Mana? consume(int amount) {
    if (current < amount) return null;
    return Mana(current: current - amount, max: max);
  }

  /// Regenerates mana
  Mana regenerate(int amount) {
    final newCurrent = (current + amount).clamp(0, max);
    return Mana(current: newCurrent, max: max);
  }

  /// Increases max mana
  Mana increaseMax(int amount) =>
      Mana(current: current + amount, max: max + amount);

  /// Restores to full mana
  Mana restoreFull() => Mana(current: max, max: max);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mana &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          max == other.max;

  @override
  int get hashCode => current.hashCode ^ max.hashCode;

  @override
  String toString() => 'Mana($current/$max)';
}
