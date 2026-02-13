import '../../domain/entities/character.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/guild_hall.dart';
import '../../domain/services/meta_progression_service.dart';
import '../../domain/repositories/character_repository.dart';
import '../../domain/repositories/meta_progression_repository.dart';
import '../../domain/value_objects/meta_progression.dart';
import '../../domain/value_objects/character_identity.dart';

/// DTO for ascension preview
class AscensionPreviewDto {
  final int echoShards;
  final List<String> newRaces;
  final List<String> newClasses;
  final int newAscensionNumber;

  AscensionPreviewDto({
    required this.echoShards,
    required this.newRaces,
    required this.newClasses,
    required this.newAscensionNumber,
  });
}

/// DTO for meta-progression summary
class MetaProgressionSummaryDto {
  final int totalAscensions;
  final int echoShards;
  final int totalEchoesCollected;
  final int totalUpgradeLevels;
  final int metaScore;
  final Map<String, dynamic> startingBonuses;
  final List<String> unlockedRaces;
  final List<String> unlockedClasses;
  final bool guildHallUnlocked;
  final double focusPercentage;
  final int zenStreakDays;

  MetaProgressionSummaryDto({
    required this.totalAscensions,
    required this.echoShards,
    required this.totalEchoesCollected,
    required this.totalUpgradeLevels,
    required this.metaScore,
    required this.startingBonuses,
    required this.unlockedRaces,
    required this.unlockedClasses,
    required this.guildHallUnlocked,
    required this.focusPercentage,
    required this.zenStreakDays,
  });
}

/// Application service for meta-progression use cases
class MetaProgressionApplicationService {
  final GameStateRepository _gameStateRepository;
  final GuildHallRepository _guildHallRepository;
  final CharacterRepository _characterRepository;
  final MetaProgressionService _metaProgressionService;

  MetaProgressionApplicationService({
    required GameStateRepository gameStateRepository,
    required GuildHallRepository guildHallRepository,
    required CharacterRepository characterRepository,
    required MetaProgressionService metaProgressionService,
  }) : _gameStateRepository = gameStateRepository,
       _guildHallRepository = guildHallRepository,
       _characterRepository = characterRepository,
       _metaProgressionService = metaProgressionService;

  /// Get or create game state
  Future<GameState> _getOrCreateGameState() async {
    var gameState = await _gameStateRepository.getGameState();
    if (gameState == null) {
      gameState = GameState.create();
      await _gameStateRepository.save(gameState);
    }
    return gameState;
  }

  /// Get or create Guild Hall
  Future<GuildHall> _getOrCreateGuildHall(String gameStateId) async {
    var guildHall = await _guildHallRepository.findByGameStateId(gameStateId);
    if (guildHall == null) {
      guildHall = GuildHall.create(gameStateId);
      await _guildHallRepository.save(guildHall);
    }
    return guildHall;
  }

  /// Record interaction (reduces focus)
  Future<void> recordInteraction() async {
    final gameState = await _getOrCreateGameState();
    gameState.recordInteraction();
    await _gameStateRepository.save(gameState);
  }

  /// Update focus based on time
  Future<void> updateFocus(int secondsAway, int secondsInApp) async {
    final gameState = await _getOrCreateGameState();
    gameState.updateFocus(secondsAway, secondsInApp);
    gameState.checkZenStreak();
    await _gameStateRepository.save(gameState);
  }

  /// Preview ascension rewards
  Future<AscensionPreviewDto> previewAscension(String characterId) async {
    final character = await _characterRepository.findById(
      CharacterId(characterId),
    );
    if (character == null) {
      throw ArgumentError('Character not found');
    }

    final gameState = await _getOrCreateGameState();

    final rewards = _metaProgressionService.calculateAscensionRewards(
      currentXp: character.experience.current,
      level: character.level,
      totalDeaths: character.totalDeaths,
    );

    final unlocks = _metaProgressionService.previewUnlocks(
      gameState.totalAscensions,
    );

    return AscensionPreviewDto(
      echoShards: rewards.echoShards,
      newRaces: unlocks['races'] ?? [],
      newClasses: unlocks['classes'] ?? [],
      newAscensionNumber: gameState.totalAscensions + 1,
    );
  }

  /// Perform ascension
  Future<MetaProgressionSummaryDto> ascend(String characterId) async {
    final character = await _characterRepository.findById(
      CharacterId(characterId),
    );
    if (character == null) {
      throw ArgumentError('Character not found');
    }

    final gameState = await _getOrCreateGameState();
    final guildHall = await _getOrCreateGuildHall(gameState.id.value);

    // Perform ascension
    gameState.ascend(character);

    // Unlock Guild Hall on first ascension
    if (gameState.totalAscensions == 1 && !guildHall.isUnlocked) {
      guildHall.unlock(1);
    }

    // Add echo to Guild Hall
    if (guildHall.isUnlocked) {
      final fate = _metaProgressionService.generateEchoFate(character, true);
      guildHall.addEcho(character, fate: fate);
    }

    // Save everything
    await _gameStateRepository.save(gameState);
    await _guildHallRepository.save(guildHall);

    return getMetaProgressionSummary();
  }

