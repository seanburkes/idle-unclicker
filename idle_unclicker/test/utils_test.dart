import 'package:flutter_test/flutter_test.dart';
import 'package:idle_unclicker/utils/dungeon_generator.dart';
import 'package:idle_unclicker/utils/dungeon_renderer.dart';
import 'package:idle_unclicker/utils/rpg_system.dart';
import 'package:idle_unclicker/utils/procedural_generator.dart';

void main() {
  group('DungeonRenderer', () {
    test('should create dungeon with valid dimensions', () {
      final renderer = DungeonRenderer(width: 60, height: 20);
      final dungeon = renderer.render();

      // Check that dungeon is not empty
      expect(dungeon.isNotEmpty, true);

      // Check dimensions by counting lines
      final lines = dungeon.split('\n');
      expect(lines.length, lessThanOrEqualTo(20));
    });

    test('should render town layout', () {
      final renderer = DungeonRenderer.town(
        TownGenerator(width: 50, height: 15, seed: 1),
      );
      final town = renderer.render(inTown: true);

      expect(town.isNotEmpty, true);
      expect(town.contains('%'), true);
      expect(town.contains('#'), true);
      expect(town.contains('@'), true);
    });

    test('should regenerate dungeon', () {
      final renderer = DungeonRenderer(width: 60, height: 20);
      renderer.render();
      renderer.regenerate();
      final dungeon2 = renderer.render();

      // After regeneration, should still have valid output
      expect(dungeon2.isNotEmpty, true);
    });
  });

  group('RPGSystem', () {
    test('should calculate hit chance correctly', () {
      // Same accuracy and evasion should give 50% hit chance
      expect(RPGSystem.getHitChance(100, 100), 50);

      // Higher accuracy should increase hit chance
      expect(RPGSystem.getHitChance(150, 100), greaterThan(50));

      // Lower accuracy should decrease hit chance
      expect(RPGSystem.getHitChance(50, 100), lessThan(50));
    });

    test('should approach bounds at extremes', () {
      // Very high accuracy should approach 100%
      expect(RPGSystem.getHitChance(1000, 1), 100);

      // Very low accuracy should approach 0%
      expect(RPGSystem.getHitChance(1, 1000), 0);
    });

    test('should generate monster template', () {
      final template = RPGSystem.generateMonster(1, 1);

      expect(template.health, greaterThan(0));
      expect(template.damage, greaterThan(0));
      expect(template.evasion, greaterThanOrEqualTo(0));
      expect(template.armor, greaterThanOrEqualTo(0));
    });
  });

  group('ProceduralGenerator', () {
    test('should roll dice within expected range', () {
      for (int i = 0; i < 100; i++) {
        final roll = ProceduralGenerator.rollDice(6);
        expect(roll, greaterThanOrEqualTo(1));
        expect(roll, lessThanOrEqualTo(6));
      }
    });

    test('should roll percent correctly', () {
      // 100% should always return true
      expect(ProceduralGenerator.rollPercent(100), true);

      // 0% should always return false
      expect(ProceduralGenerator.rollPercent(0), false);
    });

    test('should generate valid race', () {
      final race = ProceduralGenerator.generateRace();
      expect(race.isNotEmpty, true);
    });

    test('should generate valid class', () {
      final characterClass = ProceduralGenerator.generateClass();
      expect(characterClass.isNotEmpty, true);
    });
  });
}
