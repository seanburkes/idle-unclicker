import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../utils/dungeon_generator.dart';
import '../../utils/dungeon_renderer.dart';

/// Manages dungeon/town state and navigation
///
/// This provider handles:
/// - Current location (town/dungeon)
/// - Dungeon generation and rendering
/// - Town generation
/// - Depth management
/// - Town healing
class DungeonProvider extends ChangeNotifier {
  // Generators
  DungeonGenerator? _dungeonGenerator;
  TownGenerator? _townGenerator;
  DungeonRenderer? _cachedRenderer;

  // State
  bool _inTown = true;
  int _currentDungeonSeed = 0;
  int _dungeonDepth = 1;

  // Healing
  Timer? _townHealTimer;
  int _townHealSecondsRemaining = 0;
  int _townHealSecondCounter = 0;
  bool _isResting = false;

  DungeonProvider();

  // ============ Getters ============

  bool get inTown => _inTown;
  bool get inDungeon => !_inTown;
  int get dungeonDepth => _dungeonDepth;
  int get currentSeed => _currentDungeonSeed;

  bool get isResting => _isResting;
  bool get isTownHealing =>
      _townHealTimer != null && _townHealSecondsRemaining > 0;
  int get townHealingSecondsRemaining => _townHealSecondsRemaining;

  String get currentLocation => _inTown
      ? isTownHealing
            ? '🏘️ Town • Healing (${_townHealSecondsRemaining}s)'
            : '🏘️ Town'
      : '⛏️ Dungeon Level $_dungeonDepth';

  DungeonGenerator? get dungeonGenerator => _dungeonGenerator;
  TownGenerator? get townGenerator => _townGenerator;
  DungeonRenderer? get dungeonRenderer => _cachedRenderer;

  // ============ Initialization ============

  void initialize(int depth) {
    _dungeonDepth = depth;
    _currentDungeonSeed = depth;

    _dungeonGenerator = DungeonGenerator(
      width: 60,
      height: 18,
      seed: _currentDungeonSeed,
    );

    _townGenerator = TownGenerator(
      width: 50,
      height: 15,
      seed: DateTime.now().day,
    );

    _updateRenderer();
    notifyListeners();
  }

  // ============ Navigation ============

  void enterDungeon() {
    if (!_inTown) return;

    _stopTownHealing();
    _inTown = false;

    // Generate new dungeon for current level
    _currentDungeonSeed = _dungeonDepth;
    _dungeonGenerator = DungeonGenerator(
      width: 60,
      height: 18,
      seed: _currentDungeonSeed,
    );

    _updateRenderer();
    notifyListeners();
  }

  void returnToTown() {
    if (_inTown) return;

    _inTown = true;
    _dungeonGenerator = null;

    // Generate new town for the day
    _townGenerator = TownGenerator(
      width: 50,
      height: 15,
      seed: DateTime.now().day,
    );

    _updateRenderer();
    notifyListeners();
  }

  void fleeToSurface(int currentHealth, int maxHealth) {
    _inTown = true;
    _dungeonDepth = 1;

    // Health penalty for fleeing
    final newHealth = (currentHealth / 2).round();

    _updateRenderer();
    notifyListeners();
  }

  // ============ Depth Management ============

  void setDepth(int depth) {
    _dungeonDepth = depth;
    _currentDungeonSeed = depth;

    if (!_inTown) {
      _dungeonGenerator = DungeonGenerator(
        width: 60,
        height: 18,
        seed: _currentDungeonSeed,
      );
      _updateRenderer();
    }

    notifyListeners();
  }

  void descendDeeper() {
    _dungeonDepth++;
    _currentDungeonSeed = _dungeonDepth;

    _dungeonGenerator = DungeonGenerator(
      width: 60,
      height: 18,
      seed: _currentDungeonSeed,
    );

    _updateRenderer();
    notifyListeners();
  }

  // ============ Town Healing ============

  void startTownHealing(
    int currentHealth,
    int maxHealth,
    void Function() onHeal,
  ) {
    if (!inTown) return;
    if (currentHealth >= maxHealth) return;

    _stopTownHealing();
    _isResting = true;
    _townHealSecondCounter = 0;
    _townHealSecondsRemaining = (maxHealth - currentHealth) * 5;

    _townHealTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!inTown) {
        _stopTownHealing();
        return;
      }

      _townHealSecondCounter++;
      _townHealSecondsRemaining = (_townHealSecondsRemaining - 1).clamp(
        0,
        9999,
      );

      if (_townHealSecondCounter % 5 == 0) {
        onHeal();
      }

      if (_townHealSecondsRemaining <= 0) {
        _stopTownHealing();
      }

      notifyListeners();
    });

    notifyListeners();
  }

  void _stopTownHealing() {
    _townHealTimer?.cancel();
    _townHealTimer = null;
    _townHealSecondsRemaining = 0;
    _townHealSecondCounter = 0;
    _isResting = false;
  }

  void stopResting() {
    _isResting = false;
    notifyListeners();
  }

  // ============ Rendering ============

  void _updateRenderer() {
    if (_inTown) {
      _cachedRenderer = _townGenerator != null
          ? DungeonRenderer.town(_townGenerator!)
          : null;
    } else {
      _cachedRenderer = _dungeonGenerator != null
          ? DungeonRenderer.dungeon(_dungeonGenerator!)
          : null;
    }
  }

  String renderCurrentMap() {
    if (_inTown) {
      _townGenerator ??= TownGenerator(
        width: 50,
        height: 15,
        seed: DateTime.now().day,
      );
      return _townGenerator!.render();
    } else {
      _dungeonGenerator ??= DungeonGenerator(
        width: 60,
        height: 18,
        seed: _currentDungeonSeed == 0 ? _dungeonDepth : _currentDungeonSeed,
      );
      return _dungeonGenerator!.render();
    }
  }

  // ============ Cleanup ============

  @override
  void dispose() {
    _stopTownHealing();
    super.dispose();
  }
}
