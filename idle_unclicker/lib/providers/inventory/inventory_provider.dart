import 'package:flutter/foundation.dart';
import '../../models/character.dart';
import '../../models/enchanting.dart';
import '../../models/equipment_sets.dart';
import '../../models/legendary_items.dart';
import '../../services/enchanting_service.dart';
import '../../services/equipment_set_service.dart';
import '../../services/legendary_item_service.dart';

/// Manages inventory, equipment, and item systems
///
/// This provider handles:
/// - Equipment management
/// - Enchanted equipment
/// - Equipment sets
/// - Legendary items
class InventoryProvider extends ChangeNotifier {
  // Services
  final EnchantingService? _enchantingService;
  final EquipmentSetService? _equipmentSetService;
  final LegendaryItemService? _legendaryItemService;

  // State
  final List<EnchantedEquipment> _enchantedEquipment = [];
  final List<EquipmentSetItem> _setInventory = [];
  final List<EquipmentSetItem> _equippedSetItems = [];
  final List<LegendaryItem> _legendaryInventory = [];
  final List<LegendaryItem> _equippedLegendaries = [];

  InventoryProvider({
    EnchantingService? enchantingService,
    EquipmentSetService? equipmentSetService,
    LegendaryItemService? legendaryItemService,
  }) : _enchantingService = enchantingService,
       _equipmentSetService = equipmentSetService,
       _legendaryItemService = legendaryItemService;

  // ============ Getters ============

  List<EnchantedEquipment> get enchantedEquipment => _enchantedEquipment;
  List<EquipmentSetItem> get setInventory => _setInventory;
  List<EquipmentSetItem> get equippedSetItems => _equippedSetItems;
  List<LegendaryItem> get legendaryInventory => _legendaryInventory;
  List<LegendaryItem> get equippedLegendaries => _equippedLegendaries;

  EquipmentSetService? get equipmentSetService => _equipmentSetService;
  LegendaryItemService? get legendaryItemService => _legendaryItemService;
  EnchantingService? get enchantingService => _enchantingService;

  // ============ Enchanted Equipment ============

  void addEnchantedEquipment(EnchantedEquipment equipment) {
    _enchantedEquipment.add(equipment);
    _saveEnchantedEquipment();
    notifyListeners();
  }

  void removeEnchantedEquipment(EnchantedEquipment equipment) {
    _enchantedEquipment.remove(equipment);
    _saveEnchantedEquipment();
    notifyListeners();
  }

  bool socketGem(EnchantedEquipment equipment, int socketIndex, Gem gem) {
    if (_enchantingService == null) return false;
    final result = _enchantingService!.socketGem(equipment, socketIndex, gem);
    if (result) {
      _saveEnchantedEquipment();
      notifyListeners();
    }
    return result;
  }

  Gem? removeGem(EnchantedEquipment equipment, int socketIndex) {
    if (_enchantingService == null) return null;
    final gem = _enchantingService!.removeGem(equipment, socketIndex);
    if (gem != null) {
      _saveEnchantedEquipment();
      notifyListeners();
    }
    return gem;
  }

  EnchantmentResult enchantItem(EnchantedEquipment equipment) {
    if (_enchantingService == null) {
      return EnchantmentResult.failure('Enchanting service not available');
    }
    final result = _enchantingService!.enchant(equipment);
    _saveEnchantedEquipment();
    notifyListeners();
    return result;
  }

  String getEnchantmentRisk(EnchantedEquipment equipment) {
    if (_enchantingService == null) return '0%';
    return _enchantingService!.getRiskDisplay(equipment);
  }

  List<EnchantedEquipment> getEnchantableItems(bool isInTown) {
    if (_enchantingService == null) return [];
    return _enchantingService!.getEnchantableItems(
      _enchantedEquipment,
      isInTown: isInTown,
    );
  }

  Map<String, double> getTotalEnchantmentBonuses() {
    final total = <String, double>{};
    for (final equipment in _enchantedEquipment) {
      final bonuses = equipment.calculateTotalBonuses();
      bonuses.forEach((stat, value) {
        total[stat] = (total[stat] ?? 0) + value;
      });
    }
    return total;
  }

  // ============ Equipment Sets ============

