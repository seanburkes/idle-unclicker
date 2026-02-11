import 'package:hive/hive.dart';
import 'dart:math';
import 'character.dart';

part 'guild_hall.g.dart';

/// Room types in the Guild Hall
enum RoomType { trainingHall, treasury, library, smithy }

/// Room - A buildable room in the Guild Hall that provides bonuses
@HiveType(typeId: 9)
class Room extends HiveObject {
  @HiveField(0)
  String type;

  @HiveField(1)
  int level;

  @HiveField(2)
  int baseCost;

  Room({required this.type, this.level = 0, required this.baseCost});

  /// Get the cost to upgrade to the next level
  int get upgradeCost {
    if (level >= GuildHall.maxRoomLevel) return 0;
    return (baseCost * pow(1.5, level)).round();
  }

  /// Get the bonus percentage for this room
  double get bonusPercent {
    switch (type) {
      case 'trainingHall':
        return level * 0.01; // +1% skill XP per level
      case 'treasury':
        return level * 0.10; // +10% gold find per level
      case 'library':
        return level * 2.0; // 2x bestiary fill rate per level
      case 'smithy':
        return level * 0.05; // +5% better equipment drops per level
      default:
        return 0.0;
    }
  }

  /// Get a human-readable name for this room
  String get name {
    switch (type) {
      case 'trainingHall':
        return 'Training Hall';
      case 'treasury':
        return 'Treasury';
      case 'library':
        return 'Library';
      case 'smithy':
        return 'Smithy';
      default:
        return 'Unknown Room';
    }
  }

  /// Get a description of this room's bonus
  String get description {
    switch (type) {
      case 'trainingHall':
        return '+${(bonusPercent * 100).toStringAsFixed(0)}% Skill XP gain';
      case 'treasury':
        return '+${(bonusPercent * 100).toStringAsFixed(0)}% Gold find';
      case 'library':
        return '${bonusPercent.toStringAsFixed(0)}x Bestiary fill rate';
      case 'smithy':
        return '+${(bonusPercent * 100).toStringAsFixed(0)}% Better equipment drops';
      default:
        return 'No bonus';
    }
  }

  /// Get an icon for this room
  String get icon {
    switch (type) {
      case 'trainingHall':
        return '🏋️';
      case 'treasury':
        return '💰';
      case 'library':
        return '📚';
      case 'smithy':
        return '⚒️';
      default:
        return '🏛️';
    }
  }

  /// Upgrade this room
  void upgrade() {
    if (level < GuildHall.maxRoomLevel) {
      level++;
    }
  }

  /// Check if room is at max level
  bool get isMaxLevel => level >= GuildHall.maxRoomLevel;
}

/// EchoNPC - A wandering echo of a previous ascended character
@HiveType(typeId: 10)
class EchoNPC extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String race;

  @HiveField(2)
  String characterClass;

  @HiveField(3)
  int level;

  @HiveField(4)
  String fate; // How they died/ascended

  @HiveField(5)
  double positionX; // Wandering position (0.0 to 1.0)

  @HiveField(6)
  double positionY; // Wandering position (0.0 to 1.0)

  @HiveField(7)
  DateTime createdAt;

  EchoNPC({
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.fate,
    this.positionX = 0.5,
    this.positionY = 0.5,
    required this.createdAt,
  });

  /// Create an EchoNPC from a character that ascended/died
  factory EchoNPC.fromCharacter(Character character, {required String fate}) {
    final random = Random();
    return EchoNPC(
      name: character.name,
      race: character.race,
      characterClass: character.characterClass,
      level: character.level,
      fate: fate,
      positionX: random.nextDouble(),
      positionY: random.nextDouble(),
      createdAt: DateTime.now(),
    );
  }

  /// Get a display string for this echo
  String get displayTitle => '$name the $race $characterClass (Lv.$level)';

  /// Get a color based on character class
  String get classColor {
    switch (characterClass.toLowerCase()) {
      case 'warrior':
        return '#FF4444';
      case 'rogue':
        return '#44FF44';
      case 'mage':
        return '#4444FF';
      case 'ranger':
        return '#FFAA00';
      case 'cleric':
        return '#FFFFFF';
      default:
        return '#AAAAAA';
    }
  }

  /// Wandering behavior - subtly move around
  void wander() {
    final random = Random();
    positionX += (random.nextDouble() - 0.5) * 0.1;
    positionY += (random.nextDouble() - 0.5) * 0.1;

    // Keep within bounds
    positionX = positionX.clamp(0.1, 0.9);
    positionY = positionY.clamp(0.1, 0.9);
  }
}

/// GuildHall - The meta-progression hub that unlocks after first ascension
@HiveType(typeId: 11)
class GuildHall extends HiveObject {
  static const int maxRoomLevel = 10;

  // Room base costs
  static const int trainingHallBaseCost = 1000;
  static const int treasuryBaseCost = 1500;
  static const int libraryBaseCost = 2000;
  static const int smithyBaseCost = 2500;

  @HiveField(0)
  List<Room> rooms;

  @HiveField(1)
  List<EchoNPC> echoes;

  @HiveField(2)
  bool isUnlocked;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  int totalGoldInvested;

  @HiveField(5)
  String playstylePreference; // 'aggressive', 'defensive', 'loot', 'balanced'

  GuildHall({
    required this.rooms,
    required this.echoes,
    this.isUnlocked = false,
    required this.createdAt,
    this.totalGoldInvested = 0,
    this.playstylePreference = 'balanced',
  });

