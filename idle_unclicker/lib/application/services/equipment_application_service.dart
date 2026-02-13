import '../../domain/entities/character.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/character_inventory.dart';
import '../../domain/services/equipment_service.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/character_repository.dart';
import '../../domain/value_objects/equipment_enums.dart';
import '../../domain/value_objects/character_identity.dart';

/// DTO for equipment operation results
class EquipmentOperationResult {
  final bool success;
  final String? errorMessage;
  final Equipment? equipment;
  final int? goldChange;
  final List<String> messages;

  EquipmentOperationResult({
    required this.success,
    this.errorMessage,
    this.equipment,
    this.goldChange,
    this.messages = const [],
  });

  factory EquipmentOperationResult.success({
    Equipment? equipment,
    int? goldChange,
    List<String> messages = const [],
  }) => EquipmentOperationResult(
    success: true,
    equipment: equipment,
    goldChange: goldChange,
    messages: messages,
  );

  factory EquipmentOperationResult.failure(String error) =>
      EquipmentOperationResult(success: false, errorMessage: error);
}

/// Application service for equipment use cases
class EquipmentApplicationService {
  final EquipmentRepository _equipmentRepository;
  final CharacterInventoryRepository _inventoryRepository;
  final CharacterRepository _characterRepository;
  final EquipmentService _equipmentService;

  EquipmentApplicationService({
    required EquipmentRepository equipmentRepository,
    required CharacterInventoryRepository inventoryRepository,
    required CharacterRepository characterRepository,
    required EquipmentService equipmentService,
  }) : _equipmentRepository = equipmentRepository,
       _inventoryRepository = inventoryRepository,
       _characterRepository = characterRepository,
       _equipmentService = equipmentService;

  /// Gets or creates inventory for a character
  Future<CharacterInventory> _getOrCreateInventory(String characterId) async {
    var inventory = await _inventoryRepository.findByCharacterId(characterId);
    if (inventory == null) {
      inventory = CharacterInventory.empty(characterId);
      await _inventoryRepository.save(inventory);
    }
    return inventory;
  }

  /// Equips an item from inventory
  Future<EquipmentOperationResult> equipItem(
    String characterId,
    EquipmentId equipmentId,
  ) async {
    try {
      final inventory = await _getOrCreateInventory(characterId);
      final equipment = await _equipmentRepository.findById(equipmentId);

      if (equipment == null) {
        return EquipmentOperationResult.failure('Equipment not found');
      }

      if (equipment.isEquipped) {
        return EquipmentOperationResult.failure('Item is already equipped');
      }

      // Unequip current item if present
      final currentItem = inventory.getEquippedItem(equipment.slot);

      inventory.equipItem(equipment);

      await _inventoryRepository.save(inventory);
      await _equipmentRepository.save(equipment);

      final messages = <String>['Equipped ${equipment.name}'];
      if (currentItem != null) {
        messages.add('${currentItem.name} moved to inventory');
      }

      return EquipmentOperationResult.success(
        equipment: equipment,
        messages: messages,
      );
    } catch (e) {
      return EquipmentOperationResult.failure('Failed to equip item: $e');
    }
  }

  /// Unequips an item to inventory
  Future<EquipmentOperationResult> unequipItem(
    String characterId,
    EquipmentSlot slot,
  ) async {
    try {
      final inventory = await _getOrCreateInventory(characterId);

      if (!inventory.equippedItems.containsKey(slot)) {
        return EquipmentOperationResult.failure(
          'No item equipped in this slot',
        );
      }

      inventory.unequipItem(slot);

      await _inventoryRepository.save(inventory);

      return EquipmentOperationResult.success(
        messages: ['Unequipped item from ${slot.displayName}'],
      );
    } catch (e) {
      return EquipmentOperationResult.failure('Failed to unequip item: $e');
    }
  }

  /// Sells an item from inventory
  Future<EquipmentOperationResult> sellItem(
    String characterId,
    EquipmentId equipmentId,
  ) async {
    try {
      final character = await _characterRepository.findById(
        CharacterId(characterId),
      );
      if (character == null) {
        return EquipmentOperationResult.failure('Character not found');
      }

      final inventory = await _getOrCreateInventory(characterId);
      final equipment = await _equipmentRepository.findById(equipmentId);

      if (equipment == null) {
        return EquipmentOperationResult.failure('Equipment not found');
      }

      if (equipment.isEquipped) {
        return EquipmentOperationResult.failure('Cannot sell equipped item');
      }

      final sellPrice = inventory.sellItem(equipment);
      character.gold += sellPrice;

      await _inventoryRepository.save(inventory);
      await _characterRepository.save(character);
      await _equipmentRepository.delete(equipmentId);

      return EquipmentOperationResult.success(
        goldChange: sellPrice,
        messages: ['Sold ${equipment.name} for $sellPrice gold'],
      );
    } catch (e) {
      return EquipmentOperationResult.failure('Failed to sell item: $e');
    }
  }

