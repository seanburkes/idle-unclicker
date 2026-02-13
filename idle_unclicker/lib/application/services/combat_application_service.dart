import 'dart:math';
import '../../domain/entities/character.dart';
import '../../domain/value_objects/combat_objects.dart';
import '../../domain/value_objects/character_identity.dart';
import '../../domain/services/combat_service.dart';
import '../../domain/repositories/character_repository.dart';

/// Data Transfer Object for combat initiation
class InitiateCombatDto {
  final String characterId;
  final int? targetDungeonDepth;

  InitiateCombatDto({required this.characterId, this.targetDungeonDepth});
}

/// Data Transfer Object for combat turn result
class CombatTurnResultDto {
  final bool combatEnded;
  final bool victory;
  final bool fled;
  final bool playerDied;
  final int playerHealth;
  final int playerMaxHealth;
  final String? monsterName;
  final int? monsterHealth;
  final int damageDealt;
  final int damageTaken;
  final int? xpGained;
  final int? goldGained;
  final List<String> actions;
  final LootItem? lootFound;

  CombatTurnResultDto({
    required this.combatEnded,
    required this.victory,
    required this.fled,
    required this.playerDied,
    required this.playerHealth,
    required this.playerMaxHealth,
    this.monsterName,
    this.monsterHealth,
    required this.damageDealt,
    required this.damageTaken,
    this.xpGained,
    this.goldGained,
    required this.actions,
    this.lootFound,
  });
}

/// Application service for combat use cases
///
/// This service orchestrates combat operations by coordinating
/// domain entities, domain services, and repositories.
class CombatApplicationService {
  final CharacterRepository _characterRepository;
  final CombatService _combatService;

  CombatApplicationService({
    required CharacterRepository characterRepository,
    required CombatService combatService,
  }) : _characterRepository = characterRepository,
       _combatService = combatService;

  /// Initiates combat and returns the generated monster
  ///
  /// Use case: Player enters combat in the dungeon
  Future<(Character, Monster)> initiateCombat(InitiateCombatDto dto) async {
    final character = await _characterRepository.findById(
      CharacterId(dto.characterId),
    );

    if (character == null) {
      throw ArgumentError('Character not found: ${dto.characterId}');
    }

    if (!character.isAlive) {
      throw StateError('Cannot initiate combat while dead');
    }

    final dungeonDepth = dto.targetDungeonDepth ?? character.dungeonDepth;
    final monster = _combatService.generateMonster(
      dungeonDepth,
      character.level,
    );

    return (character, monster);
  }

