import 'package:hive/hive.dart';
import 'dart:math';

part 'skill_tree.g.dart';

/// Skill Tree - Passive progression system
/// Nodes unlock over time based on playtime
@HiveType(typeId: 5)
class SkillTree extends HiveObject {
  // Unlocked node IDs
  @HiveField(0)
  List<String> unlockedNodes;

  // Progress toward next unlock (0.0 to 1.0)
  @HiveField(1)
  double unlockProgress;

  // Time spent playing (in minutes) - determines unlock speed
  @HiveField(2)
  int totalPlaytimeMinutes;

  // Last time progress was updated
  @HiveField(3)
  DateTime lastUpdate;

  // Detected playstyle: 'aggressive', 'defensive', 'loot'
  @HiveField(4)
  String playstyle;

  // Stats tracking for playstyle detection
  @HiveField(5)
  int killsRecorded;

  @HiveField(6)
  int fleesRecorded;

  @HiveField(7)
  int goldLooted;

  // Active path preference set by automation
  @HiveField(8)
  String? preferredBranch;

  SkillTree({
    this.unlockedNodes = const [],
    this.unlockProgress = 0.0,
    this.totalPlaytimeMinutes = 0,
    required this.lastUpdate,
    this.playstyle = 'balanced',
    this.killsRecorded = 0,
    this.fleesRecorded = 0,
    this.goldLooted = 0,
    this.preferredBranch,
  });

  factory SkillTree.create() {
    return SkillTree(
      unlockedNodes: [],
      unlockProgress: 0.0,
      totalPlaytimeMinutes: 0,
      lastUpdate: DateTime.now(),
      playstyle: 'balanced',
    );
  }

  /// Update playtime and skill unlock progress
  void updateProgress(int minutesPlayed) {
    totalPlaytimeMinutes += minutesPlayed;

    // Unlock speed: base 1% per minute, faster early on
    double unlockRate = 0.01;
    if (unlockedNodes.length < 5) unlockRate = 0.02;
    if (unlockedNodes.length < 10) unlockRate = 0.015;

    unlockProgress += minutesPlayed * unlockRate;

    // Check for unlocks
    while (unlockProgress >= 1.0) {
      unlockProgress -= 1.0;
      _unlockNextNode();
    }

    lastUpdate = DateTime.now();
  }

  void _unlockNextNode() {
    final available = getAvailableNodes();
    if (available.isEmpty) return;

    // Filter by preferred branch if set
    List<SkillNode> candidates = available;
    if (preferredBranch != null) {
      final branchPreferred = available
          .where((n) => n.branch == preferredBranch)
          .toList();
      if (branchPreferred.isNotEmpty) {
        candidates = branchPreferred;
      }
    }

    // Pick random from candidates
    final random = Random();
    final selected = candidates[random.nextInt(candidates.length)];
    unlockedNodes = [...unlockedNodes, selected.id];
  }

  /// Record combat activity for playstyle detection
  void recordKill() {
    killsRecorded++;
    _updatePlaystyle();
  }

  void recordFlee() {
    fleesRecorded++;
    _updatePlaystyle();
  }

  void recordGold(int amount) {
    goldLooted += amount;
    _updatePlaystyle();
  }

  void _updatePlaystyle() {
    final total = killsRecorded + fleesRecorded + (goldLooted ~/ 100);
    if (total < 10) return;

    final killRatio = killsRecorded / total;
    final fleeRatio = fleesRecorded / total;
    final lootRatio = (goldLooted ~/ 100) / total;

    if (killRatio > 0.5) {
      playstyle = 'aggressive';
      preferredBranch = 'combat';
    } else if (fleeRatio > 0.3) {
      playstyle = 'defensive';
      preferredBranch = 'survival';
    } else if (lootRatio > 0.4) {
      playstyle = 'loot';
      preferredBranch = 'wealth';
    } else {
      playstyle = 'balanced';
      preferredBranch = null;
    }
  }

