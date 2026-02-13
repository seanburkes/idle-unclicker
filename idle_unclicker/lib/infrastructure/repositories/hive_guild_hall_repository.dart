import 'package:hive/hive.dart';
import '../../domain/entities/guild_hall.dart';
import '../../domain/repositories/meta_progression_repository.dart';
import '../../domain/value_objects/meta_progression.dart';

/// Hive implementation of GuildHallRepository
class HiveGuildHallRepository implements GuildHallRepository {
  static const String boxName = 'guild_halls';

  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(boxName);
    return _box!;
  }

  @override
  Future<GuildHall?> findByGameStateId(String gameStateId) async {
    final b = await box;
    final data = b.get(gameStateId);
    if (data == null) return null;
    return _fromMap(gameStateId, data);
  }

  @override
  Future<void> save(GuildHall guildHall) async {
    final b = await box;
    final data = _toMap(guildHall);
    await b.put(guildHall.gameStateId, data);
    guildHall.clearDomainEvents();
  }

  @override
  Future<bool> exists(String gameStateId) async {
    final b = await box;
    return b.containsKey(gameStateId);
  }

  // === Mapping Methods ===

  GuildHall _fromMap(String gameStateId, Map<dynamic, dynamic> data) {
    return GuildHall(
      gameStateId: gameStateId,
      rooms: _roomsFromList(data['rooms'] ?? []),
      echoes: _echoesFromList(data['echoes'] ?? []),
      isUnlocked: data['isUnlocked'] ?? false,
      totalGoldInvested: data['totalGoldInvested'] ?? 0,
      playstylePreference: data['playstylePreference'] ?? 'balanced',
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> _toMap(GuildHall guildHall) {
    return {
      'rooms': _roomsToList(guildHall.rooms),
      'echoes': _echoesToList(guildHall.echoes),
      'isUnlocked': guildHall.isUnlocked,
      'totalGoldInvested': guildHall.totalGoldInvested,
      'playstylePreference': guildHall.playstylePreference,
      'createdAt': guildHall.createdAt.toIso8601String(),
    };
  }

  List<Room> _roomsFromList(List<dynamic> list) {
    return list
        .map(
          (r) => Room(
            type: RoomType.values.byName(r['type']),
            level: r['level'] ?? 0,
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> _roomsToList(List<Room> rooms) {
    return rooms.map((r) => {'type': r.type.name, 'level': r.level}).toList();
  }

  List<EchoNPC> _echoesFromList(List<dynamic> list) {
    return list
        .map(
          (e) => EchoNPC(
            name: e['name'],
            race: e['race'],
            characterClass: e['characterClass'],
            level: e['level'],
            fate: e['fate'],
            createdAt: DateTime.parse(e['createdAt']),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> _echoesToList(List<EchoNPC> echoes) {
    return echoes
        .map(
          (e) => {
            'name': e.name,
            'race': e.race,
            'characterClass': e.characterClass,
            'level': e.level,
            'fate': e.fate,
            'createdAt': e.createdAt.toIso8601String(),
          },
        )
        .toList();
  }
}