  /// Auto-equips best items from inventory
  Future<EquipmentOperationResult> autoEquip(String characterId) async {
    try {
      final inventory = await _getOrCreateInventory(characterId);

      if (inventory.inventoryItems.isEmpty) {
        return EquipmentOperationResult.success(
          messages: ['No items in inventory to equip'],
        );
      }

      final equipped = inventory.autoEquip();

      if (equipped.isEmpty) {
        return EquipmentOperationResult.success(
          messages: ['No upgrades found in inventory'],
        );
      }

      await _inventoryRepository.save(inventory);

      // Save all equipped items
      for (final item in equipped) {
        await _equipmentRepository.save(item);
      }

      return EquipmentOperationResult.success(
        messages: equipped.map((e) => 'Equipped ${e.name}').toList(),
      );
    } catch (e) {
      return EquipmentOperationResult.failure('Failed to auto-equip: $e');
    }
  }

  /// Inserts a gem into equipment
  Future<EquipmentOperationResult> insertGem(
    String characterId,
    EquipmentId equipmentId,
    int socketIndex,
    Gem gem,
  ) async {
    try {
      final equipment = await _equipmentRepository.findById(equipmentId);

      if (equipment == null) {
        return EquipmentOperationResult.failure('Equipment not found');
      }

      equipment.insertGem(socketIndex, gem);

      await _equipmentRepository.save(equipment);

      return EquipmentOperationResult.success(
        equipment: equipment,
        messages: ['Inserted ${gem.name} into ${equipment.name}'],
      );
    } catch (e) {
      return EquipmentOperationResult.failure('Failed to insert gem: $e');
    }
  }

  /// Removes a gem from equipment
  Future<EquipmentOperationResult> removeGem(
    String characterId,
    EquipmentId equipmentId,
    int socketIndex,
  ) async {
    try {
      final equipment = await _equipmentRepository.findById(equipmentId);

      if (equipment == null) {
        return EquipmentOperationResult.failure('Equipment not found');
      }

      final gem = equipment.removeGem(socketIndex);

      await _equipmentRepository.save(equipment);

      return EquipmentOperationResult.success(
        equipment: equipment,
        messages: ['Removed ${gem.name} from ${equipment.name}'],
      );
    } catch (e) {
      return EquipmentOperationResult.failure('Failed to remove gem: $e');
    }
  }

  /// Generates equipment from dungeon drop
  Future<EquipmentOperationResult> generateDungeonDrop(
    String characterId,
    int dungeonLevel, {
    double magicFind = 1.0,
  }) async {
    try {
      final inventory = await _getOrCreateInventory(characterId);

      final equipment = _equipmentService.generateEquipment(dungeonLevel);

      inventory.addToInventory(equipment);

      await _inventoryRepository.save(inventory);
      await _equipmentRepository.save(equipment);

      return EquipmentOperationResult.success(
        equipment: equipment,
        messages: ['Found ${equipment.name} (${equipment.rarity.displayName})'],
      );
    } catch (e) {
      return EquipmentOperationResult.failure('Failed to generate drop: $e');
    }
  }

  /// Gets inventory summary for a character
  Future<Map<String, dynamic>> getInventorySummary(String characterId) async {
    final inventory = await _getOrCreateInventory(characterId);

    return {
      'characterId': characterId,
      'equippedCount': inventory.equippedCount,
      'inventoryCount': inventory.inventoryCount,
      'gold': inventory.gold,
      'totalEquippedStats': {
        'attack': inventory.totalEquippedStats.attack,
        'defense': inventory.totalEquippedStats.defense,
        'health': inventory.totalEquippedStats.health,
        'mana': inventory.totalEquippedStats.mana,
      },
      'equippedItems': inventory.equippedItems.map(
        (slot, item) => MapEntry(slot.name, {
          'id': item.id.value,
          'name': item.name,
          'rarity': item.rarity.displayName,
        }),
      ),
    };
  }
}