  bool get showEquipmentSets =>
      (_equipmentSetService?.state.discoveredSets.isNotEmpty ?? false);

  List<EquipmentSet> get discoveredSets =>
      _equipmentSetService?.state.discoveredSets ?? [];

  Map<SetName, ActiveSet> get activeSets =>
      _equipmentSetService?.state.activeSets ?? {};

  SetSynergy? get currentSynergy => _equipmentSetService?.state.activeSynergy;

  double get totalCorruptionDrain =>
      _equipmentSetService?.state.totalCorruptionDrain ?? 0.0;

  bool get hasCorruptionEquipped =>
      _equipmentSetService?.state.hasCorruptionEquipped ?? false;

  List<SetBonus> get activeSetBonuses =>
      _equipmentSetService?.totalActiveBonuses ?? [];

  void addToSetInventory(EquipmentSetItem item) {
    _setInventory.add(item);
    _saveSetEquipment();
    notifyListeners();
  }

  void equipSetItem(EquipmentSetItem item) {
    // Remove from inventory
    _setInventory.removeWhere(
      (i) =>
          i.equipment.name == item.equipment.name &&
          i.equipment.slot == item.equipment.slot,
    );

    // Add to equipped (replacing any item in same slot)
    _equippedSetItems.removeWhere(
      (i) => i.equipment.slot == item.equipment.slot,
    );
    _equippedSetItems.add(item);

    _saveSetEquipment();
    _equipmentSetService?.state.save();
    notifyListeners();
  }

  void unequipSetItem(EquipmentSetItem item) {
    _equippedSetItems.removeWhere(
      (i) =>
          i.equipment.name == item.equipment.name &&
          i.equipment.slot == item.equipment.slot,
    );
    _setInventory.add(item);

    _saveSetEquipment();
    _equipmentSetService?.state.save();
    notifyListeners();
  }

  int getPiecesEquippedForSet(SetName setName) {
    return _equipmentSetService?.state.activeSets[setName]?.piecesEquipped ?? 0;
  }

  SetEvaluationResult evaluateSetItem(
    EquipmentSetItem newItem,
    EquipmentSetItem? currentItem,
    Character? character,
  ) {
    if (_equipmentSetService == null) {
      return SetEvaluationResult(
        shouldEquip: false,
        recommendation: 'Service unavailable',
        currentStatScore: 0.0,
        newStatScore: 0.0,
        setBonusValue: 0.0,
      );
    }
    return _equipmentSetService!.evaluateSetVsStats(
      newItem,
      currentItem,
      _equipmentSetService!.state,
      character,
    );
  }

  // ============ Legendary Items ============

  LegendaryCollection? get legendaryCollection =>
      _legendaryItemService?.collection;

  void addLegendaryItem(LegendaryItem item) {
    _legendaryInventory.add(item);
    _saveLegendaryEquipment();
    notifyListeners();
  }

  void equipLegendaryItem(LegendaryItem item) {
    _legendaryInventory.remove(item);
    _equippedLegendaries.add(item);
    _saveLegendaryEquipment();
    notifyListeners();
  }

  void unequipLegendaryItem(LegendaryItem item) {
    _equippedLegendaries.remove(item);
    _legendaryInventory.add(item);
    _saveLegendaryEquipment();
    notifyListeners();
  }

  // ============ Automation ============

  List<String> processAutoEquip(dynamic gameContext, Character character) {
    if (_equipmentSetService == null) return [];
    return _equipmentSetService!.executeAutoEquip(
      gameContext,
      _setInventory,
      _equippedSetItems,
    );
  }

  List<String> processAutoEnchant(
    Character character,
    String playstyle,
    bool isInTown,
  ) {
    if (_enchantingService == null) return [];
    return _enchantingService!.executeAutoEnchant(
      character,
      _enchantedEquipment,
      playstyle,
      isInTown: isInTown,
    );
  }

  // ============ Persistence ============

  Future<void> _saveEnchantedEquipment() async {
    // TODO: Implement persistence
  }

  Future<void> _saveSetEquipment() async {
    // TODO: Implement persistence
  }

  Future<void> _saveLegendaryEquipment() async {
    // TODO: Implement persistence
  }

  Future<void> loadEquipment() async {
    // TODO: Load from persistence
    notifyListeners();
  }
}