  /// Purchase a meta-upgrade
  Future<void> purchaseMetaUpgrade(MetaUpgradeType type) async {
    final gameState = await _getOrCreateGameState();
    gameState.purchaseUpgrade(type);
    await _gameStateRepository.save(gameState);
  }

  /// Get available upgrades
  Future<Map<MetaUpgradeType, Map<String, dynamic>>>
  getAvailableUpgrades() async {
    final gameState = await _getOrCreateGameState();
    return gameState.availableUpgrades;
  }

  /// Upgrade a Guild Hall room
  Future<void> upgradeGuildHallRoom(RoomType type, int availableGold) async {
    final gameState = await _getOrCreateGameState();
    final guildHall = await _getOrCreateGuildHall(gameState.id.value);

    if (!guildHall.isUnlocked) {
      throw StateError('Guild Hall is locked');
    }

    final cost = guildHall.getUpgradeCost(type);
    if (availableGold < cost) {
      throw StateError('Not enough gold');
    }

    guildHall.upgradeRoom(type, cost);
    await _guildHallRepository.save(guildHall);
  }

  /// Get Guild Hall status
  Future<Map<String, dynamic>> getGuildHallStatus() async {
    final gameState = await _getOrCreateGameState();
    final guildHall = await _getOrCreateGuildHall(gameState.id.value);

    return {
      'isUnlocked': guildHall.isUnlocked,
      'totalRoomLevels': guildHall.totalRoomLevels,
      'maxedRooms': guildHall.maxedRoomsCount,
      'echoCount': guildHall.echoCount,
      'completionPercentage': guildHall.completionPercentage,
      'bonuses': guildHall.totalBonuses.toMap(),
      'rooms': guildHall.rooms
          .map(
            (r) => {
              'type': r.type.name,
              'name': r.type.displayName,
              'level': r.level,
              'maxLevel': Room.maxLevel,
              'upgradeCost': r.upgradeCost,
              'bonus': r.bonus,
              'isMaxed': r.isMaxed,
            },
          )
          .toList(),
      'echoes': guildHall.echoes
          .map(
            (e) => {
              'name': e.name,
              'race': e.race,
              'class': e.characterClass,
              'level': e.level,
              'fate': e.fate,
            },
          )
          .toList(),
    };
  }

  /// Get meta-progression summary
  Future<MetaProgressionSummaryDto> getMetaProgressionSummary() async {
    final gameState = await _getOrCreateGameState();
    final guildHall = await _getOrCreateGuildHall(gameState.id.value);

    final bonuses = _metaProgressionService.calculateCombinedBonuses(
      gameState,
      guildHall.isUnlocked ? guildHall : null,
    );

    final metaScore = _metaProgressionService.calculateMetaScore(
      gameState,
      guildHall.isUnlocked ? guildHall : null,
    );

    return MetaProgressionSummaryDto(
      totalAscensions: gameState.totalAscensions,
      echoShards: gameState.echoShards,
      totalEchoesCollected: gameState.totalEchoesCollected,
      totalUpgradeLevels: gameState.totalUpgradeLevels,
      metaScore: metaScore,
      startingBonuses: {
        'healthBonus': bonuses.healthBonus,
        'potionBonus': bonuses.potionBonus,
        'xpMultiplier': bonuses.xpMultiplier,
        'startingDepth': bonuses.startingDepth,
        'goldFindMultiplier': bonuses.goldFindMultiplier,
        'equipmentDropMultiplier': bonuses.equipmentDropMultiplier,
        'bestiaryRateMultiplier': bonuses.bestiaryRateMultiplier,
      },
      unlockedRaces: gameState.unlockedRaces,
      unlockedClasses: gameState.unlockedClasses,
      guildHallUnlocked: guildHall.isUnlocked,
      focusPercentage: gameState.focusPercentage,
      zenStreakDays: gameState.zenStreakDays,
    );
  }

  /// Get recommended upgrade
  Future<Map<String, dynamic>?> getRecommendedUpgrade(String playstyle) async {
    final gameState = await _getOrCreateGameState();

    final recommended = _metaProgressionService.getRecommendedUpgrade(
      gameState,
      playstyle,
    );

    if (recommended == null) return null;

    final upgrade = gameState.getUpgrade(recommended);
    return {
      'type': recommended.name,
      'displayName': recommended.displayName,
      'description': recommended.description,
      'currentLevel': upgrade.currentLevel,
      'maxLevel': recommended.maxLevel,
      'nextCost': upgrade.nextCost,
      'canAfford': upgrade.canAfford(gameState.echoShards),
    };
  }

  /// Get optimal room upgrade order
  Future<List<Map<String, dynamic>>> getOptimalRoomUpgrades(
    String playstyle,
  ) async {
    final gameState = await _getOrCreateGameState();
    final guildHall = await _getOrCreateGuildHall(gameState.id.value);

    if (!guildHall.isUnlocked) return [];

    final order = _metaProgressionService.getOptimalUpgradeOrder(
      guildHall,
      playstyle,
    );

    return order.map((type) {
      final room = guildHall.getRoom(type)!;
      return {
        'type': type.name,
        'name': type.displayName,
        'currentLevel': room.level,
        'upgradeCost': room.upgradeCost,
      };
    }).toList();
  }
}
