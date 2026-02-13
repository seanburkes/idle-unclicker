import 'package:flutter_test/flutter_test.dart';
import 'package:idle_unclicker/domain/entities/character.dart';
import 'package:idle_unclicker/domain/value_objects/character_identity.dart';
import 'package:idle_unclicker/domain/value_objects/vitals.dart';
import 'package:idle_unclicker/domain/value_objects/experience.dart';
import 'package:idle_unclicker/domain/value_objects/stats.dart';

void main() {
  group('Character', () {
    late Character character;

    setUp(() {
      character = Character.create(
        name: 'TestHero',
        race: 'Human',
        characterClass: 'Warrior',
        stats: const CharacterStats(
          strength: 14,
          dexterity: 12,
          intelligence: 10,
          constitution: 14, // Gives +2 CON bonus, so 10 HP
          wisdom: 10,
          charisma: 10,
        ),
        startingGold: 100,
      );
    });

    test('should create character with correct initial state', () {
      expect(character.identity.name, 'TestHero');
      expect(character.identity.race, 'Human');
      expect(character.identity.characterClass, 'Warrior');
      expect(character.level, 1);
      expect(character.isAlive, true);
      expect(character.totalDeaths, 0);
      expect(character.gold, 100);
    });

    test('should take damage and reduce health', () {
      final initialHealth =
          character.health.current; // Should be 10 with CON 14
      character.takeDamage(5);

      expect(character.health.current, initialHealth - 5);
      expect(character.isAlive, true);
      expect(character.hasPendingEvents, true);
    });

    test('should die when health reaches zero', () {
      final maxHealth = character.health.max;
      character.takeDamage(maxHealth + 10);

      expect(character.isAlive, false);
      expect(character.totalDeaths, 1);
      expect(character.health.current, 0);
    });

    test('should heal correctly', () {
      character.takeDamage(5);
      final healthAfterDamage = character.health.current;

      character.heal(3);

      expect(character.health.current, healthAfterDamage + 3);
    });

    test('should not overheal', () {
      final maxHealth = character.health.max;
      character.heal(1000);

      expect(character.health.current, maxHealth);
    });

    test('should use health potion when available', () {
      final initialPotions = character.healthPotions;
      final maxHealth = character.health.max;

      character.takeDamage(maxHealth ~/ 2);
      final used = character.useHealthPotion();

      expect(used, true);
      expect(character.healthPotions, initialPotions - 1);
      expect(character.health.current, greaterThan(maxHealth ~/ 2));
    });

    test('should not use health potion when none available', () {
      character.healthPotions = 0;
      final used = character.useHealthPotion();

      expect(used, false);
    });

    test('should gain experience', () {
      final levelsGained = character.gainExperience(50);

      expect(levelsGained, 0);
      expect(character.experience.current, 50);
      expect(character.hasPendingEvents, true);
    });

    test('should level up when enough experience gained', () {
      character.gainExperience(150); // More than needed for level 1

      expect(character.level, greaterThan(1));
      expect(character.unallocatedPoints, greaterThan(0));
    });

    test('should allocate stat points correctly', () {
      character.unallocatedPoints = 3;
      final initialStr = character.stats.strength;

      final success = character.allocateStatPoint('strength');

      expect(success, true);
      expect(character.stats.strength, initialStr + 1);
      expect(character.unallocatedPoints, 2);
    });

    test('should not allocate stat points when none available', () {
      character.unallocatedPoints = 0;
      final success = character.allocateStatPoint('strength');

      expect(success, false);
    });

    test('should not allocate stat points when stat at max', () {
      character.unallocatedPoints = 3;
      // Create character with max strength
      character = Character.create(
        name: 'Test',
        race: 'Human',
        characterClass: 'Warrior',
        stats: CharacterStats(
          strength: 18, // Max
          dexterity: 10,
          intelligence: 10,
          constitution: 10,
          wisdom: 10,
          charisma: 10,
        ),
      );
      character.unallocatedPoints = 3;

      final success = character.allocateStatPoint('strength');

      expect(success, false);
    });

    test('should gain skill XP', () {
      character.gainSkillXP('weapon', 30);

      expect(character.weaponSkill.currentXP, 30);
      expect(character.weaponSkill.level, 0);
    });

    test('should level up skills', () {
      character.gainSkillXP('weapon', 60); // More than threshold of 50

      expect(character.weaponSkill.level, 1);
      expect(character.weaponSkill.currentXP, 10); // 60 - 50
    });

    test('should resurrect after death', () {
      character.takeDamage(character.health.max + 10);
      expect(character.isAlive, false);

      character.resurrect();

      expect(character.isAlive, true);
      expect(character.health.current, character.health.max);
    });

    test('should calculate attack power correctly', () {
      // Base from stats (14 // 3 = 4) + skill (0 // 2 = 0)
      expect(character.attackPower, 4);

      // Level up weapon skill to 2
      character.weaponSkill = SkillExperience(level: 2, currentXP: 0);
      expect(character.attackPower, 5); // 4 + (2 // 2 = 1)
    });

    test('should calculate defense correctly', () {
      // Base from stats (14 // 4 = 3) + skill (0 // 3 = 0)
      expect(character.defense, 3);
    });

    test('should detect critical health', () {
      final maxHealth = character.health.max;
      character.takeDamage((maxHealth * 0.8).floor());

      expect(character.isAtCriticalHealth, true);
    });

    test('should emit domain events', () {
      character.takeDamage(5); // Don't kill the character
      character.gainExperience(20);
      character.heal(3);

      final events = character.getDomainEvents();
      expect(events.length, 3);
      expect(events[0].eventType, 'CharacterDamaged');
      expect(events[1].eventType, 'ExperienceGained');
      expect(events[2].eventType, 'CharacterHealed');
    });

    test('should clear events after reading', () {
      character.takeDamage(10);
      expect(character.hasPendingEvents, true);

      character.getDomainEvents();
      character.clearDomainEvents();

      expect(character.hasPendingEvents, false);
    });
  });
}
