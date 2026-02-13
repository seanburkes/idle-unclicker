import '../entities/equipment.dart';
import '../entities/character_inventory.dart';
import '../value_objects/equipment_enums.dart';

/// Repository interface for Equipment aggregate
abstract class EquipmentRepository {
  /// Finds equipment by its unique ID
  Future<Equipment?> findById(EquipmentId id);

  /// Saves equipment (create or update)
  Future<void> save(Equipment equipment);

  /// Deletes equipment permanently
  Future<void> delete(EquipmentId id);

  /// Finds all equipment for a character (both equipped and inventory)
  Future<List<Equipment>> findByCharacterId(String characterId);

  /// Finds equipped items for a character
  Future<Map<EquipmentSlot, Equipment>> findEquippedByCharacterId(
    String characterId,
  );

  /// Finds inventory items for a character
  Future<List<Equipment>> findInventoryByCharacterId(String characterId);
}

/// Repository interface for CharacterInventory aggregate
abstract class CharacterInventoryRepository {
  /// Finds inventory by character ID
  Future<CharacterInventory?> findByCharacterId(String characterId);

  /// Saves inventory (create or update)
  Future<void> save(CharacterInventory inventory);

  /// Deletes inventory for a character
  Future<void> delete(String characterId);

  /// Checks if character has inventory
  Future<bool> exists(String characterId);
}