  /// Get all available nodes that can be unlocked
  List<SkillNode> getAvailableNodes() {
    return SkillTreeData.allNodes
        .where(
          (node) =>
              !unlockedNodes.contains(node.id) &&
              node.prerequisites.every((pre) => unlockedNodes.contains(pre)),
        )
        .toList();
  }

  /// Get unlocked nodes
  List<SkillNode> getUnlockedNodes() {
    return SkillTreeData.allNodes
        .where((node) => unlockedNodes.contains(node.id))
        .toList();
  }

  /// Calculate total bonuses from unlocked nodes
  Map<String, double> getTotalBonuses() {
    final bonuses = <String, double>{};
    final unlocked = getUnlockedNodes();

    for (final node in unlocked) {
      for (final entry in node.bonuses.entries) {
        bonuses[entry.key] = (bonuses[entry.key] ?? 0) + entry.value;
      }
    }

    return bonuses;
  }

  /// Get progress percentage to next unlock
  double get progressPercent => (unlockProgress * 100).clamp(0, 100);
}

/// Individual skill node
class SkillNode {
  final String id;
  final String name;
  final String description;
  final String branch; // 'combat', 'survival', 'wealth'
  final Map<String, double> bonuses;
  final List<String> prerequisites;
  final int tier; // 1-5, affects position in grid
  final int position; // 0-5, hex position within tier

  const SkillNode({
    required this.id,
    required this.name,
    required this.description,
    required this.branch,
    required this.bonuses,
    this.prerequisites = const [],
    required this.tier,
    required this.position,
  });
}

/// Skill tree data definitions
class SkillTreeData {
  // Combat Branch (Red)
  static const List<SkillNode> combatNodes = [
    SkillNode(
      id: 'c1',
      name: 'Sharp Edge',
      description: 'Deal 5% more damage',
      branch: 'combat',
      bonuses: {'damage': 0.05},
      tier: 1,
      position: 0,
    ),
    SkillNode(
      id: 'c2',
      name: 'Quick Strike',
      description: 'Attack 3% faster',
      branch: 'combat',
      bonuses: {'attackSpeed': 0.03},
      prerequisites: ['c1'],
      tier: 2,
      position: 0,
    ),
    SkillNode(
      id: 'c3',
      name: 'Precise Hit',
      description: '+2% critical chance',
      branch: 'combat',
      bonuses: {'critChance': 0.02},
      prerequisites: ['c1'],
      tier: 2,
      position: 1,
    ),
    SkillNode(
      id: 'c4',
      name: 'Brutal Force',
      description: 'Deal 10% more damage, take 5% more',
      branch: 'combat',
      bonuses: {'damage': 0.10, 'damageTaken': 0.05},
      prerequisites: ['c2'],
      tier: 3,
      position: 0,
    ),
    SkillNode(
      id: 'c5',
      name: 'Bloodlust',
      description: 'Heal 2% of damage dealt',
      branch: 'combat',
      bonuses: {'lifeSteal': 0.02},
      prerequisites: ['c3'],
      tier: 3,
      position: 1,
    ),
    SkillNode(
      id: 'c6',
      name: 'Berserker',
      description: 'Below 25% HP: +20% damage',
      branch: 'combat',
      bonuses: {'berserkDamage': 0.20},
      prerequisites: ['c4', 'c5'],
      tier: 4,
      position: 0,
    ),
    SkillNode(
      id: 'c7',
      name: 'Executioner',
      description: 'Enemies below 10% HP die instantly',
      branch: 'combat',
      bonuses: {'execute': 1.0},
      prerequisites: ['c6'],
      tier: 5,
      position: 0,
    ),
  ];

