import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../models/skill_tree.dart';

/// Manages skill tree progression and unlocks
///
/// This provider handles:
/// - Skill node unlocks
/// - Playstyle detection
/// - Bonus calculations
/// - Progress tracking
class SkillTreeProvider extends ChangeNotifier {
  final Box<SkillTree> _skillTreeBox;

  SkillTree? _skillTree;

  SkillTreeProvider(this._skillTreeBox);

  // ============ Getters ============

  SkillTree? get skillTree => _skillTree;
  bool get hasSkillTree => _skillTree != null;

  double get unlockProgress => _skillTree?.unlockProgress ?? 0.0;
  String get playstyle => _skillTree?.playstyle ?? 'balanced';

  List<SkillNode> get unlockedNodes => _skillTree?.getUnlockedNodes() ?? [];
  List<SkillNode> get availableNodes => _skillTree?.getAvailableNodes() ?? [];

  Map<String, double> get totalBonuses => _skillTree?.getTotalBonuses() ?? {};

  // ============ Loading ============

  Future<void> loadSkillTree() async {
    _skillTree = _skillTreeBox.get('tree');

    if (_skillTree == null) {
      _skillTree = SkillTree.create();
      await _skillTreeBox.put('tree', _skillTree!);
    }

    notifyListeners();
  }

  // ============ Progression ============

  void updateProgress(int minutes) {
    _skillTree?.updateProgress(minutes);
    _skillTree?.save();
    notifyListeners();
  }

  // ============ Tracking ============

  void recordKill() {
    _skillTree?.recordKill();
    _skillTree?.save();
    notifyListeners();
  }

  void recordGold(int amount) {
    _skillTree?.recordGold(amount);
    _skillTree?.save();
    notifyListeners();
  }

  void recordFlee() {
    _skillTree?.recordFlee();
    _skillTree?.save();
    notifyListeners();
  }

  // ============ Bonuses ============

  double getXPMultiplier() {
    final bonuses = totalBonuses;
    return bonuses['xpMultiplier'] ?? 1.0;
  }

  double getGoldMultiplier() {
    final bonuses = totalBonuses;
    return bonuses['goldMultiplier'] ?? 1.0;
  }

  double getDamageMultiplier() {
    final bonuses = totalBonuses;
    return bonuses['damageMultiplier'] ?? 1.0;
  }

  double getDefenseMultiplier() {
    final bonuses = totalBonuses;
    return bonuses['defenseMultiplier'] ?? 1.0;
  }

  // ============ Utility ============

  void save() {
    _skillTree?.save();
  }
}
