import 'package:flutter_test/flutter_test.dart';
import 'package:idle_unclicker/domain/value_objects/vitals.dart';

void main() {
  group('Health', () {
    test('should create health with valid values', () {
      const health = Health(current: 50, max: 100);
      expect(health.current, 50);
      expect(health.max, 100);
    });

    test('should enforce invariants', () {
      expect(() => Health(current: -1, max: 100), throwsAssertionError);
      expect(() => Health(current: 50, max: 0), throwsAssertionError);
      expect(() => Health(current: 150, max: 100), throwsAssertionError);
    });

    test('should create full health', () {
      final health = Health.full(100);
      expect(health.current, 100);
      expect(health.max, 100);
    });

    test('should detect critical health', () {
      final critical = Health(current: 20, max: 100);
      final healthy = Health(current: 50, max: 100);

      expect(critical.isCritical, true);
      expect(healthy.isCritical, false);
    });

    test('should take damage correctly', () {
      final health = Health(current: 100, max: 100);
      final damaged = health.takeDamage(30);

      expect(damaged, isNotNull);
      expect(damaged!.current, 70);
      expect(damaged.max, 100);
    });

    test('should return null when damage kills', () {
      final health = Health(current: 30, max: 100);
      final result = health.takeDamage(50);

      expect(result, isNull);
    });

    test('should heal correctly', () {
      final health = Health(current: 50, max: 100);
      final healed = health.heal(20);

      expect(healed.current, 70);
      expect(healed.max, 100);
    });

    test('should not overheal', () {
      final health = Health(current: 90, max: 100);
      final healed = health.heal(20);

      expect(healed.current, 100);
    });

    test('should increase max health', () {
      final health = Health(current: 50, max: 100);
      final increased = health.increaseMax(10);

      expect(increased.current, 60);
      expect(increased.max, 110);
    });

    test('should restore to full', () {
      final health = Health(current: 30, max: 100);
      final restored = health.restoreFull();

      expect(restored.current, 100);
      expect(restored.max, 100);
    });

    test('should be equal when values match', () {
      const health1 = Health(current: 50, max: 100);
      const health2 = Health(current: 50, max: 100);
      const health3 = Health(current: 60, max: 100);

      expect(health1 == health2, true);
      expect(health1 == health3, false);
    });
  });

  group('Mana', () {
    test('should create mana with valid values', () {
      const mana = Mana(current: 30, max: 50);
      expect(mana.current, 30);
      expect(mana.max, 50);
    });

    test('should create full mana', () {
      final mana = Mana.full(50);
      expect(mana.current, 50);
      expect(mana.max, 50);
    });

    test('should consume mana correctly', () {
      final mana = Mana(current: 50, max: 50);
      final consumed = mana.consume(20);

      expect(consumed, isNotNull);
      expect(consumed!.current, 30);
    });

    test('should return null when insufficient mana', () {
      final mana = Mana(current: 10, max: 50);
      final result = mana.consume(20);

      expect(result, isNull);
    });

    test('should regenerate mana', () {
      final mana = Mana(current: 30, max: 50);
      final regenerated = mana.regenerate(10);

      expect(regenerated.current, 40);
    });

    test('should not over-regenerate', () {
      final mana = Mana(current: 45, max: 50);
      final regenerated = mana.regenerate(10);

      expect(regenerated.current, 50);
    });

    test('should increase max mana', () {
      final mana = Mana(current: 30, max: 50);
      final increased = mana.increaseMax(10);

      expect(increased.current, 40);
      expect(increased.max, 60);
    });

    test('should restore to full', () {
      final mana = Mana(current: 20, max: 50);
      final restored = mana.restoreFull();

      expect(restored.current, 50);
      expect(restored.max, 50);
    });
  });
}
