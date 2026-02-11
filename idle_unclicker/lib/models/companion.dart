import 'package:hive/hive.dart';
import 'dart:math';

part 'companion.g.dart';

/// Mercenary Companion - AI party member
@HiveType(typeId: 7)
class Companion extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String role; // 'tank', 'healer', 'dps', 'scout'

  @HiveField(2)
  int level;

  @HiveField(3)
  int experience;

  @HiveField(4)
  int maxHealth;

  @HiveField(5)
  int currentHealth;

  @HiveField(6)
  int attack;

  @HiveField(7)
  int defense;

  @HiveField(8)
  double loyalty; // 0.0 to 1.0

  @HiveField(9)
  int totalCombats;

  @HiveField(10)
  int fleesWitnessed;

  @HiveField(11)
  int kills;

  @HiveField(12)
  bool isActive;

  @HiveField(13)
  String? weaponType;

  @HiveField(14)
  String? armorType;

  Companion({
    required this.name,
    required this.role,
    this.level = 1,
    this.experience = 0,
    required this.maxHealth,
    required this.currentHealth,
    required this.attack,
    required this.defense,
    this.loyalty = 0.5,
    this.totalCombats = 0,
    this.fleesWitnessed = 0,
    this.kills = 0,
    this.isActive = true,
    this.weaponType,
    this.armorType,
  });

  factory Companion.generate(String role, int playerLevel) {
    final random = Random();
    final names = _companionNames[role] ?? ['Mercenary'];
    final name = names[random.nextInt(names.length)];

    // Base stats scaled to player level
    final baseLevel = max(1, playerLevel - 1 + random.nextInt(3));

    final stats = _calculateStats(role, baseLevel);

    return Companion(
      name: name,
      role: role,
      level: baseLevel,
      maxHealth: stats['health']!,
      currentHealth: stats['health']!,
      attack: stats['attack']!,
      defense: stats['defense']!,
      weaponType: _defaultWeaponForRole(role),
      armorType: _defaultArmorForRole(role),
    );
  }

  static Map<String, int> _calculateStats(String role, int level) {
    final base = {
      'tank': {'health': 30, 'attack': 3, 'defense': 5},
      'healer': {'health': 20, 'attack': 2, 'defense': 2},
      'dps': {'health': 20, 'attack': 6, 'defense': 1},
      'scout': {'health': 15, 'attack': 4, 'defense': 3},
    };

    final roleBase = base[role] ?? base['dps']!;

    return {
      'health': roleBase['health']! + (level * 5),
      'attack': roleBase['attack']! + (level * 2),
      'defense': roleBase['defense']! + (level ~/ 2),
    };
  }

  static String? _defaultWeaponForRole(String role) {
    final weapons = {
      'tank': 'balanced',
      'healer': 'precise',
      'dps': 'heavy',
      'scout': 'quick',
    };
    return weapons[role];
  }

  static String? _defaultArmorForRole(String role) {
    final armors = {
      'tank': 'chain',
      'healer': 'cloth',
      'dps': 'leather',
      'scout': 'leather',
    };
    return armors[role];
  }

  static final Map<String, List<String>> _companionNames = {
    'tank': ['Grimgar', 'Boulder', 'Shieldmaiden', 'Ironhide', 'Stonewall'],
    'healer': ['Lumina', 'Sage', 'Moonwhisper', 'Sunbeam', 'Lifebinder'],
    'dps': ['Shadow', 'Blade', 'Ember', 'Raven', 'Storm'],
    'scout': ['Swift', 'Silent', 'Ghost', 'Wind', 'Pathfinder'],
  };

  /// Gain XP and possibly level up
  void gainExperience(int amount) {
    experience += amount;
    final required = level * 100;
    if (experience >= required) {
      experience -= required;
      level++;
      // Stat growth on level
      maxHealth += 5;
      currentHealth = maxHealth;
      attack += 2;
      defense += 1;
    }
  }

  /// Take damage
  void takeDamage(int damage) {
    currentHealth = max(0, currentHealth - damage);
    if (currentHealth == 0) {
      isActive = false;
    }
  }

  /// Heal
  void heal(int amount) {
    currentHealth = min(maxHealth, currentHealth + amount);
    if (currentHealth > 0) {
      isActive = true;
    }
  }

  /// Record a flee event - reduces loyalty
  void witnessFlee() {
    fleesWitnessed++;
    loyalty -= 0.1;
    loyalty = loyalty.clamp(0.0, 1.0);
  }

  /// Record a victory - increases loyalty
  void recordVictory() {
    totalCombats++;
    loyalty += 0.05;
    loyalty = loyalty.clamp(0.0, 1.0);
  }

  /// Check if companion will desert
  bool get willDesert => loyalty < 0.2 && Random().nextDouble() < 0.3;

  /// Check if companion will sacrifice themselves
  bool get willSacrifice => loyalty > 0.8 && Random().nextDouble() < 0.1;

  /// Get role description
  String get roleDescription {
    return {
          'tank': 'High HP, taunts enemies',
          'healer': 'Regenerates party HP',
          'dps': 'High damage output',
          'scout': 'High evasion, finds loot',
        }[role] ??
        'Unknown';
  }

  /// Get hire cost
  int get hireCost => level * 50 + 100;

  /// Get maintenance cost per day
  int get dailyCost => level * 5;

  String get status {
    if (!isActive) return '💀 Defeated';
    if (loyalty < 0.3) return '😠 Disloyal';
    if (loyalty > 0.8) return '😊 Loyal';
    return '😐 Neutral';
  }
}

