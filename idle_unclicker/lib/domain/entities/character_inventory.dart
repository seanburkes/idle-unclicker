import 'aggregate_root.dart';
import 'equipment.dart';
import '../events/equipment_events.dart';
import '../value_objects/equipment_enums.dart';

/// Aggregate Root: CharacterInventory
///
/// Manages all equipment items for a character including:
/// - Equipped items by slot
/// - Unequipped items in inventory
/// - Equipment management operations
class CharacterInventory extends AggregateRoot {
  final String characterId;
  final Map<EquipmentSlot, Equipment> equippedItems;
  final List<Equipment> inventoryItems;
  int gold;

  CharacterInventory({
    required this.characterId,
    Map<EquipmentSlot, Equipment>? equippedItems,
    List<Equipment>? inventoryItems,
    this.gold = 0,
  }) : equippedItems = equippedItems ?? {},
       inventoryItems = inventoryItems ?? [];

  /// Factory to create empty inventory for new character
  factory CharacterInventory.empty(String characterId) {
    return CharacterInventory(characterId: characterId, gold: 0);
  }

  // === Domain Behaviors ===

  /// Equips an item from inventory to a slot
  /// Unequips current item if present
  void equipItem(Equipment item) {
    if (item.isEquipped) {
      throw StateError('Item is already equipped');
    }

    final slot = item.slot;

    // Unequip current item if any
    if (equippedItems.containsKey(slot)) {
      final currentItem = equippedItems[slot]!;
      _unequipToInventory(currentItem);
    }

    // Remove from inventory and equip
    inventoryItems.removeWhere((e) => e.id.value == item.id.value);
    item.equip(characterId);
    equippedItems[slot] = item;

    recordEvent(
      EquipmentEquipped(
        equipmentId: item.id.value,
        characterId: characterId,
        slot: slot.name,
        equipmentName: item.name,
      ),
    );
  }

  /// Unequips an item and returns it to inventory
  void unequipItem(EquipmentSlot slot) {
    if (!equippedItems.containsKey(slot)) {
      throw StateError('No item equipped in $slot');
    }

    final item = equippedItems.remove(slot)!;
    item.unequip();
    inventoryItems.add(item);

    recordEvent(
      EquipmentUnequipped(
        equipmentId: item.id.value,
        characterId: characterId,
        slot: slot.name,
      ),
    );
  }

  /// Adds equipment to inventory
  void addToInventory(Equipment item) {
    if (item.isEquipped) {
      throw StateError('Cannot add equipped item to inventory');
    }

    inventoryItems.add(item);

    recordEvent(
      EquipmentAddedToInventory(
        equipmentId: item.id.value,
        equipmentName: item.name,
        characterId: characterId,
      ),
    );
  }

  /// Removes equipment from inventory and sells it
  int sellItem(Equipment item) {
    if (item.isEquipped) {
      throw StateError('Cannot sell equipped item');
    }

    final removed = inventoryItems.remove(item);
    if (!removed) {
      throw StateError('Item not found in inventory');
    }

    final sellPrice = _calculateSellPrice(item);
    gold += sellPrice;

    recordEvent(
      EquipmentSold(
        equipmentId: item.id.value,
        equipmentName: item.name,
        sellPrice: sellPrice,
        characterId: characterId,
      ),
    );

    return sellPrice;
  }

  /// Sells multiple items at once
  int sellItems(List<Equipment> items) {
    var totalGold = 0;
    for (final item in items) {
      totalGold += sellItem(item);
    }
    return totalGold;
  }

  /// Moves equipped item to inventory without unequipping
  void moveEquippedToInventory(EquipmentSlot slot) {
    if (!equippedItems.containsKey(slot)) return;

    final item = equippedItems.remove(slot)!;
    item.unequip();
    inventoryItems.add(item);
  }

  /// Gets item equipped in a specific slot
  Equipment? getEquippedItem(EquipmentSlot slot) {
    return equippedItems[slot];
  }

  /// Gets all equipped items
  List<Equipment> get allEquippedItems => equippedItems.values.toList();

  /// Gets items suitable for auto-equip (better than current)
  List<Equipment> get upgradeableItems {
    final upgrades = <Equipment>[];

    for (final item in inventoryItems) {
      final currentItem = equippedItems[item.slot];
      if (currentItem == null || item.isBetterThan(currentItem)) {
        upgrades.add(item);
      }
    }

    return upgrades;
  }

  /// Auto-equips best items from inventory
  List<Equipment> autoEquip() {
    final equipped = <Equipment>[];

    for (final item in List<Equipment>.from(inventoryItems)) {
      final currentItem = equippedItems[item.slot];
      if (currentItem == null || item.isBetterThan(currentItem)) {
        equipItem(item);
        equipped.add(item);
      }
    }

    return equipped;
  }

  /// Gets total stats from all equipped items
  EquipmentStats get totalEquippedStats {
    var total = EquipmentStats.empty();
    for (final item in equippedItems.values) {
      total = total + item.totalStats;
    }
    return total;
  }

  /// Finds best item for a slot from inventory
  Equipment? findBestItemForSlot(EquipmentSlot slot) {
    final candidates = inventoryItems.where((e) => e.slot == slot).toList();
    if (candidates.isEmpty) return null;

    candidates.sort(
      (a, b) => b.totalStats.totalStats.compareTo(a.totalStats.totalStats),
    );
    return candidates.first;
  }

  /// Gets all items of a specific rarity
  List<Equipment> getItemsByRarity(EquipmentRarity rarity) {
    return inventoryItems.where((e) => e.rarity == rarity).toList();
  }

  /// Gets sellable items (non-equipped, low value)
  List<Equipment> getSellableItems() {
    return inventoryItems.where((item) {
      // Keep rare+ items
      if (item.rarity.index >= EquipmentRarity.rare.index) return false;
      // Keep high level items
      if (item.itemLevel >= 10) return false;
      return true;
    }).toList();
  }

  // === Properties ===

  int get equippedCount => equippedItems.length;
  int get inventoryCount => inventoryItems.length;
  int get totalItemCount => equippedCount + inventoryCount;
  bool get hasItems => totalItemCount > 0;
  bool get isEmpty => totalItemCount == 0;

  /// Gets items grouped by slot
  Map<EquipmentSlot, List<Equipment>> get itemsBySlot {
    final map = <EquipmentSlot, List<Equipment>>{};
    for (final slot in EquipmentSlot.values) {
      map[slot] = inventoryItems.where((e) => e.slot == slot).toList();
    }
    return map;
  }

  @override
  String toString() =>
      'CharacterInventory($characterId, $equippedCount equipped, $inventoryCount in bag, $gold gold)';

  // === Private Helpers ===

  void _unequipToInventory(Equipment item) {
    item.unequip();
    equippedItems.remove(item.slot);
    inventoryItems.add(item);
  }

  int _calculateSellPrice(Equipment item) {
    final basePrice = item.itemLevel * 10;
    final rarityMultiplier = item.rarity.starCount;
    return (basePrice * rarityMultiplier).toInt();
  }
}
