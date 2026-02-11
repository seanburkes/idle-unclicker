import 'package:hive/hive.dart';

part 'equipment.g.dart';

@HiveType(typeId: 2)
class Equipment extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String slot;

  @HiveField(2)
  int attackBonus;

  @HiveField(3)
  int defenseBonus;

  @HiveField(4)
  int healthBonus;

  @HiveField(5)
  int manaBonus;

  @HiveField(6)
  int level;

  @HiveField(7)
  int rarity;

  Equipment({
    required this.name,
    required this.slot,
    this.attackBonus = 0,
    this.defenseBonus = 0,
    this.healthBonus = 0,
    this.manaBonus = 0,
    this.level = 1,
    this.rarity = 1,
  });

  factory Equipment.empty(String slot) {
    return Equipment(name: 'None', slot: slot, level: 0);
  }

  /// Get the number of sockets based on rarity tier
  /// Common=0, Uncommon=1, Rare=2, Epic=3, Legendary=4
  int get socketCount {
    // rarity 1 = common = 0 sockets
    // rarity 2 = uncommon = 1 socket
    // rarity 3 = rare = 2 sockets
    // rarity 4 = epic = 3 sockets
    // rarity 5 = legendary = 4 sockets
    return (rarity - 1).clamp(0, 4);
  }

  /// Check if this equipment is legendary (rarity 5)
  bool get isLegendary => rarity >= 5;

  /// Check if this equipment can be enchanted (must have rarity > 0)
  bool get canBeEnchanted => rarity > 0;
}

@HiveType(typeId: 3)
class Inventory extends HiveObject {
  @HiveField(0)
  List<Equipment> items;

  @HiveField(1)
  int gold;

  Inventory({this.items = const [], this.gold = 0});
}