  // Survival Branch (Green)
  static const List<SkillNode> survivalNodes = [
    SkillNode(
      id: 's1',
      name: 'Thick Skin',
      description: 'Take 5% less damage',
      branch: 'survival',
      bonuses: {'damageReduction': 0.05},
      tier: 1,
      position: 0,
    ),
    SkillNode(
      id: 's2',
      name: 'Fast Recovery',
      description: 'Regen 1% HP per minute',
      branch: 'survival',
      bonuses: {'hpRegen': 0.01},
      prerequisites: ['s1'],
      tier: 2,
      position: 0,
    ),
    SkillNode(
      id: 's3',
      name: 'Evasive',
      description: '+3% evasion',
      branch: 'survival',
      bonuses: {'evasion': 0.03},
      prerequisites: ['s1'],
      tier: 2,
      position: 1,
    ),
    SkillNode(
      id: 's4',
      name: 'Toughness',
      description: '+10% max HP',
      branch: 'survival',
      bonuses: {'maxHp': 0.10},
      prerequisites: ['s2'],
      tier: 3,
      position: 0,
    ),
    SkillNode(
      id: 's5',
      name: 'Second Wind',
      description: 'Once per combat, survive a lethal blow at 1 HP',
      branch: 'survival',
      bonuses: {'secondWind': 1.0},
      prerequisites: ['s3'],
      tier: 3,
      position: 1,
    ),
    SkillNode(
      id: 's6',
      name: 'Iron Will',
      description: 'Immune to status effects',
      branch: 'survival',
      bonuses: {'statusImmunity': 1.0},
      prerequisites: ['s4', 's5'],
      tier: 4,
      position: 0,
    ),
    SkillNode(
      id: 's7',
      name: 'Immortal',
      description: 'Resurrect once per day with 50% HP',
      branch: 'survival',
      bonuses: {'resurrection': 1.0},
      prerequisites: ['s6'],
      tier: 5,
      position: 0,
    ),
  ];

  // Wealth Branch (Gold)
  static const List<SkillNode> wealthNodes = [
    SkillNode(
      id: 'w1',
      name: 'Lucky',
      description: 'Find 10% more gold',
      branch: 'wealth',
      bonuses: {'goldFind': 0.10},
      tier: 1,
      position: 0,
    ),
    SkillNode(
      id: 'w2',
      name: 'Scavenger',
      description: 'Potions drop 15% more often',
      branch: 'wealth',
      bonuses: {'potionDrop': 0.15},
      prerequisites: ['w1'],
      tier: 2,
      position: 0,
    ),
    SkillNode(
      id: 'w3',
      name: 'Haggler',
      description: 'Shop prices reduced by 10%',
      branch: 'wealth',
      bonuses: {'shopDiscount': 0.10},
      prerequisites: ['w1'],
      tier: 2,
      position: 1,
    ),
    SkillNode(
      id: 'w4',
      name: 'Treasure Hunter',
      description: 'Better equipment drops',
      branch: 'wealth',
      bonuses: {'itemQuality': 0.10},
      prerequisites: ['w2'],
      tier: 3,
      position: 0,
    ),
    SkillNode(
      id: 'w5',
      name: 'Efficient',
      description: 'XP gain increased by 10%',
      branch: 'wealth',
      bonuses: {'xpGain': 0.10},
      prerequisites: ['w3'],
      tier: 3,
      position: 1,
    ),
    SkillNode(
      id: 'w6',
      name: 'Midas Touch',
      description: 'Enemies drop gold on death',
      branch: 'wealth',
      bonuses: {'goldPerKill': 1.0},
      prerequisites: ['w4', 'w5'],
      tier: 4,
      position: 0,
    ),
    SkillNode(
      id: 'w7',
      name: 'Wealthy',
      description: 'Interest on gold: +1% per day',
      branch: 'wealth',
      bonuses: {'goldInterest': 0.01},
      prerequisites: ['w6'],
      tier: 5,
      position: 0,
    ),
  ];

  static List<SkillNode> get allNodes => [
    ...combatNodes,
    ...survivalNodes,
    ...wealthNodes,
  ];

  static SkillNode? getNodeById(String id) {
    try {
      return allNodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}