  /// Create a new Guild Hall (locked until first ascension)
  factory GuildHall.create() {
    return GuildHall(
      rooms: [
        Room(type: 'trainingHall', level: 0, baseCost: trainingHallBaseCost),
        Room(type: 'treasury', level: 0, baseCost: treasuryBaseCost),
        Room(type: 'library', level: 0, baseCost: libraryBaseCost),
        Room(type: 'smithy', level: 0, baseCost: smithyBaseCost),
      ],
      echoes: [],
      isUnlocked: false,
      createdAt: DateTime.now(),
      totalGoldInvested: 0,
      playstylePreference: 'balanced',
    );
  }

  /// Unlock the Guild Hall after first ascension
  void unlock() {
    isUnlocked = true;
  }

  /// Get a room by type
  Room? getRoom(String type) {
    try {
      return rooms.firstWhere((room) => room.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Get total bonuses from all rooms
  Map<String, double> getTotalBonuses() {
    double skillXpMultiplier = 1.0;
    double goldFindMultiplier = 1.0;
    double bestiaryRateMultiplier = 1.0;
    double equipmentDropMultiplier = 1.0;

    for (final room in rooms) {
      switch (room.type) {
        case 'trainingHall':
          skillXpMultiplier += room.bonusPercent;
          break;
        case 'treasury':
          goldFindMultiplier += room.bonusPercent;
          break;
        case 'library':
          bestiaryRateMultiplier += room.bonusPercent;
          break;
        case 'smithy':
          equipmentDropMultiplier += room.bonusPercent;
          break;
      }
    }

    return {
      'skillXpMultiplier': skillXpMultiplier,
      'goldFindMultiplier': goldFindMultiplier,
      'bestiaryRateMultiplier': bestiaryRateMultiplier,
      'equipmentDropMultiplier': equipmentDropMultiplier,
    };
  }

  /// Get total room levels (for display)
  int get totalRoomLevels => rooms.fold(0, (sum, room) => sum + room.level);

  /// Get the highest level room
  Room? get highestLevelRoom {
    if (rooms.isEmpty) return null;
    return rooms.reduce((a, b) => a.level > b.level ? a : b);
  }

  /// Add an echo from an ascended character
  void addEcho(Character character, {required String fate}) {
    final echo = EchoNPC.fromCharacter(character, fate: fate);
    echoes.add(echo);

    // Keep only the most recent 20 echoes
    if (echoes.length > 20) {
      echoes = echoes.sublist(echoes.length - 20);
    }
  }

  /// Get the 3-4 most recent echoes that should be displayed wandering
  List<EchoNPC> get wanderingEchoes {
    if (echoes.isEmpty) return [];
    return echoes.reversed.take(4).toList();
  }

  /// Update wandering positions for all echoes
  void updateEchoPositions() {
    for (final echo in echoes) {
      echo.wander();
    }
  }

  /// Get the cost to upgrade a specific room
  int getRoomUpgradeCost(String roomType) {
    final room = getRoom(roomType);
    return room?.upgradeCost ?? 0;
  }

  /// Check if a room can be upgraded
  bool canUpgradeRoom(String roomType, int availableGold) {
    final room = getRoom(roomType);
    if (room == null) return false;
    if (room.isMaxLevel) return false;
    return availableGold >= room.upgradeCost;
  }

  /// Upgrade a room and return the cost (0 if failed)
  int upgradeRoom(String roomType) {
    final room = getRoom(roomType);
    if (room == null || room.isMaxLevel) return 0;

    final cost = room.upgradeCost;
    room.upgrade();
    totalGoldInvested += cost;
    return cost;
  }

  /// Get the next room to upgrade based on playstyle (for automation)
  String? getNextUpgradeForPlaystyle(String playstyle) {
    final availableRooms = rooms.where((r) => !r.isMaxLevel).toList();
    if (availableRooms.isEmpty) return null;

    switch (playstyle.toLowerCase()) {
      case 'aggressive':
        // Prioritize training hall (more damage/skills)
        final training = getRoom('trainingHall');
        if (training != null && !training.isMaxLevel) return 'trainingHall';
        // Fall back to smithy for better weapons
        final smithy = getRoom('smithy');
        if (smithy != null && !smithy.isMaxLevel) return 'smithy';
        break;
      case 'defensive':
        // Prioritize smithy for better armor/survival
        final smithy = getRoom('smithy');
        if (smithy != null && !smithy.isMaxLevel) return 'smithy';
        // Fall back to training for HP bonuses
        final training = getRoom('trainingHall');
        if (training != null && !training.isMaxLevel) return 'trainingHall';
        break;
      case 'loot':
        // Prioritize treasury for gold
        final treasury = getRoom('treasury');
        if (treasury != null && !treasury.isMaxLevel) return 'treasury';
        // Fall back to library for more knowledge
        final library = getRoom('library');
        if (library != null && !library.isMaxLevel) return 'library';
        break;
    }

    // Default: upgrade the lowest level room
    availableRooms.sort((a, b) => a.level.compareTo(b.level));
    return availableRooms.first.type;
  }

  /// Check if all rooms are maxed out
  bool get isFullyUpgraded => rooms.every((room) => room.isMaxLevel);

  /// Get a summary of the guild hall
  Map<String, dynamic> getSummary() {
    final bonuses = getTotalBonuses();
    return {
      'totalLevels': totalRoomLevels,
      'maxLevels': rooms.length * maxRoomLevel,
      'echoCount': echoes.length,
      'totalInvested': totalGoldInvested,
      'skillXpMultiplier': bonuses['skillXpMultiplier'],
      'goldFindMultiplier': bonuses['goldFindMultiplier'],
      'bestiaryRateMultiplier': bonuses['bestiaryRateMultiplier'],
      'equipmentDropMultiplier': bonuses['equipmentDropMultiplier'],
    };
  }
}