  /// Processes a single combat turn
  ///
  /// Use case: Process one round of combat between player and monster
  Future<CombatTurnResultDto> processCombatTurn(
    Character character,
    Monster monster,
  ) async {
    final actions = <String>[];

    // 1. Check if should flee
    if (_combatService.shouldFlee(character, monster)) {
      _combatService.returnToTown(
        character,
        reason: 'Fled from ${monster.name} at critical health',
      );

      await _characterRepository.save(character);

      return CombatTurnResultDto(
        combatEnded: true,
        victory: false,
        fled: true,
        playerDied: false,
        playerHealth: character.health.current,
        playerMaxHealth: character.health.max,
        monsterName: monster.name,
        monsterHealth: monster.health,
        damageDealt: 0,
        damageTaken: 0,
        actions: ['Fled from combat with ${monster.name}'],
      );
    }

    // 2. Check if should use potion
    if (_combatService.shouldUsePotion(character)) {
      if (_combatService.usePotion(character)) {
        actions.add('Used health potion (+${character.health.max ~/ 2} HP)');
      }
    }

    // 3. Process combat turn
    final combatResult = _combatService.processCombatTurn(character, monster);
    actions.addAll(combatResult.log);

    // 4. Check combat outcome
    if (combatResult.victory) {
      // Combat won - check for loot
      final loot = _combatService.generateLoot(
        character.dungeonDepth,
        monster.level,
      );

      // Check for potion drop (30% chance)
      if (_combatService.shouldDropPotion()) {
        character.healthPotions++;
        actions.add('Found health potion!');
      }

      // Save character state
      await _characterRepository.save(character);

      return CombatTurnResultDto(
        combatEnded: true,
        victory: true,
        fled: false,
        playerDied: false,
        playerHealth: character.health.current,
        playerMaxHealth: character.health.max,
        monsterName: monster.name,
        monsterHealth: 0,
        damageDealt: combatResult.totalDamageDealt,
        damageTaken: combatResult.totalDamageTaken,
        xpGained: combatResult.xpGained,
        goldGained: combatResult.goldGained,
        actions: actions,
        lootFound: loot,
      );
    }

    if (!character.isAlive) {
      // Player died
      await _characterRepository.save(character);

      return CombatTurnResultDto(
        combatEnded: true,
        victory: false,
        fled: false,
        playerDied: true,
        playerHealth: 0,
        playerMaxHealth: character.health.max,
        monsterName: monster.name,
        monsterHealth: monster.health,
        damageDealt: combatResult.totalDamageDealt,
        damageTaken: combatResult.totalDamageTaken,
        actions: actions,
      );
    }

    // Combat continues
    await _characterRepository.save(character);

    return CombatTurnResultDto(
      combatEnded: false,
      victory: false,
      fled: false,
      playerDied: false,
      playerHealth: character.health.current,
      playerMaxHealth: character.health.max,
      monsterName: monster.name,
      monsterHealth: monster.health,
      damageDealt: combatResult.totalDamageDealt,
      damageTaken: combatResult.totalDamageTaken,
      actions: actions,
    );
  }

  /// Handles post-combat logic
  ///
  /// Use case: Determine what to do after combat ends
  Future<List<String>> processPostCombat(
    Character character,
    bool victory,
  ) async {
    final actions = <String>[];

    if (!victory) {
      // Died - character is already updated in processCombatTurn
      return actions;
    }

    // Check if should rest
    if (_combatService.shouldRestAfterCombat(character)) {
      _combatService.rest(character);
      actions.add('Rested and recovered health');
    }

    // Check if should return to town
    if (_combatService.shouldReturnToTown(character)) {
      _combatService.returnToTown(character, reason: 'Low on resources');
      actions.add('Returned to town for supplies');
    } else {
      // Continue to next depth
      character.dungeonDepth++;
      actions.add('Descending to floor ${character.dungeonDepth}');
    }

    await _characterRepository.save(character);

    return actions;
  }

  /// Handles player resurrection after death
  ///
  /// Use case: Respawn character in town after dying
  Future<List<String>> processResurrection(Character character) async {
    final actions = <String>[];

    if (character.isAlive) {
      throw StateError('Character is already alive');
    }

    actions.add('Character died! Respawning in town...');

    // Reset character state
    character.dungeonDepth = 1;
    character.resurrect();
    character.totalDeaths++;

    // Lose 50% gold
    final goldLost = (character.gold * 0.5).round();
    character.gold -= goldLost;

    // Ensure minimum potions
    if (character.healthPotions < 3) {
      character.healthPotions = 3;
    }

    actions.add('Respawned in town');
    actions.add('Lost $goldLost gold (${(character.gold * 2)} remaining)');
    actions.add('Total deaths: ${character.totalDeaths}');

    await _characterRepository.save(character);

    return actions;
  }

  /// Allows manual return to town
  ///
  /// Use case: Player chooses to return to town
  Future<void> returnToTown(
    Character character, {
    required String reason,
  }) async {
    _combatService.returnToTown(character, reason: reason);
    await _characterRepository.save(character);
  }
}

/// Extension method for potion drop chance
extension CombatServiceExtension on CombatService {
  bool shouldDropPotion() {
    // 30% chance to drop potion from monster
    return (Random().nextDouble() < 0.3);
  }
}
