import 'package:flutter_test/flutter_test.dart';
import 'package:idle_unclicker/domain/value_objects/combat_objects.dart';

void main() {
  group('Monster', () {
    test('should create monster with valid values', () {
      final monster = Monster(
        name: 'Goblin',
        level: 5,
        health: 50,
        maxHealth: 50,
        damage: 10,
        armor: 5,
        evasion: 3,
        xpValue: 25,
        goldValue: 10,
      );

      expect(monster.name, 'Goblin');
      expect(monster.level, 5);
      expect(monster.health, 50);
      expect(monster.isDefeated, false);
    });

    test('should enforce invariants', () {
      expect(
        () => Monster(
          name: 'Test',
          level: 1,
          health: -1, // Invalid
          maxHealth: 50,
          damage: 10,
          armor: 5,
          evasion: 3,
          xpValue: 25,
          goldValue: 10,
        ),
        throwsAssertionError,
      );

      expect(
        () => Monster(
          name: 'Test',
          level: 0, // Invalid
          health: 50,
          maxHealth: 50,
          damage: 10,
          armor: 5,
          evasion: 3,
          xpValue: 25,
          goldValue: 10,
        ),
        throwsAssertionError,
      );
    });

    test('should detect when defeated', () {
      final monster = Monster(
        name: 'Goblin',
        level: 1,
        health: 10,
        maxHealth: 10,
        damage: 5,
        armor: 2,
        evasion: 1,
        xpValue: 10,
        goldValue: 5,
      );

      expect(monster.isDefeated, false);

      monster.takeDamage(15);
      expect(monster.isDefeated, true);
      expect(monster.health, 0);
    });

    test('should calculate hit chance correctly', () {
      // Test normal case
      final monster1 = Monster(
        name: 'Test',
        level: 5,
        health: 50,
        maxHealth: 50,
        damage: 30, // accuracy = 30 * 0.5 = 15
        armor: 5,
        evasion: 5,
        xpValue: 25,
        goldValue: 10,
      );

      // accuracy(15) vs evasion(5)
      // chance = 50 + (15 - 5) / 5 = 50 + 2 = 52%
      expect(monster1.getHitChance(5), 52);

      // Should be clamped to minimum 5%
      expect(monster1.getHitChance(1000), 5);

      // Test max clamping - need very high accuracy
      final monster2 = Monster(
        name: 'Test2',
        level: 50,
        health: 500,
        maxHealth: 500,
        damage: 500, // accuracy = 500 * 0.5 = 250
        armor: 50,
        evasion: 50,
        xpValue: 250,
        goldValue: 100,
      );
      // accuracy(250) vs evasion(0) = 50 + 250/5 = 100, clamped to 95%
      expect(monster2.getHitChance(0), 95);
    });

    test('should take damage with armor reduction', () {
      final monster = Monster(
        name: 'Test',
        level: 5,
        health: 100,
        maxHealth: 100,
        damage: 10,
        armor: 10, // Reduces damage by 5
        evasion: 3,
        xpValue: 25,
        goldValue: 10,
      );

      // Attack power 20, armor 10
      // Actual damage = 20 - (10/2) = 15
      final damage = monster.takeDamage(20);
      expect(damage, 15);
      expect(monster.health, 85);
    });

    test('should deal minimum 1 damage', () {
      final monster = Monster(
        name: 'Test',
        level: 5,
        health: 100,
        maxHealth: 100,
        damage: 10,
        armor: 100, // High armor
        evasion: 3,
        xpValue: 25,
        goldValue: 10,
      );

      // Even with high armor, minimum 1 damage
      final damage = monster.takeDamage(10);
      expect(damage, 1);
      expect(monster.health, 99);
    });
  });

  group('CombatResult', () {
    test('should create victory result', () {
      final result = CombatResult.victory(
        damageDealt: 100,
        damageTaken: 20,
        turns: 5,
        xp: 50,
        gold: 25,
        log: ['Hit', 'Defeated enemy'],
      );

      expect(result.victory, true);
      expect(result.fled, false);
      expect(result.totalDamageDealt, 100);
      expect(result.totalDamageTaken, 20);
      expect(result.xpGained, 50);
      expect(result.goldGained, 25);
    });

    test('should create defeat result', () {
      final result = CombatResult.defeat(
        damageDealt: 50,
        turns: 3,
        log: ['Hit', 'You died'],
      );

      expect(result.victory, false);
      expect(result.fled, false);
      expect(result.totalDamageDealt, 50);
      expect(result.totalDamageTaken, 0);
    });

    test('should create fled result', () {
      final result = CombatResult.fled(
        damageDealt: 30,
        damageTaken: 40,
        turns: 2,
        reason: 'Critical health',
        log: ['Hit', 'Taking damage'],
      );

      expect(result.victory, false);
      expect(result.fled, true);
      expect(result.totalDamageDealt, 30);
      expect(result.totalDamageTaken, 40);
      expect(result.log.last, 'Fled: Critical health');
    });
  });

  group('LootItem', () {
    test('should create loot item', () {
      final item = LootItem(
        name: 'Magic Sword',
        slot: 'weapon',
        level: 10,
        rarity: 3,
        attackBonus: 15,
        defenseBonus: 0,
      );

      expect(item.name, 'Magic Sword');
      expect(item.slot, 'weapon');
      expect(item.level, 10);
      expect(item.rarity, 3);
      expect(item.isWeapon, true);
      expect(item.isArmor, false);
      expect(item.attackBonus, 15);
    });

    test('should identify armor correctly', () {
      final item = LootItem(
        name: 'Steel Armor',
        slot: 'chest',
        level: 10,
        rarity: 2,
        attackBonus: 0,
        defenseBonus: 20,
      );

      expect(item.isWeapon, false);
      expect(item.isArmor, true);
    });
  });
}
