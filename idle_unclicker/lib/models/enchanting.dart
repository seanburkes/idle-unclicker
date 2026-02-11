import 'package:hive/hive.dart';
import 'dart:math';
import 'equipment.dart';

part 'enchanting.g.dart';

/// GemType - The three types of gems with their associated stats
@HiveType(typeId: 20)
enum GemType {
  @HiveField(0)
  ruby, // Red - Strength/Damage
  @HiveField(1)
  sapphire, // Blue - Intellect/Magic
  @HiveField(2)
  emerald, // Green - Agility/Speed
}

/// GemTier - The quality tier of a gem affecting bonus magnitude
@HiveType(typeId: 21)
enum GemTier {
  @HiveField(0)
  cracked, // Tier 1 - +1%
  @HiveField(1)
  flawed, // Tier 2 - +2%
  @HiveField(2)
  regular, // Tier 3 - +3%
  @HiveField(3)
  flawless, // Tier 4 - +4%
  @HiveField(4)
  perfect, // Tier 5 - +5%
}

/// PrefixType - The prefix enchantment types
@HiveType(typeId: 22)
enum PrefixType {
  @HiveField(0)
  sharp, // +damage
  @HiveField(1)
  sturdy, // +armor
  @HiveField(2)
  lucky, // +gold
  @HiveField(3)
  swift, // +speed
  @HiveField(4)
  wise, // +mana/intellect
  @HiveField(5)
  vital, // +health
  @HiveField(6)
  precise, // +accuracy
  @HiveField(7)
  resilient, // +resistance
}

/// SuffixType - The suffix enchantment types
@HiveType(typeId: 23)
enum SuffixType {
  @HiveField(0)
  ofPower, // +damage
  @HiveField(1)
  ofProtection, // +armor
  @HiveField(2)
  ofFortune, // +gold
  @HiveField(3)
  ofHaste, // +speed
  @HiveField(4)
  ofWisdom, // +mana
  @HiveField(5)
  ofVitality, // +health
  @HiveField(6)
  ofPrecision, // +crit
  @HiveField(7)
  ofEvasion, // +dodge
  @HiveField(8)
  ofStrength, // +strength
  @HiveField(9)
  ofAgility, // +dexterity
}

/// CurseType - Cursed enchantments that provide powerful bonuses with drawbacks
@HiveType(typeId: 24)
enum CurseType {
  @HiveField(0)
  none, // No curse
  @HiveField(1)
  bloodthirsty, // +damage, -health
  @HiveField(2)
  greedy, // +gold, -armor
  @HiveField(3)
  reckless, // +speed, -evasion
  @HiveField(4)
  fragile, // +crit, -max health
}

/// Gem - A socketable gem that provides stat bonuses
@HiveType(typeId: 25)
class Gem extends HiveObject {
  @HiveField(0)
  GemType type;

  @HiveField(1)
  GemTier tier;

  GemType get gemType => type;
  GemTier get gemTier => tier;

  Gem({required this.type, required this.tier});

  /// Get the bonus percentage for this gem
  double get bonusPercent {
    switch (tier) {
      case GemTier.cracked:
        return 0.01;
      case GemTier.flawed:
        return 0.02;
      case GemTier.regular:
        return 0.03;
      case GemTier.flawless:
        return 0.04;
      case GemTier.perfect:
        return 0.05;
    }
  }

  /// Get the stat type this gem affects
  String get affectedStat {
    switch (type) {
      case GemType.ruby:
        return 'strength';
      case GemType.sapphire:
        return 'intellect';
      case GemType.emerald:
        return 'agility';
    }
  }

  /// Get a human-readable name for the gem
  String get name {
    final tierName = tier.toString().split('.').last;
    final typeName = type.toString().split('.').last;
    return '${tierName.capitalize()} ${typeName.capitalize()}';
  }

  /// Get the color associated with this gem type
  String get color {
    switch (type) {
      case GemType.ruby:
        return '#FF0000';
      case GemType.sapphire:
        return '#0000FF';
      case GemType.emerald:
        return '#00FF00';
    }
  }

  /// Get an icon for this gem
  String get icon {
    switch (type) {
      case GemType.ruby:
        return '🔴';
      case GemType.sapphire:
        return '🔵';
      case GemType.emerald:
        return '🟢';
    }
  }

