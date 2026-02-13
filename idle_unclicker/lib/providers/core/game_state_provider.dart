import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../models/game_state.dart';
import '../../models/combat_log.dart';

/// Manages game state, progression, and persistence
///
/// This provider handles:
/// - Focus and zen streak mechanics
/// - Ascension and meta-progression
/// - Combat logging
/// - Offline progress calculation
/// - App lifecycle state
class GameStateProvider extends ChangeNotifier {
  final Box<GameState> _gameStateBox;
  final Box<CombatLog> _combatLogBox;

  GameState? _gameState;
  CombatLog? _combatLog;

  // Pending log entries batching
  final List<String> _pendingLogEntries = [];
  Timer? _logFlushTimer;

  // App state
  bool _isInApp = true;

  // Ascension state
  bool _ascensionAvailable = false;
  int _pendingEchoShards = 0;

  GameStateProvider(this._gameStateBox, this._combatLogBox);

  // ============ Getters ============

  GameState? get gameState => _gameState;
  CombatLog? get combatLog => _combatLog;

  // Focus
  double get focusPercentage => _gameState?.focusPercentage ?? 0.0;
  double get effectiveMultiplier => _gameState?.effectiveMultiplier ?? 1.0;
  int get zenStreakDays => _gameState?.zenStreakDays ?? 0;
  bool get isZenStreakActive => (_gameState?.zenStreakDays ?? 0) > 0;

  // Ascension
  int get totalAscensions => _gameState?.totalAscensions ?? 0;
  int get echoShards => _gameState?.echoShards ?? 0;
  bool get ascensionAvailable => _ascensionAvailable;
  int get pendingEchoShards => _pendingEchoShards;

  // Stats
  int get totalClicks => _gameState?.totalClicks ?? 0;
  int get totalTimeInApp => _gameState?.totalTimeInAppSeconds ?? 0;
  int get totalTimeAway => _gameState?.totalTimeAwaySeconds ?? 0;

  // App state
  bool get isInApp => _isInApp;

  // Combat log
  List<String> get recentCombatEntries => _combatLog?.recentEntries ?? [];
  List<String> get allCombatEntries => _combatLog?.entries ?? [];

  // ============ Loading ============

  Future<void> loadGameState() async {
    _gameState = _gameStateBox.get('state');
    _combatLog = _combatLogBox.get('log');

    if (_gameState == null) {
      _gameState = GameState.create();
      await _gameStateBox.put('state', _gameState!);
    }

    if (_combatLog == null) {
      _combatLog = CombatLog();
      await _combatLogBox.put('log', _combatLog!);
    }

    // Start log flush timer
    _startLogFlushTimer();

    notifyListeners();
  }

  void _startLogFlushTimer() {
    _logFlushTimer?.cancel();
    _logFlushTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _flushLogs(),
    );
  }

  // ============ Focus Mechanics ============

  void recordInteraction() {
    _gameState?.recordInteraction();
    notifyListeners();
  }

  void updateFocus(int idleMinutes, int focusSeconds) {
    _gameState?.updateFocus(idleMinutes, focusSeconds);
    notifyListeners();
  }

  void checkZenStreak() {
    _gameState?.checkZenStreak();
    notifyListeners();
  }

  // ============ Ascension ============

  void calculateAscension(
    int characterLevel,
    double characterExp,
    int totalDeaths,
  ) {
    _pendingEchoShards =
        _gameState?.calculateEchoShards(
          characterExp,
          characterLevel,
          totalDeaths,
        ) ??
        0;

    _ascensionAvailable = _pendingEchoShards >= 10;
    notifyListeners();
  }

  Future<void> performAscension() async {
    if (_gameState == null) return;

    _gameState!.ascend(
      0, // Experience reset
      0, // Level reset
      0, // Deaths don't matter after ascension
    );

    _ascensionAvailable = false;
    _pendingEchoShards = 0;

    await _save();
    notifyListeners();
  }

  void clearAscension() {
    _ascensionAvailable = false;
    _pendingEchoShards = 0;
    notifyListeners();
  }

  // ============ Meta Upgrades ============

  bool purchaseUpgrade(String type) {
    if (_gameState == null) return false;

    final success = _gameState!.purchaseUpgrade(type);
    if (success) {
      _save();
      notifyListeners();
    }
    return success;
  }

  Map<String, dynamic> getStartingBonuses() {
    return _gameState?.getStartingBonuses() ??
        {
          'hpMultiplier': 1.0,
          'bonusPotions': 0,
          'xpMultiplier': 1.0,
          'startingDepth': 1,
        };
  }

  // ============ Combat Logging ============

  void log(String message, {bool immediate = false}) {
    _pendingLogEntries.add(message);

    if (immediate) {
      _flushLogs();
    }

    // Don't notify listeners for log changes to avoid rebuild spam
    // The log display will refresh on its own timer
  }

  void _flushLogs() {
    if (_pendingLogEntries.isEmpty) return;
    if (_combatLog == null) return;

    for (final entry in _pendingLogEntries) {
      _combatLog!.addEntry(entry);
    }
    _pendingLogEntries.clear();

    // Save periodically but don't notify
    if (_combatLog!.entries.length % 10 == 0) {
      _combatLog!.save();
    }
  }

  void clearCombatLog() {
    _combatLog?.clear();
    _combatLog?.save();
    notifyListeners();
  }

  // ============ App Lifecycle ============

  void onAppPause() {
    _isInApp = false;
    _flushLogs();
    _save();
  }

  Future<void> onAppResume() async {
    _isInApp = true;
    // Offline progress calculated by GameProvider
    notifyListeners();
  }

  // ============ Persistence ============

  Future<void> save() async {
    await _save();
  }

  Future<void> _save() async {
    _flushLogs();
    await _gameState?.save();
    await _combatLog?.save();
  }

  Future<void> flushAndSave() async {
    await _save();
  }

  // ============ Utility ============

  void incrementTotalClicks() {
    _gameState?.recordInteraction();
  }

  @override
  void dispose() {
    _logFlushTimer?.cancel();
    _flushLogs();
    super.dispose();
  }
}
