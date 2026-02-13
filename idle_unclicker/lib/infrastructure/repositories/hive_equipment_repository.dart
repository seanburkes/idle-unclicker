import 'package:hive/hive.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/character_inventory.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/value_objects/equipment_enums.dart';

/// Hive implementation of EquipmentRepository
class HiveEquipmentRepository implements EquipmentRepository {
  static const String boxName = 'equipment';

  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(boxName);
    return _box!;
  }

  @override
  Future<Equipment?> findById(EquipmentId id) async {
    final b = await box;
    final data = b.get(id.value);
    if (data == null) return null;
    return _fromMap(id.value, data);
  }

  @override
  Future<void> save(Equipment equipment) async {
    final b = await box;
    final data = _toMap(equipment);
    await b.put(equipment.id.value, data);
    equipment.clearDomainEvents();
  }

  @override
  Future<void> delete(EquipmentId id) async {
    final b = await box;
    await b.delete(id.value);
  }

  @override
  Future<List<Equipment>> findByCharacterId(String characterId) async {
    final b = await box;
    final equipment = <Equipment>[];

    for (final entry in b.toMap().entries) {
      final data = entry.value;
      if (data['characterId'] == characterId) {
        equipment.add(_fromMap(entry.key, data));
      }
    }

    return equipment;
  }

  @override
  Future<Map<EquipmentSlot, Equipment>> findEquippedByCharacterId(
    String characterId,
  ) async {
    final all = await findByCharacterId(characterId);
    final equipped = <EquipmentSlot, Equipment>{};

    for (final item in all) {
      if (item.isEquipped && item.equippedByCharacterId == characterId) {
        equipped[item.slot] = item;
      }
    }

    return equipped;
  }

  @override
  Future<List<Equipment>> findInventoryByCharacterId(String characterId) async {
    final all = await findByCharacterId(characterId);
    return all.where((e) => !e.isEquipped).toList();
  }

  // === Mapping Methods ===

  Equipment _fromMap(String id, Map<dynamic, dynamic> data) {
    return Equipment(
      id: EquipmentId(id),
      name: data['name'] ?? 'Unknown',
      slot: EquipmentSlot.values.byName(data['slot'] ?? 'chest'),
      rarity: EquipmentRarity.values.byName(data['rarity'] ?? 'common'),
      itemLevel: data['itemLevel'] ?? 1,
      baseStats: EquipmentStats(
        attack: data['attack'] ?? 0,
        defense: data['defense'] ?? 0,
        health: data['health'] ?? 0,
        mana: data['mana'] ?? 0,
      ),
      sockets: _socketsFromList(data['sockets'] ?? []),
      isEquipped: data['isEquipped'] ?? false,
      equippedByCharacterId: data['equippedByCharacterId'],
    );
  }

  Map<String, dynamic> _toMap(Equipment equipment) {
    return {
      'name': equipment.name,
      'slot': equipment.slot.name,
      'rarity': equipment.rarity.name,
      'itemLevel': equipment.itemLevel,
      'attack': equipment.baseStats.attack,
      'defense': equipment.baseStats.defense,
      'health': equipment.baseStats.health,
      'mana': equipment.baseStats.mana,
      'sockets': _socketsToList(equipment.sockets),
      'isEquipped': equipment.isEquipped,
      'equippedByCharacterId': equipment.equippedByCharacterId,
    };
  }

  List<GemSocket> _socketsFromList(List<dynamic> list) {
    return list.map((s) {
      if (s['isFilled'] == true && s['gem'] != null) {
        final gemData = s['gem'];
        return GemSocket.filled(
          Gem(
            name: gemData['name'],
            type: GemType.values.byName(gemData['type']),
            tier: gemData['tier'],
          ),
        );
      }
      return GemSocket.empty();
    }).toList();
  }

  List<Map<String, dynamic>> _socketsToList(List<GemSocket> sockets) {
    return sockets.map((s) {
      if (s.isFilled && s.gem != null) {
        return {
          'isFilled': true,
          'gem': {
            'name': s.gem!.name,
            'type': s.gem!.type.name,
            'tier': s.gem!.tier,
          },
        };
      }
      return {'isFilled': false};
    }).toList();
  }
}

/// Hive implementation of CharacterInventoryRepository
class HiveCharacterInventoryRepository implements CharacterInventoryRepository {
  static const String boxName = 'character_inventories';
  final EquipmentRepository _equipmentRepository;

  Box<Map>? _box;

  HiveCharacterInventoryRepository(this._equipmentRepository);

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(boxName);
    return _box!;
  }

  @override
  Future<CharacterInventory?> findByCharacterId(String characterId) async {
    final b = await box;
    final data = b.get(characterId);
    if (data == null) return null;
    return _fromMap(characterId, data);
  }

  @override
  Future<void> save(CharacterInventory inventory) async {
    final b = await box;
    final data = _toMap(inventory);
    await b.put(inventory.characterId, data);
    inventory.clearDomainEvents();
  }

  @override
  Future<void> delete(String characterId) async {
    final b = await box;
    await b.delete(characterId);
  }

  @override
  Future<bool> exists(String characterId) async {
    final b = await box;
    return b.containsKey(characterId);
  }

  // === Mapping Methods ===

  CharacterInventory _fromMap(String characterId, Map<dynamic, dynamic> data) {
    return CharacterInventory(
      characterId: characterId,
      gold: data['gold'] ?? 0,
    );
  }

  Map<String, dynamic> _toMap(CharacterInventory inventory) {
    return {
      'gold': inventory.gold,
      'equippedCount': inventory.equippedCount,
      'inventoryCount': inventory.inventoryCount,
    };
  }
}