  /// Create a random gem of random tier
  factory Gem.random(Random random) {
    final types = GemType.values;
    final tiers = GemTier.values;
    return Gem(
      type: types[random.nextInt(types.length)],
      tier: tiers[random.nextInt(tiers.length)],
    );
  }

  @override
  String toString() => name;
}

/// Enchantment - A magical enchantment with prefix, suffix, and optional curse
@HiveType(typeId: 26)
class Enchantment extends HiveObject {
  @HiveField(0)
  PrefixType prefix;

  @HiveField(1)
  SuffixType suffix;

  @HiveField(2)
  CurseType curse;

  @HiveField(3)
  double prefixMagnitude; // 0.10 to 0.20 for normal, 0.25 to 0.35 for cursed

  @HiveField(4)
  double suffixMagnitude;

  @HiveField(5)
  double curseDrawbackMagnitude; // 0.10 to 0.15 for curse drawback

  @HiveField(6)
  bool isCursed;

  Enchantment({
    required this.prefix,
    required this.suffix,
    this.curse = CurseType.none,
    required this.prefixMagnitude,
    required this.suffixMagnitude,
    this.curseDrawbackMagnitude = 0.0,
    this.isCursed = false,
  });

  /// Get the full enchantment name (e.g., "Sharp Sword of Power")
  String getEnchantmentName(String baseItemName) {
    final prefixStr = _getPrefixName();
    final suffixStr = _getSuffixName();
    return '$prefixStr $baseItemName $suffixStr';
  }

  String _getPrefixName() {
    switch (prefix) {
      case PrefixType.sharp:
        return 'Sharp';
      case PrefixType.sturdy:
        return 'Sturdy';
      case PrefixType.lucky:
        return 'Lucky';
      case PrefixType.swift:
        return 'Swift';
      case PrefixType.wise:
        return 'Wise';
      case PrefixType.vital:
        return 'Vital';
      case PrefixType.precise:
        return 'Precise';
      case PrefixType.resilient:
        return 'Resilient';
    }
  }

  String _getSuffixName() {
    switch (suffix) {
      case SuffixType.ofPower:
        return 'of Power';
      case SuffixType.ofProtection:
        return 'of Protection';
      case SuffixType.ofFortune:
        return 'of Fortune';
      case SuffixType.ofHaste:
        return 'of Haste';
      case SuffixType.ofWisdom:
        return 'of Wisdom';
      case SuffixType.ofVitality:
        return 'of Vitality';
      case SuffixType.ofPrecision:
        return 'of Precision';
      case SuffixType.ofEvasion:
        return 'of Evasion';
      case SuffixType.ofStrength:
        return 'of Strength';
      case SuffixType.ofAgility:
        return 'of Agility';
    }
  }

  /// Get the curse name if cursed
  String? get curseName {
    switch (curse) {
      case CurseType.none:
        return null;
      case CurseType.bloodthirsty:
        return 'Bloodthirsty';
      case CurseType.greedy:
        return 'Greedy';
      case CurseType.reckless:
        return 'Reckless';
      case CurseType.fragile:
        return 'Fragile';
    }
  }

