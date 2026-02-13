import 'package:flutter/foundation.dart';
import '../../models/boss_rush.dart';
import '../../services/boss_rift_service.dart';

/// Manages Boss Rush and Rift state
///
/// This provider handles:
/// - Boss generation and combat
/// - Essence inventory
/// - Daily rifts
/// - Boss history
class BossRushProvider extends ChangeNotifier {
  final BossRiftService? _bossRiftService;

  BossRushProvider({BossRiftService? bossRiftService})
    : _bossRiftService = bossRiftService;

  // ============ Getters ============

  BossRushState? get bossRushState => _bossRiftService?.state;
  Boss? get currentBoss => _bossRiftService?.currentBoss;
  Rift? get dailyRift => _bossRiftService?.dailyRift;

  Map<EssenceType, int> get essenceInventory =>
      _bossRiftService?.essenceInventory ?? {};
  int get totalEssences => _bossRiftService?.totalEssences ?? 0;
  List<Boss> get defeatedBosses => _bossRiftService?.defeatedBosses ?? [];
  List<Rift> get riftHistory => _bossRiftService?.riftHistory ?? [];

  bool get showBossRush =>
      (_bossRiftService?.state.totalBossesDefeated ?? 0) > 0;

  // ============ Boss Management ============

  Boss? generateBossForFloor(int floor) {
    return _bossRiftService?.generateBoss(floor);
  }

  void skipCurrentBoss() {
    _bossRiftService?.state.currentBoss = null;
    _bossRiftService?.state.save();
    notifyListeners();
  }

  // ============ Essences ============

  bool useEssences(EssenceType type, int amount) {
    final result = _bossRiftService?.useEssences(type, amount) ?? false;
    if (result) {
      _bossRiftService?.state.save();
      notifyListeners();
    }
    return result;
  }

  // ============ Rifts ============

  void attemptDailyRift() {
    final rift = _bossRiftService?.dailyRift;
    if (rift == null) return;

    // Rift combat implementation
    notifyListeners();
  }

  void generateDailyRift() {
    _bossRiftService?.generateDailyRift();
    notifyListeners();
  }

  // ============ Automation ============

  void processBossTick(int characterLevel, int dungeonDepth, bool inTown) {
    // Generate daily rift if needed
    _bossRiftService?.generateDailyRift();
  }

  void save() {
    _bossRiftService?.state.save();
  }
}