/// Companion roster - manages all hired companions
@HiveType(typeId: 8)
class CompanionRoster extends HiveObject {
  @HiveField(0)
  List<Companion> companions;

  @HiveField(1)
  int maxCompanions;

  @HiveField(2)
  int totalHired;

  @HiveField(3)
  int totalDeserted;

  @HiveField(4)
  int totalSacrificed;

  CompanionRoster({
    this.companions = const [],
    this.maxCompanions = 2,
    this.totalHired = 0,
    this.totalDeserted = 0,
    this.totalSacrificed = 0,
  });

  factory CompanionRoster.create() {
    return CompanionRoster(companions: []);
  }

  /// Get active companions
  List<Companion> get activeCompanions =>
      companions.where((c) => c.isActive).toList();

  /// Check if can hire more
  bool get canHire => companions.length < maxCompanions;

  /// Hire a new companion
  void hire(Companion companion) {
    companions = [...companions, companion];
    totalHired++;
  }

  /// Remove a companion (desertion or death)
  void remove(Companion companion) {
    companions = companions.where((c) => c != companion).toList();
  }

  /// Record desertion
  void recordDesertion() {
    totalDeserted++;
  }

  /// Record sacrifice
  void recordSacrifice() {
    totalSacrificed++;
  }

  /// Check party composition
  bool get hasTank => companions.any((c) => c.role == 'tank' && c.isActive);
  bool get hasHealer => companions.any((c) => c.role == 'healer' && c.isActive);
  bool get hasDPS => companions.any((c) => c.role == 'dps' && c.isActive);

  /// Get missing roles
  List<String> get missingRoles {
    final missing = <String>[];
    if (!hasTank) missing.add('tank');
    if (!hasHealer) missing.add('healer');
    if (!hasDPS) missing.add('dps');
    return missing;
  }

  /// Get total party power
  int get partyPower {
    return companions.fold(0, (sum, c) => sum + c.attack + c.defense);
  }

  /// Daily maintenance - pay wages and check loyalty
  List<String> dailyMaintenance(int availableGold) {
    final logs = <String>[];
    int totalCost = 0;

    for (final companion in companions) {
      totalCost += companion.dailyCost;
    }

    if (availableGold < totalCost) {
      // Can't pay - loyalty drops
      for (final companion in companions) {
        companion.loyalty -= 0.1;
        companion.loyalty = companion.loyalty.clamp(0.0, 1.0);
      }
      logs.add('Could not pay companion wages! Loyalty decreased.');
    } else {
      logs.add('Paid \$$totalCost in companion wages.');
    }

    // Check for desertions
    final deserters = companions.where((c) => c.willDesert).toList();
    for (final deserter in deserters) {
      remove(deserter);
      recordDesertion();
      logs.add('${deserter.name} has deserted!');
    }

    return logs;
  }
}

/// Available companion templates in town
class CompanionMarket {
  static List<Companion> generateAvailable(int playerLevel, {int count = 3}) {
    final random = Random();
    final roles = ['tank', 'healer', 'dps', 'scout'];
    final available = <Companion>[];

    // Ensure variety - at least one of each preferred role if possible
    final preferredRoles = ['tank', 'healer', 'dps'];

    for (int i = 0; i < count; i++) {
      String role;
      if (i < preferredRoles.length) {
        role = preferredRoles[i];
      } else {
        role = roles[random.nextInt(roles.length)];
      }

      // Random level variance
      final levelOffset = random.nextInt(3) - 1; // -1, 0, or 1
      final companion = Companion.generate(role, playerLevel + levelOffset);
      available.add(companion);
    }

    return available;
  }
}