  /// Get a description of the enchantment bonuses
  Map<String, double> getBonuses() {
    final bonuses = <String, double>{};

    // Prefix bonuses
    switch (prefix) {
      case PrefixType.sharp:
        bonuses['damage'] = (bonuses['damage'] ?? 0) + prefixMagnitude;
        break;
      case PrefixType.sturdy:
        bonuses['armor'] = (bonuses['armor'] ?? 0) + prefixMagnitude;
        break;
      case PrefixType.lucky:
        bonuses['gold'] = (bonuses['gold'] ?? 0) + prefixMagnitude;
        break;
      case PrefixType.swift:
        bonuses['speed'] = (bonuses['speed'] ?? 0) + prefixMagnitude;
        break;
      case PrefixType.wise:
        bonuses['intellect'] = (bonuses['intellect'] ?? 0) + prefixMagnitude;
        break;
      case PrefixType.vital:
        bonuses['health'] = (bonuses['health'] ?? 0) + prefixMagnitude;
        break;
      case PrefixType.precise:
        bonuses['accuracy'] = (bonuses['accuracy'] ?? 0) + prefixMagnitude;
        break;
      case PrefixType.resilient:
        bonuses['resistance'] = (bonuses['resistance'] ?? 0) + prefixMagnitude;
        break;
    }

    // Suffix bonuses
    switch (suffix) {
      case SuffixType.ofPower:
        bonuses['damage'] = (bonuses['damage'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofProtection:
        bonuses['armor'] = (bonuses['armor'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofFortune:
        bonuses['gold'] = (bonuses['gold'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofHaste:
        bonuses['speed'] = (bonuses['speed'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofWisdom:
        bonuses['mana'] = (bonuses['mana'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofVitality:
        bonuses['health'] = (bonuses['health'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofPrecision:
        bonuses['crit'] = (bonuses['crit'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofEvasion:
        bonuses['evasion'] = (bonuses['evasion'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofStrength:
        bonuses['strength'] = (bonuses['strength'] ?? 0) + suffixMagnitude;
        break;
      case SuffixType.ofAgility:
        bonuses['agility'] = (bonuses['agility'] ?? 0) + suffixMagnitude;
        break;
    }

    return bonuses;
  }

  /// Get curse drawback penalties
  Map<String, double> getCursePenalties() {
    if (!isCursed || curse == CurseType.none) return {};

    final penalties = <String, double>{};
    switch (curse) {
      case CurseType.bloodthirsty:
        penalties['health'] = -curseDrawbackMagnitude;
        break;
      case CurseType.greedy:
        penalties['armor'] = -curseDrawbackMagnitude;
        break;
      case CurseType.reckless:
        penalties['evasion'] = -curseDrawbackMagnitude;
        break;
      case CurseType.fragile:
        penalties['maxHealth'] = -curseDrawbackMagnitude;
        break;
      case CurseType.none:
        break;
    }
    return penalties;
  }

  /// Generate a random enchantment
  factory Enchantment.generate(Random random, {bool forceCursed = false}) {
    final prefixes = PrefixType.values;
    final suffixes = SuffixType.values;
    final curses = CurseType.values.where((c) => c != CurseType.none).toList();

    // Determine if cursed: 25% chance (or forced)
    final isCursed = forceCursed || random.nextDouble() < 0.25;

    double prefixMag;
    double suffixMag;
    double curseMag = 0.0;
    CurseType selectedCurse = CurseType.none;

    if (isCursed) {
      // Cursed enchantments: 25-35% bonus
      prefixMag = 0.25 + (random.nextDouble() * 0.10);
      suffixMag = 0.25 + (random.nextDouble() * 0.10);
      curseMag = 0.10 + (random.nextDouble() * 0.05);
      selectedCurse = curses[random.nextInt(curses.length)];
    } else {
      // Normal enchantments: 10-20% bonus
      prefixMag = 0.10 + (random.nextDouble() * 0.10);
      suffixMag = 0.10 + (random.nextDouble() * 0.10);
    }

    return Enchantment(
      prefix: prefixes[random.nextInt(prefixes.length)],
      suffix: suffixes[random.nextInt(suffixes.length)],
      curse: selectedCurse,
      prefixMagnitude: prefixMag,
      suffixMagnitude: suffixMag,
      curseDrawbackMagnitude: curseMag,
      isCursed: isCursed,
    );
  }
}

/// Socket - A socket in equipment that can hold a gem
@HiveType(typeId: 27)
class Socket extends HiveObject {
  @HiveField(0)
  Gem? gem;

  @HiveField(1)
  bool isLocked;

  Socket({this.gem, this.isLocked = false});

  /// Check if this socket has a gem
  bool get hasGem => gem != null;

  /// Get the bonus from this socket (0 if empty)
  double get bonusPercent => gem?.bonusPercent ?? 0.0;

  /// Get the stat type this socket contributes
  String? get statType => gem?.affectedStat;

  /// Socket a gem into this socket
  void socketGem(Gem newGem) {
    if (!isLocked) {
      gem = newGem;
    }
  }

  /// Remove the gem from this socket
  Gem? removeGem() {
    if (isLocked || gem == null) return null;
    final removed = gem;
    gem = null;
    return removed;
  }

  /// Unlock this socket
  void unlock() {
    isLocked = false;
  }

  /// Create an empty unlocked socket
  factory Socket.empty() => Socket();

  /// Create a locked socket
  factory Socket.locked() => Socket(isLocked: true);
}

/// EnchantedEquipment - Wraps Equipment with enchanting capabilities
@HiveType(typeId: 28)
class EnchantedEquipment extends HiveObject {
  @HiveField(0)
  Equipment baseEquipment;

  @HiveField(1)
  List<Socket> sockets;

  @HiveField(2)
  Enchantment? enchantment;

  @HiveField(3)
  int enchantAttempts;

  @HiveField(4)
  String? historyLog; // Recent enchantment history

  EnchantedEquipment({
    required this.baseEquipment,
    required this.sockets,
    this.enchantment,
    this.enchantAttempts = 0,
    this.historyLog,
  });

  /// Create an EnchantedEquipment from base equipment
  factory EnchantedEquipment.fromEquipment(Equipment equipment) {
    final socketCount = equipment.socketCount;
    final sockets = List<Socket>.generate(
      socketCount,
      (index) => Socket.empty(),
    );

    return EnchantedEquipment(baseEquipment: equipment, sockets: sockets);
  }

  /// Get the total number of sockets
  int get socketCount => sockets.length;

  /// Get the number of filled sockets
  int get filledSocketCount => sockets.where((s) => s.hasGem).length;

  /// Get the number of empty sockets
  int get emptySocketCount =>
      sockets.where((s) => !s.hasGem && !s.isLocked).length;

  /// Check if this item has an enchantment
  bool get isEnchanted => enchantment != null;

  /// Check if this item is cursed
  bool get isCursed => enchantment?.isCursed ?? false;

  /// Get the current destruction risk (5% base + 1% per attempt, capped at 20%)
  double get destructionRisk {
    final risk = 0.05 + (enchantAttempts * 0.01);
    return risk.clamp(0.05, 0.20);
  }

  /// Get the display name with enchantment
  String get displayName {
    if (enchantment != null) {
      return enchantment!.getEnchantmentName(baseEquipment.name);
    }
    return baseEquipment.name;
  }

  /// Calculate total stat bonuses from gems
  Map<String, double> calculateGemBonuses() {
    final bonuses = <String, double>{};

    for (final socket in sockets) {
      if (socket.hasGem && socket.gem != null) {
        final stat = socket.gem!.affectedStat;
        bonuses[stat] = (bonuses[stat] ?? 0) + socket.gem!.bonusPercent;
      }
    }

    return bonuses;
  }

  /// Calculate total stat bonuses from enchantment
  Map<String, double> calculateEnchantmentBonuses() {
    if (enchantment == null) return {};

    final bonuses = enchantment!.getBonuses();
    final penalties = enchantment!.getCursePenalties();

    // Merge bonuses and penalties
    final total = Map<String, double>.from(bonuses);
    penalties.forEach((stat, value) {
      total[stat] = (total[stat] ?? 0) + value;
    });

    return total;
  }

  /// Calculate all total bonuses (gems + enchantment)
  Map<String, double> calculateTotalBonuses() {
    final gemBonuses = calculateGemBonuses();
    final enchantBonuses = calculateEnchantmentBonuses();

    final total = Map<String, double>.from(gemBonuses);
    enchantBonuses.forEach((stat, value) {
      total[stat] = (total[stat] ?? 0) + value;
    });

    return total;
  }

  /// Get the effective attack bonus including all enchantments
  int get effectiveAttackBonus {
    var bonus = baseEquipment.attackBonus.toDouble();
    final bonuses = calculateTotalBonuses();

    // Apply damage bonuses
    if (bonuses.containsKey('damage')) {
      bonus *= (1 + bonuses['damage']!);
    }
    if (bonuses.containsKey('strength')) {
      bonus *= (1 + bonuses['strength']!);
    }

    return bonus.round();
  }

  /// Get the effective defense bonus including all enchantments
  int get effectiveDefenseBonus {
    var bonus = baseEquipment.defenseBonus.toDouble();
    final bonuses = calculateTotalBonuses();

    // Apply armor bonuses
    if (bonuses.containsKey('armor')) {
      bonus *= (1 + bonuses['armor']!);
    }

    return bonus.round();
  }

  /// Get the effective health bonus including all enchantments
  int get effectiveHealthBonus {
    var bonus = baseEquipment.healthBonus.toDouble();
    final bonuses = calculateTotalBonuses();

    // Apply health bonuses
    if (bonuses.containsKey('health')) {
      bonus *= (1 + bonuses['health']!);
    }

    return bonus.round();
  }

  /// Get the effective mana bonus including all enchantments
  int get effectiveManaBonus {
    var bonus = baseEquipment.manaBonus.toDouble();
    final bonuses = calculateTotalBonuses();

    // Apply mana bonuses
    if (bonuses.containsKey('mana')) {
      bonus *= (1 + bonuses['mana']!);
    }
    if (bonuses.containsKey('intellect')) {
      bonus *= (1 + bonuses['intellect']!);
    }

    return bonus.round();
  }

  /// Socket a gem into an empty socket
  bool socketGem(int socketIndex, Gem gem) {
    if (socketIndex < 0 || socketIndex >= sockets.length) return false;
    if (sockets[socketIndex].hasGem) return false;
    if (sockets[socketIndex].isLocked) return false;

    sockets[socketIndex].socketGem(gem);
    return true;
  }

  /// Remove a gem from a socket
  Gem? removeGem(int socketIndex) {
    if (socketIndex < 0 || socketIndex >= sockets.length) return null;
    return sockets[socketIndex].removeGem();
  }

  /// Apply an enchantment to this item
  void applyEnchantment(Enchantment newEnchantment) {
    enchantment = newEnchantment;
    enchantAttempts++;
    _addToHistory(
      'Enchanted: ${newEnchantment.getEnchantmentName(baseEquipment.name)}',
    );
  }

  /// Record a failed enchantment (item destroyed)
  void recordDestruction() {
    enchantAttempts++;
    _addToHistory('DESTROYED during enchantment attempt');
  }

  /// Add an entry to the history log
  void _addToHistory(String entry) {
    final timestamp = DateTime.now().toIso8601String().substring(0, 16);
    final newEntry = '[$timestamp] $entry';

    if (historyLog == null || historyLog!.isEmpty) {
      historyLog = newEntry;
    } else {
      final entries = historyLog!.split('\n');
      entries.add(newEntry);
      // Keep only last 10 entries
      if (entries.length > 10) {
        entries.removeAt(0);
      }
      historyLog = entries.join('\n');
    }
  }

  /// Get the history log entries
  List<String> get historyEntries {
    if (historyLog == null || historyLog!.isEmpty) return [];
    return historyLog!.split('\n');
  }

  /// Get rarity color based on base equipment rarity
  String get rarityColor {
    switch (baseEquipment.rarity) {
      case 1:
        return '#AAAAAA'; // Common - Grey
      case 2:
        return '#00FF00'; // Uncommon - Green
      case 3:
        return '#0088FF'; // Rare - Blue
      case 4:
        return '#AA00FF'; // Epic - Purple
      case 5:
        return '#FFAA00'; // Legendary - Gold
      default:
        return '#AAAAAA';
    }
  }

  /// Get rarity name
  String get rarityName {
    switch (baseEquipment.rarity) {
      case 1:
        return 'Common';
      case 2:
        return 'Uncommon';
      case 3:
        return 'Rare';
      case 4:
        return 'Epic';
      case 5:
        return 'Legendary';
      default:
        return 'Unknown';
    }
  }
}

/// Helper extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// EnchantmentResult - Result of an enchantment attempt
class EnchantmentResult {
  final bool success;
  final bool destroyed;
  final Enchantment? enchantment;
  final String message;

  EnchantmentResult({
    required this.success,
    required this.destroyed,
    this.enchantment,
    required this.message,
  });

  factory EnchantmentResult.success(Enchantment enchantment) {
    return EnchantmentResult(
      success: true,
      destroyed: false,
      enchantment: enchantment,
      message: enchantment.isCursed
          ? 'Cursed enchantment applied!'
          : 'Enchantment successful!',
    );
  }

  factory EnchantmentResult.destroyed() {
    return EnchantmentResult(
      success: false,
      destroyed: true,
      message: 'Item was destroyed during enchantment!',
    );
  }

  factory EnchantmentResult.failure(String reason) {
    return EnchantmentResult(
      success: false,
      destroyed: false,
      message: 'Enchantment failed: $reason',
    );
  }
}
