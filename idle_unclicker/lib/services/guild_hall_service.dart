import '../models/guild_hall.dart';
import '../models/character.dart';

/// Service for managing Guild Hall operations
class GuildHallService {
  final GuildHall _guildHall;

  GuildHallService(this._guildHall);

  /// Get the underlying GuildHall model
  GuildHall get guildHall => _guildHall;

  /// Check if Guild Hall is unlocked
  bool get isUnlocked => _guildHall.isUnlocked;

  /// Get all total bonuses as multipliers
  Map<String, double> getBonuses() {
    return _guildHall.getTotalBonuses();
  }

  /// Get specific bonus multipliers
  double getSkillXpMultiplier() {
    return getBonuses()['skillXpMultiplier'] ?? 1.0;
  }

  double getGoldFindMultiplier() {
    return getBonuses()['goldFindMultiplier'] ?? 1.0;
  }

  double getBestiaryRateMultiplier() {
    return getBonuses()['bestiaryRateMultiplier'] ?? 1.0;
  }

  double getEquipmentDropMultiplier() {
    return getBonuses()['equipmentDropMultiplier'] ?? 1.0;
  }

  /// Build/upgrade a room
  /// Returns the cost if successful, 0 if not
  int buildRoom(String roomType) {
    return _guildHall.upgradeRoom(roomType);
  }

  /// Check if a room can be afforded
  bool canAfford(String roomType, int availableGold) {
    return _guildHall.canUpgradeRoom(roomType, availableGold);
  }

  /// Get the upgrade cost for a room
  int getUpgradeCost(String roomType) {
    return _guildHall.getRoomUpgradeCost(roomType);
  }

  /// Get a specific room
  Room? getRoom(String roomType) {
    return _guildHall.getRoom(roomType);
  }

  /// Get all rooms
  List<Room> getAllRooms() {
    return _guildHall.rooms;
  }

  /// Add an Echo from an ascended character
  void addEcho(Character character, {String fate = 'Ascended to legend'}) {
    _guildHall.addEcho(character, fate: fate);
  }

  /// Get wandering echoes for display
  List<EchoNPC> getWanderingEchoes() {
    return _guildHall.wanderingEchoes;
  }

  /// Update echo positions (call periodically)
  void updateEchoPositions() {
    _guildHall.updateEchoPositions();
  }

  /// Get total room levels
  int get totalRoomLevels => _guildHall.totalRoomLevels;

  /// Get max possible room levels
  int get maxRoomLevels => _guildHall.rooms.length * GuildHall.maxRoomLevel;

  /// Check if all rooms are maxed
  bool get isFullyUpgraded => _guildHall.isFullyUpgraded;

  /// Get automation decision based on playstyle
  /// Returns the room type that should be upgraded next
  String? getAutomationDecision(String playstyle) {
    return _guildHall.getNextUpgradeForPlaystyle(playstyle);
  }

  /// Execute automation - attempt to upgrade based on playstyle
  /// Returns the cost of the upgrade (0 if no upgrade was made)
  int executeAutomation(int availableGold, String playstyle) {
    if (!_guildHall.isUnlocked) return 0;

    final nextRoom = getAutomationDecision(playstyle);
    if (nextRoom == null) return 0;

    if (canAfford(nextRoom, availableGold)) {
      return buildRoom(nextRoom);
    }

    return 0;
  }

  /// Check if any room can be afforded
  bool canAffordAnyRoom(int availableGold) {
    for (final room in _guildHall.rooms) {
      if (canAfford(room.type, availableGold)) {
        return true;
      }
    }
    return false;
  }

  /// Get the cheapest affordable room
  String? getCheapestAffordableRoom(int availableGold) {
    Room? cheapest;
    int cheapestCost = availableGold + 1;

    for (final room in _guildHall.rooms) {
      if (!room.isMaxLevel) {
        final cost = room.upgradeCost;
        if (cost <= availableGold && cost < cheapestCost) {
          cheapest = room;
          cheapestCost = cost;
        }
      }
    }

    return cheapest?.type;
  }

  /// Unlock the Guild Hall (called on first ascension)
  void unlock() {
    _guildHall.unlock();
  }

  /// Check if Guild Hall should be shown to player
  /// (feature enabled AND at least one ascension)
  bool shouldShow(int totalAscensions) {
    return _guildHall.isUnlocked || totalAscensions > 0;
  }

  /// Get summary information for display
  Map<String, dynamic> getSummary() {
    return _guildHall.getSummary();
  }

  /// Get total gold invested
  int get totalGoldInvested => _guildHall.totalGoldInvested;

  /// Get echo count
  int get echoCount => _guildHall.echoes.length;
}
