import 'package:hive/hive.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/meta_progression_repository.dart';
import '../../domain/value_objects/meta_progression.dart';

/// Hive implementation of GameStateRepository
class HiveGameStateRepository implements GameStateRepository {
  static const String boxName = 'game_state';
  static const String gameStateKey = 'global_game_state';

  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(boxName);
    return _box!;
  }

  @override
  Future<GameState?> getGameState() async {
    final b = await box;
    final data = b.get(gameStateKey);
    if (data == null) return null;
    return _fromMap(data);
  }

  @override
  Future<void> save(GameState gameState) async {
    final b = await box;
    final data = _toMap(gameState);
    await b.put(gameStateKey, data);
    gameState.clearDomainEvents();
  }

  @override
  Future<bool> exists() async {
    final b = await box;
    return b.containsKey(gameStateKey);
  }

  // === Mapping Methods ===

  GameState _fromMap(Map<dynamic, dynamic> data) {
    return GameState(
      id: GameStateId(data['id'] ?? 'global_game_state'),
      echoShards: data['echoShards'] ?? 0,
      totalAscensions: data['totalAscensions'] ?? 0,
      totalEchoesCollected: data['totalEchoesCollected'] ?? 0,
      metaUpgrades: _metaUpgradesFromMap(data['metaUpgrades'] ?? {}),
      focusPercentage: (data['focusPercentage'] ?? 0.0).toDouble(),
      zenStreakDays: data['zenStreakDays'] ?? 0,
      lastZenCheckDate: DateTime.parse(
        data['lastZenCheckDate'] ?? DateTime.now().toIso8601String(),
      ),
      lastUpdateTime: DateTime.parse(
        data['lastUpdateTime'] ?? DateTime.now().toIso8601String(),
      ),
      totalTimeInAppSeconds: data['totalTimeInAppSeconds'] ?? 0,
      totalTimeAwaySeconds: data['totalTimeAwaySeconds'] ?? 0,
      totalInteractions: data['totalInteractions'] ?? 0,
      unlockedRaces: List<String>.from(data['unlockedRaces'] ?? ['Human']),
      unlockedClasses: List<String>.from(
        data['unlockedClasses'] ?? ['Warrior'],
      ),
    );
  }

  Map<String, dynamic> _toMap(GameState gameState) {
    return {
      'id': gameState.id.value,
      'echoShards': gameState.echoShards,
      'totalAscensions': gameState.totalAscensions,
      'totalEchoesCollected': gameState.totalEchoesCollected,
      'metaUpgrades': _metaUpgradesToMap(gameState.metaUpgrades),
      'focusPercentage': gameState.focusPercentage,
      'zenStreakDays': gameState.zenStreakDays,
      'lastZenCheckDate': gameState.lastZenCheckDate.toIso8601String(),
      'lastUpdateTime': gameState.lastUpdateTime.toIso8601String(),
      'totalTimeInAppSeconds': gameState.totalTimeInAppSeconds,
      'totalTimeAwaySeconds': gameState.totalTimeAwaySeconds,
      'totalInteractions': gameState.totalInteractions,
      'unlockedRaces': gameState.unlockedRaces,
      'unlockedClasses': gameState.unlockedClasses,
    };
  }

  Map<MetaUpgradeType, MetaUpgrade> _metaUpgradesFromMap(
    Map<dynamic, dynamic> map,
  ) {
    final upgrades = <MetaUpgradeType, MetaUpgrade>{};
    for (final type in MetaUpgradeType.values) {
      final level = map[type.name] ?? 0;
      upgrades[type] = MetaUpgrade(type: type, currentLevel: level);
    }
    return upgrades;
  }

  Map<String, int> _metaUpgradesToMap(
    Map<MetaUpgradeType, MetaUpgrade> upgrades,
  ) {
    final map = <String, int>{};
    for (final entry in upgrades.entries) {
      map[entry.key.name] = entry.value.currentLevel;
    }
    return map;
  }
}
