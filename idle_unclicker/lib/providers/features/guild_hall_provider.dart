import 'package:flutter/foundation.dart';
import '../../models/guild_hall.dart';
import '../../services/guild_hall_service.dart';

/// Manages Guild Hall state and upgrades
///
/// This provider handles:
/// - Guild Hall rooms and upgrades
/// - Echo NPCs
/// - Bonuses from Guild Hall
class GuildHallProvider extends ChangeNotifier {
  final GuildHallService? _guildHallService;

  GuildHallProvider({GuildHallService? guildHallService})
    : _guildHallService = guildHallService;

  // ============ Getters ============
  GuildHall? get guildHall => _guildHallService?.guildHall;
  bool get isUnlocked => _guildHallService?.isUnlocked ?? false;
  bool get shouldShow => _guildHallService?.shouldShow(0) ?? false;

  List<Room> get rooms => _guildHallService?.guildHall.rooms ?? [];
  List<EchoNPC> get wanderingEchoes =>
      _guildHallService?.guildHall.wanderingEchoes ?? [];

  Map<String, double> get bonuses => _guildHallService?.getBonuses() ?? {};

  // ============ Room Management ============

  bool canAffordUpgrade(String roomType, int gold) {
    return _guildHallService?.canAfford(roomType, gold) ?? false;
  }

  int upgradeRoom(String roomType) {
    if (_guildHallService == null) return 0;
    return _guildHallService!.buildRoom(roomType);
  }

  Room? getRoom(String roomType) {
    return _guildHallService?.getRoom(roomType);
  }

  // ============ Echoes ============

  void addEcho(dynamic character, {required String fate}) {
    _guildHallService?.addEcho(character, fate: fate);
    _guildHallService?.guildHall.save();
    notifyListeners();
  }

  // ============ Automation ============

  int processAutomation(int currentGold, String playstyle) {
    if (_guildHallService == null) return 0;

    final upgradeCost = _guildHallService!.executeAutomation(
      currentGold,
      playstyle,
    );

    if (upgradeCost > 0) {
      _guildHallService!.guildHall.save();
      notifyListeners();
    }

    return upgradeCost;
  }

  // ============ Updates ============

  void updateEchoPositions() {
    _guildHallService?.updateEchoPositions();
    notifyListeners();
  }

  void save() {
    _guildHallService?.guildHall.save();
  }
}
