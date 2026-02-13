import 'package:flutter_test/flutter_test.dart';
import 'package:idle_unclicker/domain/events/combat_events.dart';

void main() {
  group('Combat Events', () {
    test('CombatStarted should serialize correctly', () {
      final event = CombatStarted(
        characterId: 'char_123',
        monsterName: 'Goblin',
        monsterLevel: 5,
        dungeonDepth: 3,
      );

      expect(event.eventType, 'CombatStarted');
      expect(event.characterId, 'char_123');
      expect(event.monsterName, 'Goblin');
      expect(event.monsterLevel, 5);
      expect(event.dungeonDepth, 3);

      final json = event.toJson();
      expect(json['eventType'], 'CombatStarted');
      expect(json['characterId'], 'char_123');
      expect(json['monsterName'], 'Goblin');
    });

    test('PlayerAttacked should serialize correctly', () {
      final event = PlayerAttacked(
        characterId: 'char_123',
        damageDealt: 25,
        wasCritical: true,
        monsterHealthRemaining: 50,
      );

      expect(event.eventType, 'PlayerAttacked');
      expect(event.damageDealt, 25);
      expect(event.wasCritical, true);
      expect(event.monsterHealthRemaining, 50);

      final json = event.toJson();
      expect(json['wasCritical'], true);
      expect(json['damageDealt'], 25);
    });

    test('MonsterAttacked should serialize correctly', () {
      final event = MonsterAttacked(
        characterId: 'char_123',
        monsterName: 'Orc',
        damageDealt: 15,
        playerHealthRemaining: 85,
      );

      expect(event.eventType, 'MonsterAttacked');
      expect(event.monsterName, 'Orc');
      expect(event.damageDealt, 15);

      final json = event.toJson();
      expect(json['monsterName'], 'Orc');
    });

    test('CombatFled should serialize correctly', () {
      final event = CombatFled(
        characterId: 'char_123',
        reason: 'Critical health',
        healthRemaining: 10,
      );

      expect(event.eventType, 'CombatFled');
      expect(event.reason, 'Critical health');
      expect(event.healthRemaining, 10);

      final json = event.toJson();
      expect(json['reason'], 'Critical health');
    });

    test('MonsterDefeated should serialize correctly', () {
      final event = MonsterDefeated(
        characterId: 'char_123',
        monsterName: 'Dragon',
        xpGained: 100,
        goldGained: 50,
        dungeonDepth: 10,
      );

      expect(event.eventType, 'MonsterDefeated');
      expect(event.monsterName, 'Dragon');
      expect(event.xpGained, 100);
      expect(event.goldGained, 50);

      final json = event.toJson();
      expect(json['xpGained'], 100);
      expect(json['goldGained'], 50);
    });

    test('PotionUsedInCombat should serialize correctly', () {
      final event = PotionUsedInCombat(
        characterId: 'char_123',
        healAmount: 50,
        healthAfter: 80,
        potionsRemaining: 2,
      );

      expect(event.eventType, 'PotionUsedInCombat');
      expect(event.healAmount, 50);
      expect(event.potionsRemaining, 2);

      final json = event.toJson();
      expect(json['healAmount'], 50);
      expect(json['potionsRemaining'], 2);
    });

    test('LootFound should serialize correctly', () {
      final event = LootFound(
        characterId: 'char_123',
        itemName: 'Magic Sword',
        itemLevel: 10,
        rarity: 3,
      );

      expect(event.eventType, 'LootFound');
      expect(event.itemName, 'Magic Sword');
      expect(event.rarity, 3);

      final json = event.toJson();
      expect(json['itemName'], 'Magic Sword');
      expect(json['rarity'], 3);
    });

    test('CharacterRested should serialize correctly', () {
      final event = CharacterRested(
        characterId: 'char_123',
        healthRegained: 25,
        healthAfter: 75,
      );

      expect(event.eventType, 'CharacterRested');
      expect(event.healthRegained, 25);
      expect(event.healthAfter, 75);

      final json = event.toJson();
      expect(json['healthRegained'], 25);
    });

    test('ReturnedToTown should serialize correctly', () {
      final event = ReturnedToTown(
        characterId: 'char_123',
        reason: 'Low on potions',
        dungeonDepth: 5,
      );

      expect(event.eventType, 'ReturnedToTown');
      expect(event.reason, 'Low on potions');
      expect(event.dungeonDepth, 5);

      final json = event.toJson();
      expect(json['reason'], 'Low on potions');
    });

    test('All events should have occurredAt timestamp', () {
      final before = DateTime.now();

      final event = CombatStarted(
        characterId: 'char_123',
        monsterLevel: 1,
        dungeonDepth: 1,
      );

      final after = DateTime.now();

      expect(
        event.occurredAt.isAfter(before) ||
            event.occurredAt.isAtSameMomentAs(before),
        true,
      );
      expect(
        event.occurredAt.isBefore(after) ||
            event.occurredAt.isAtSameMomentAs(after),
        true,
      );
    });
  });
}
