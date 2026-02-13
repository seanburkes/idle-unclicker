import 'dart:async';
import 'package:flutter/foundation.dart';

/// Manages all game loop timers and tick orchestration
///
/// This provider is responsible for:
/// - Starting/stopping all periodic timers
/// - Distributing ticks to other providers via callbacks
/// - Managing timer lifecycle (app pause/resume)
class GameTimerProvider extends ChangeNotifier {
  // Core timers
  Timer? _gameTimer;
  Timer? _focusTimer;
  Timer? _saveTimer;
  Timer? _combatTimer;

  // Feature timers
  Timer? _skillTreeTimer;
  Timer? _guildHallTimer;
  Timer? _professionTimer;
  Timer? _bossRiftTimer;
  Timer? _equipmentSetTimer;
  Timer? _transmutationTimer;
  Timer? _alchemyTimer;
  Timer? _legendaryTimer;
  Timer? _spiralTimer;
  Timer? _enchantingTimer;
  Timer? _townHealTimer;

  // Configuration
  final Map<TimerType, Duration> _intervals = {
    TimerType.game: const Duration(seconds: 5),
    TimerType.focus: const Duration(seconds: 30),
    TimerType.save: const Duration(seconds: 60),
    TimerType.combat: const Duration(seconds: 1),
    TimerType.skillTree: const Duration(minutes: 1),
    TimerType.guildHall: const Duration(minutes: 2),
    TimerType.profession: const Duration(minutes: 2),
    TimerType.bossRift: const Duration(minutes: 5),
    TimerType.equipmentSet: const Duration(minutes: 4),
    TimerType.transmutation: const Duration(minutes: 3),
    TimerType.alchemy: const Duration(seconds: 30),
    TimerType.legendary: const Duration(minutes: 4),
    TimerType.spiral: const Duration(minutes: 5),
    TimerType.enchanting: const Duration(minutes: 3),
  };

  // Callbacks for tick distribution
  final Map<TimerType, List<VoidCallback>> _tickCallbacks = {};

  bool _isRunning = false;
  bool _isPaused = false;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  /// Register a callback for a specific timer type
  void onTick(TimerType type, VoidCallback callback) {
    _tickCallbacks.putIfAbsent(type, () => []).add(callback);
  }

  /// Unregister a callback
  void removeCallback(TimerType type, VoidCallback callback) {
    _tickCallbacks[type]?.remove(callback);
  }

  /// Start all game timers
  void startAll() {
    if (_isRunning) return;

    _cancelAll();

    _gameTimer = Timer.periodic(
      _intervals[TimerType.game]!,
      (_) => _distributeTick(TimerType.game),
    );
    _focusTimer = Timer.periodic(
      _intervals[TimerType.focus]!,
      (_) => _distributeTick(TimerType.focus),
    );
    _saveTimer = Timer.periodic(
      _intervals[TimerType.save]!,
      (_) => _distributeTick(TimerType.save),
    );
    _combatTimer = Timer.periodic(
      _intervals[TimerType.combat]!,
      (_) => _distributeTick(TimerType.combat),
    );
    _skillTreeTimer = Timer.periodic(
      _intervals[TimerType.skillTree]!,
      (_) => _distributeTick(TimerType.skillTree),
    );
    _guildHallTimer = Timer.periodic(
      _intervals[TimerType.guildHall]!,
      (_) => _distributeTick(TimerType.guildHall),
    );
    _enchantingTimer = Timer.periodic(
      _intervals[TimerType.enchanting]!,
      (_) => _distributeTick(TimerType.enchanting),
    );
    _professionTimer = Timer.periodic(
      _intervals[TimerType.profession]!,
      (_) => _distributeTick(TimerType.profession),
    );
    _bossRiftTimer = Timer.periodic(
      _intervals[TimerType.bossRift]!,
      (_) => _distributeTick(TimerType.bossRift),
    );
    _equipmentSetTimer = Timer.periodic(
      _intervals[TimerType.equipmentSet]!,
      (_) => _distributeTick(TimerType.equipmentSet),
    );
    _transmutationTimer = Timer.periodic(
      _intervals[TimerType.transmutation]!,
      (_) => _distributeTick(TimerType.transmutation),
    );
    _alchemyTimer = Timer.periodic(
      _intervals[TimerType.alchemy]!,
      (_) => _distributeTick(TimerType.alchemy),
    );
    _legendaryTimer = Timer.periodic(
      _intervals[TimerType.legendary]!,
      (_) => _distributeTick(TimerType.legendary),
    );
    _spiralTimer = Timer.periodic(
      _intervals[TimerType.spiral]!,
      (_) => _distributeTick(TimerType.spiral),
    );

    _isRunning = true;
    _isPaused = false;
    notifyListeners();
  }

  /// Pause all timers (when app goes to background)
  void pauseAll() {
    if (!_isRunning || _isPaused) return;

    _cancelAll();
    _isPaused = true;
    notifyListeners();
  }

  /// Resume all timers (when app returns to foreground)
  void resumeAll() {
    if (!_isPaused) return;

    startAll();
    _isPaused = false;
    notifyListeners();
  }

  /// Stop all timers
  void stopAll() {
    _cancelAll();
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  /// Start a one-time town heal timer
  Timer startTownHealTimer(Duration interval, void Function() callback) {
    _townHealTimer?.cancel();
    _townHealTimer = Timer.periodic(interval, (_) => callback());
    return _townHealTimer!;
  }

  /// Stop town heal timer
  void stopTownHealTimer() {
    _townHealTimer?.cancel();
    _townHealTimer = null;
  }

  void _distributeTick(TimerType type) {
    final callbacks = _tickCallbacks[type];
    if (callbacks != null) {
      for (final callback in callbacks) {
        callback();
      }
    }
  }

  void _cancelAll() {
    _gameTimer?.cancel();
    _focusTimer?.cancel();
    _saveTimer?.cancel();
    _combatTimer?.cancel();
    _skillTreeTimer?.cancel();
    _guildHallTimer?.cancel();
    _enchantingTimer?.cancel();
    _professionTimer?.cancel();
    _bossRiftTimer?.cancel();
    _equipmentSetTimer?.cancel();
    _transmutationTimer?.cancel();
    _alchemyTimer?.cancel();
    _legendaryTimer?.cancel();
    _spiralTimer?.cancel();
    _townHealTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }
}

/// Types of game timers
enum TimerType {
  game,
  focus,
  save,
  combat,
  skillTree,
  guildHall,
  profession,
  bossRift,
  equipmentSet,
  transmutation,
  alchemy,
  legendary,
  spiral,
  enchanting,
}
