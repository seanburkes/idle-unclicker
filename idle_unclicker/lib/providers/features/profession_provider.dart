import 'package:flutter/foundation.dart';
import '../../models/professions.dart';
import '../../services/profession_service.dart';

/// Manages professions and crafting
///
/// This provider handles:
/// - Profession levels and XP
/// - Material gathering
/// - Crafting recipes
/// - Auto-crafting
class ProfessionProvider extends ChangeNotifier {
  final ProfessionService? _professionService;

  ProfessionProvider({ProfessionService? professionService})
    : _professionService = professionService;

  // ============ Getters ============

  ProfessionState? get professionState => _professionService?.state;
  List<Profession> get professions =>
      _professionService?.state.professions ?? [];

  Map<MaterialType, int> get inventory =>
      _professionService?.state.inventory ?? {};

  List<String> get recentGatherLog =>
      _professionService?.state.recentGatherLog ?? [];

  int get totalCraftsCompleted =>
      _professionService?.state.totalCraftsCompleted ?? 0;

  int get astralMaterialCount =>
      _professionService?.state.astralMaterialCount ?? 0;

  int get inventoryValue => _professionService?.state.inventoryValue ?? 0;

  bool get autoCraftEnabled => _professionService?.autoCraftEnabled ?? true;

  // ============ Profession Management ============

  void toggleAutoCraft() {
    _professionService?.toggleAutoCraft();
    notifyListeners();
  }

  // ============ Crafting ============

  CraftResult craftItem(CraftedItemType itemType) {
    if (_professionService == null) {
      return CraftResult.failure('Profession service not available');
    }
    final result = _professionService!.craft(itemType);
    _professionService!.state.save();
    notifyListeners();
    return result;
  }

  bool canCraftItem(CraftedItemType itemType) {
    return _professionService?.canCraft(itemType) ?? false;
  }

  List<CraftingRecipe> get craftableRecipes =>
      _professionService?.getCraftableRecipes() ?? [];

  // ============ Gathering ============

  List<MaterialGatheredEvent> gatherMaterials({
    required ProfessionType professionType,
    required String monsterType,
    required bool isFocusMode,
    required int dungeonDepth,
  }) {
    if (_professionService == null) return [];

    final events = _professionService!.gatherMaterials(
      professionType: professionType,
      monsterType: monsterType,
      isFocusMode: isFocusMode,
      dungeonDepth: dungeonDepth,
    );

    if (events.isNotEmpty) {
      _professionService!.state.save();
      notifyListeners();
    }

    return events;
  }

  // ============ Automation ============

  List<String> processAutoCraft(dynamic character) {
    if (_professionService == null) return [];

    final actions = _professionService!.executeAutoCraft(character);

    if (actions.isNotEmpty) {
      _professionService!.state.save();
      notifyListeners();
    }

    return actions;
  }

  void save() {
    _professionService?.state.save();
  }
}
