import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/character.dart';
import '../models/game_state.dart';
import '../models/combat_log.dart';
import '../models/equipment.dart';
import '../models/skill_tree.dart';
import '../services/time_manager.dart';
import '../services/guild_hall_service.dart';
import '../services/boss_rift_service.dart';
import '../utils/procedural_generator.dart';
import '../utils/rpg_system.dart';
import '../utils/dungeon_generator.dart';
import '../utils/dungeon_renderer.dart';
import '../utils/player_automaton.dart';
import '../models/bestiary.dart';
import '../models/companion.dart';
import '../models/guild_hall.dart';
import '../models/enchanting.dart';
import '../models/boss_rush.dart';
import '../models/professions.dart';
import '../models/equipment_sets.dart';
import '../models/transmutation.dart';
import '../models/alchemy.dart';
import '../models/legendary_items.dart';
import '../models/infinite_spiral.dart';
import '../services/enchanting_service.dart';
import '../services/profession_service.dart';
import '../services/equipment_set_service.dart';
import '../services/transmutation_service.dart';
import '../services/alchemy_service.dart';
import '../services/legendary_item_service.dart';
import '../services/spiral_service.dart';
import '../config/feature_flags.dart';

class GameProvider extends ChangeNotifier {
  final Box<Character> _characterBox;
  final Box<GameState> _gameStateBox;
  final Box<CombatLog> _combatLogBox;
  final Box<SkillTree> _skillTreeBox;
  final Box<Bestiary> _bestiaryBox;
  final Box<CompanionRoster> _companionBox;
  final Box<GuildHall> _guildHallBox;
  final Box<BossRushState> _bossRushBox;
  final Box<ProfessionState> _professionBox;
  final TimeManager _timeManager;

  Timer? _gameTimer;
  Timer? _focusTimer;
  Timer? _saveTimer;
  Timer? _combatTimer;
  Timer? _skillTreeTimer;
  Timer? _guildHallTimer;
  Timer? _professionTimer;

  Character? _character;
  GameState? _gameState;
  CombatLog? _combatLog;
  SkillTree? _skillTree;
  Bestiary? _bestiary;
  CompanionRoster? _companionRoster;
  GuildHall? _guildHall;
  GuildHallService? _guildHallService;
  EnchantingService? _enchantingService;
  BossRushState? _bossRushState;
  BossRiftService? _bossRiftService;
  ProfessionState? _professionState;
  ProfessionService? _professionService;
  List<EnchantedEquipment> _enchantedEquipment = [];
  final Random _random = Random();

  // Equipment Sets
  EquipmentSetState? _equipmentSetState;
  EquipmentSetService? _equipmentSetService;
  final Box<EquipmentSetState> _equipmentSetBox;
  List<EquipmentSetItem> _setInventory = [];
  List<EquipmentSetItem> _equippedSetItems = [];

  // Transmutation & Alchemy
  TransmutationState? _transmutationState;
  TransmutationService? _transmutationService;
  AlchemyState? _alchemyState;
  AlchemyService? _alchemyService;
  final Box<TransmutationState> _transmutationBox;
  final Box<AlchemyState> _alchemyBox;

  // Legendary Items
  LegendaryCollection? _legendaryCollection;
  LegendaryItemService? _legendaryItemService;
  final Box<LegendaryCollection> _legendaryBox;
  List<LegendaryItem> _legendaryInventory = [];
  List<LegendaryItem> _equippedLegendaries = [];

  // Infinite Spiral
  InfiniteSpiral? _spiral;
  SpiralService? _spiralService;
  final Box<InfiniteSpiral> _spiralBox;

  // Boss combat state
  bool _isBossFight = false;
  int _bossCombatTurns = 0;

  bool _isInApp = true;
  bool _ascensionAvailable = false;
  int _pendingEchoShards = 0;

  String _currentEnemy = '';
  String _currentEnemyType = '';
  int _enemyHealth = 0;
  int _enemyMaxHealth = 0;
  int _enemyAttack = 0;
  int _enemyEvasion = 0;
  int _enemyArmor = 0;
  bool _inCombat = false;
  bool _isResting = false;
  bool _inTown = true; // Start in town

  DungeonGenerator? _dungeonGenerator;
  TownGenerator? _townGenerator;
  DungeonRenderer? _cachedRenderer;
  int _currentDungeonSeed = 0;

  final PlayerAutomaton _automaton = PlayerAutomaton();
  final List<String> _pendingLogEntries = [];

  final ValueNotifier<double> enemyHealthPercent = ValueNotifier(0.0);
  final ValueNotifier<double> focusPercent = ValueNotifier(0.0);
  final ValueNotifier<int> playerHealth = ValueNotifier(0);
  final ValueNotifier<int> playerMaxHealth = ValueNotifier(0);
  final ValueNotifier<int> potionCount = ValueNotifier(0);

  GameProvider(
    this._characterBox,
    this._gameStateBox,
    this._combatLogBox,
    this._skillTreeBox,
    this._bestiaryBox,
    this._companionBox,
    this._guildHallBox,
    this._bossRushBox,
    this._professionBox,
    this._equipmentSetBox,
    this._transmutationBox,
    this._alchemyBox,
    this._legendaryBox,
    this._spiralBox,
    this._timeManager,
  ) {
    _loadGame();
  }

  Future<void> _loadGame() async {
    await _timeManager.initialize();

    _character = _characterBox.get('main');
    _gameState = _gameStateBox.get('state');
    _combatLog = _combatLogBox.get('log');
    _skillTree = _skillTreeBox.get('tree');
    _bestiary = _bestiaryBox.get('bestiary');
    _companionRoster = _companionBox.get('roster');

    if (_character == null) {
      _createNewCharacter();
    }

    if (_gameState == null) {
      _gameState = GameState.create();
      await _gameStateBox.put('state', _gameState!);
    }

    if (_combatLog == null) {
      _combatLog = CombatLog();
      await _combatLogBox.put('log', _combatLog!);
    }

    if (_skillTree == null) {
      _skillTree = SkillTree.create();
      await _skillTreeBox.put('tree', _skillTree!);
    }

    if (_bestiary == null) {
      _bestiary = Bestiary.create();
      await _bestiaryBox.put('bestiary', _bestiary!);
    }

    if (_companionRoster == null) {
      _companionRoster = CompanionRoster.create();
      await _companionBox.put('roster', _companionRoster!);
    }

    // Load Guild Hall
    _guildHall = _guildHallBox.get('hall');
    if (_guildHall == null) {
      _guildHall = GuildHall.create();
      await _guildHallBox.put('hall', _guildHall!);
    }
    _guildHallService = GuildHallService(_guildHall!);

    // Initialize Enchanting Service
    _enchantingService = EnchantingService();
    await _loadEnchantedEquipment();

    // Load Boss Rush State
    _bossRushState = _bossRushBox.get('bossrush');
    if (_bossRushState == null) {
      _bossRushState = BossRushState.create();
      await _bossRushBox.put('bossrush', _bossRushState!);
    }
    _bossRiftService = BossRiftService(_bossRushState!);

    // Load Profession State
    _professionState = _professionBox.get('professions');
    if (_professionState == null) {
      _professionState = ProfessionState.create();
      await _professionBox.put('professions', _professionState!);
    }
    _professionService = ProfessionService(_professionState!);
    _professionService!.initializeProfessions();

    // Load Equipment Set State
    _equipmentSetState = _equipmentSetBox.get('sets');
    if (_equipmentSetState == null) {
      _equipmentSetState = EquipmentSetState();
      await _equipmentSetBox.put('sets', _equipmentSetState!);
    }
    _equipmentSetService = EquipmentSetService(_equipmentSetState!);
    _equipmentSetService!.initializeSets();
    await _loadSetEquipment();

    // Load Transmutation State
    _transmutationState = _transmutationBox.get('transmutation');
    if (_transmutationState == null) {
      _transmutationState = TransmutationState.create();
      await _transmutationBox.put('transmutation', _transmutationState!);
    }
    _transmutationService = TransmutationService(_transmutationState!);
    _transmutationService!.initializeRecipes();

    // Load Alchemy State
    _alchemyState = _alchemyBox.get('alchemy');
    if (_alchemyState == null) {
      _alchemyState = AlchemyState.create();
      await _alchemyBox.put('alchemy', _alchemyState!);
    }
    _alchemyService = AlchemyService(_alchemyState!);
    _alchemyService!.initializeRecipes();

    // Link transmutation and alchemy
    _transmutationService!.updateAlchemyState(_alchemyState!);
    _alchemyService!.updateProfessionState(_professionState!);

    // Load Legendary Collection
    _legendaryCollection = _legendaryBox.get('legendary');
    if (_legendaryCollection == null) {
      _legendaryCollection = LegendaryCollection.create();
      await _legendaryBox.put('legendary', _legendaryCollection!);
    }
    _legendaryItemService = LegendaryItemService(_legendaryCollection!);
    _legendaryItemService!.initializeLegendaryItems();
    await _loadLegendaryEquipment();

    // Load Infinite Spiral
    if (AppFeatures.isEnabled(AppFeatures.infiniteSpiral)) {
      _spiral = _spiralBox.get('spiral');
      if (_spiral == null) {
        _spiral = InfiniteSpiral.create();
        await _spiralBox.put('spiral', _spiral!);
      }
      _spiralService = SpiralService(_spiral!);
      _spiralService!.initializeSpiral();
    }

    // Unlock Guild Hall if player has ascended at least once
    if (_gameState != null &&
        _gameState!.totalAscensions > 0 &&
        !_guildHall!.isUnlocked) {
      _guildHall!.unlock();
      _guildHall!.save();
    }

    _updateNotifiers();
    _currentDungeonSeed = _character?.dungeonDepth ?? 1;
    _dungeonGenerator = DungeonGenerator(
      width: 60,
      height: 18,
      seed: _currentDungeonSeed,
    );
    _townGenerator = TownGenerator(
      width: 50,
      height: 15,
      seed: DateTime.now().day,
    ); // New town each day
    _updateRenderer();
    await _calculateOfflineProgress();
    _startGameLoop();
    notifyListeners();
  }

  void _updateNotifiers() {
    if (_character != null) {
      focusPercent.value = _gameState?.focusPercentage ?? 0.0;
      playerHealth.value = _character!.currentHealth;
      playerMaxHealth.value = _character!.maxHealth;
      potionCount.value = _character!.healthPotions;
      enemyHealthPercent.value = _inCombat && _enemyMaxHealth > 0
          ? _enemyHealth / _enemyMaxHealth
          : 0.0;
    }
  }

  void _createNewCharacter() {
    _createNewCharacterWithBonuses();
  }

  /// Load enchanted equipment from storage
  Future<void> _loadEnchantedEquipment() async {
    // For now, initialize with empty list
    // In a full implementation, this would load from a Hive box
    _enchantedEquipment = [];
  }

  /// Save enchanted equipment to storage
  Future<void> _saveEnchantedEquipment() async {
    // For now, no-op
    // In a full implementation, this would save to a Hive box
  }

  /// Load equipment set items from storage
  Future<void> _loadSetEquipment() async {
    // For now, initialize with empty list
    // In a full implementation, this would load from a Hive box
    _setInventory = [];
    _equippedSetItems = [];
  }

  /// Save equipment set items to storage
  Future<void> _saveSetEquipment() async {
    // For now, no-op
    // In a full implementation, this would save to a Hive box
  }

  /// Load legendary equipment from storage
  Future<void> _loadLegendaryEquipment() async {
    // For now, initialize with empty list
    // The actual legendary items are stored in LegendaryCollection
    _legendaryInventory = [];
    _equippedLegendaries = [];
  }

  /// Save legendary equipment to storage
  Future<void> _saveLegendaryEquipment() async {
    // For now, no-op
    // The LegendaryCollection is saved automatically
  }

  Future<void> _calculateOfflineProgress() async {
    if (_gameState == null || _character == null) return;

    final validation = await _timeManager.validateOfflineTime(
      _gameState!.lastTrustedNtpTime,
      _gameState!.lastLocalTime,
    );

    if (validation.wasManipulated) {
      _log('Time manipulation detected. Progress capped.', immediate: true);
    }

    final offlineSeconds = validation.offlineSeconds;

    // Use automaton to calculate progress (8+ hour gate)
    final result = _automaton.calculateOfflineProgress(
      _character!,
      offlineSeconds,
      _character!.dungeonDepth,
    );

    if (result.didProcess) {
      // Apply XP and gold
      _character!.gainExperience(result.xpGained.toDouble());
      _character!.gold += result.goldGained;

      // Track for skill tree playstyle
      _skillTree?.recordGold(result.goldGained);

      _log('=== Offline Progress (8+ hours) ===', immediate: true);
      _log(result.summary, immediate: true);
      _log(
        'Gained: ${result.xpGained} XP, ${result.goldGained} gold',
        immediate: true,
      );
      if (result.deaths > 0) {
        _log('WARNING: Died ${result.deaths} times!', immediate: true);
      }

      // Log items found
      for (final item in result.itemsFound.take(5)) {
        _log('Found: ${item.name}', immediate: true);
      }
      if (result.itemsFound.length > 5) {
        _log(
          '...and ${result.itemsFound.length - 5} more items',
          immediate: true,
        );
      }
    } else if (offlineSeconds > 0) {
      // Less than 8 hours - just update focus
      final offlineMinutes = offlineSeconds ~/ 60;
      _gameState!.updateFocus(offlineMinutes, 0);
      _log(
        'Welcome back! ${offlineMinutes}m of idle time accumulated.',
        immediate: true,
      );
      _log('(8+ hours needed for combat progress)', immediate: true);
    }

    final snapshot = await _timeManager.getCurrentTimeSnapshot();
    _gameState!.lastTrustedNtpTime = snapshot['trusted']!;
    _gameState!.lastLocalTime = snapshot['local']!;
    _gameState!.save();
    _character!.save();
  }

  Timer? _enchantingTimer;
  Timer? _bossRiftTimer;
  Timer? _equipmentSetTimer;
  Timer? _transmutationTimer;
  Timer? _alchemyTimer;
  Timer? _legendaryTimer;
  Timer? _spiralTimer;

  void _startGameLoop() {
    _gameTimer?.cancel();
    _focusTimer?.cancel();
    _saveTimer?.cancel();
    _combatTimer?.cancel();
    _skillTreeTimer?.cancel();
    _guildHallTimer?.cancel();
    _enchantingTimer?.cancel();
    _professionTimer?.cancel();
    _transmutationTimer?.cancel();
    _alchemyTimer?.cancel();
    _legendaryTimer?.cancel();
    _spiralTimer?.cancel();

    _gameTimer = Timer.periodic(Duration(seconds: 5), (_) => _gameTick());
    _focusTimer = Timer.periodic(Duration(seconds: 30), (_) => _focusTick());
    _saveTimer = Timer.periodic(Duration(seconds: 60), (_) => _flushAndSave());
    _combatTimer = Timer.periodic(Duration(seconds: 1), (_) => _combatTick());
    _skillTreeTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _skillTreeTick(),
    );
    _guildHallTimer = Timer.periodic(
      Duration(minutes: 2),
      (_) => _guildHallTick(),
    );
    _enchantingTimer = Timer.periodic(
      Duration(minutes: 3),
      (_) => _enchantingTick(),
    );
    _professionTimer = Timer.periodic(
      Duration(minutes: 2),
      (_) => _professionTick(),
    );
    _bossRiftTimer = Timer.periodic(
      Duration(minutes: 5),
      (_) => _bossRiftTick(),
    );
    _equipmentSetTimer = Timer.periodic(
      Duration(minutes: 4),
      (_) => _equipmentSetTick(),
    );
    _transmutationTimer = Timer.periodic(
      Duration(minutes: 3),
      (_) => _transmutationTick(),
    );
    _alchemyTimer = Timer.periodic(
      Duration(seconds: 30),
      (_) => _alchemyTick(),
    );
    _legendaryTimer = Timer.periodic(
      Duration(minutes: 4),
      (_) => _legendaryTick(),
    );
    _spiralTimer = Timer.periodic(Duration(minutes: 5), (_) => _spiralTick());
  }

  /// Legendary items automation tick
  void _legendaryTick() {
    if (_legendaryItemService == null || _character == null) return;

    // Execute legendary automation
    final actions = _legendaryItemService!.executeAutomation(this);
    for (final action in actions) {
      _log(action, immediate: true);
    }

    _legendaryCollection?.save();
    notifyListeners();
  }

  /// Spiral automation tick - handles loop transitions and tale progress
  void _spiralTick() {
    if (_spiralService == null || _character == null) return;
    if (!AppFeatures.isEnabled(AppFeatures.infiniteSpiral)) return;

    // Execute spiral automation
    final actions = _spiralService!.executeAutomation(this);
    for (final action in actions) {
      _log(action, immediate: true);
    }

    _spiral?.save();
    notifyListeners();
  }

  /// Check for floor 100 and trigger spiral reset if needed
  void _checkSpiralFloorTrigger() {
    if (_spiralService == null || _character == null) return;
    if (!AppFeatures.isEnabled(AppFeatures.infiniteSpiral)) return;

    // Check if we reached floor 100
    if (_character!.dungeonDepth >= 100) {
      if (_spiral!.autoAdvanceEnabled && _spiral!.hasReachedFloor100) {
        // Execute reset
        final actions = _spiralService!.executeSpiralReset(this);
        for (final action in actions) {
          _log(action, immediate: true);
        }
      } else if (!_spiral!.hasReachedFloor100) {
        // First time reaching floor 100
        _spiralService!.checkFloor100Trigger(_gameState!, _character!);
        _log('🌀 Floor 100 reached! The Spiral awaits...', immediate: true);
        _log('Enable auto-advance to begin infinite looping.', immediate: true);
      }
    }
  }

  /// Process legendary drop from boss
  void _processLegendaryDrop(Boss boss) {
    if (_legendaryItemService == null || _character == null) return;

    final dropped = _legendaryItemService!.attemptDrop(boss, _character!);
    if (dropped != null) {
      _log('★ LEGENDARY DROP! ★', immediate: true);
      _log('${dropped.name} ${dropped.effect.type.icon}', immediate: true);
      _log(dropped.description, immediate: true);
      if (dropped.hasSentience) {
        _log('This item has sentience...', immediate: true);
        _log(dropped.sentience!.desireDescription, immediate: true);
      }
      notifyListeners();
    }
  }

  /// Transmutation automation tick
  void _transmutationTick() {
    if (_transmutationService == null || _character == null) return;
    if (!_inTown) return; // Only transmute in town

    // Auto-transmute excess items
    final transmutableItems = _getTransmutableInventory();
    final shouldTransmute = _transmutationService!.shouldAutoTransmute(
      totalInventoryItems: transmutableItems.length,
      maxInventorySize: 100,
      itemsByTier: _getItemsByTier(transmutableItems),
      isInTown: _inTown,
    );

    if (shouldTransmute) {
      final transmuteActions = _transmutationService!.executeAutoTransmute(
        itemsByTier: _groupItemsByTier(transmutableItems),
        onItemsConsumed: (tier, count) {
          // Handle item consumption
        },
        onItemsProduced: (tier, count) {
          // Handle item production
        },
      );

      for (final action in transmuteActions) {
        _log(action, immediate: true);
      }

      if (transmuteActions.isNotEmpty) {
        notifyListeners();
      }
    }

    _transmutationState?.save();
  }

  /// Alchemy automation tick
  void _alchemyTick() {
    if (_alchemyService == null || _character == null) return;

    // Update brewing progress
    _alchemyService!.updateBrewingProgress();

    // Collect completed brews
    final collected = _alchemyService!.collectAllCompleted();
    for (final potion in collected) {
      _log('Collected: ${potion.displayName}', immediate: true);
    }

    // Auto-brew if in town
    if (_inTown) {
      final shouldBrew = _alchemyService!.shouldAutoBrew(
        currentHealth: _character!.currentHealth,
        maxHealth: _character!.maxHealth,
        isInCombat: _inCombat,
        isBeforeBoss: _isBossFight,
        isInTown: _inTown,
      );

      if (shouldBrew) {
        final brewActions = _alchemyService!.executeAutoBrew(
          character: _character!,
          isBeforeBoss: _isBossFight,
        );

        for (final action in brewActions) {
          _log(action, immediate: true);
        }
      }
    }

    // Update active effects (remove expired)
    _alchemyState?.updateEffects();

    _alchemyState?.save();
    notifyListeners();
  }

  /// Helper: Get transmutable items from inventory
  List<TransmutableItem> _getTransmutableInventory() {
    // For now, return empty list
    // In full implementation, would gather from equipment, gems, materials
    return [];
  }

  /// Helper: Get items grouped by tier
  Map<ItemTier, int> _getItemsByTier(List<TransmutableItem> items) {
    final result = <ItemTier, int>{};
    for (final item in items) {
      result[item.tier] = (result[item.tier] ?? 0) + 1;
    }
    return result;
  }

  /// Helper: Group items by tier
  Map<ItemTier, List<TransmutableItem>> _groupItemsByTier(
    List<TransmutableItem> items,
  ) {
    final result = <ItemTier, List<TransmutableItem>>{};
    for (final item in items) {
      result.putIfAbsent(item.tier, () => []).add(item);
    }
    return result;
  }

  /// Boss/Rift automation tick
  void _bossRiftTick() {
    if (_character == null) return;

    // Check for boss on current floor when in dungeon
    if (!_inTown && !_inCombat) {
      final bossActions = _automaton.detectAndEvaluateBoss(
        _character!,
        _character!.dungeonDepth,
        _bossRiftService,
      );
      for (final action in bossActions) {
        _log(action, immediate: true);
      }

      // If boss detected and confidence high enough, start boss fight
      if (_bossRiftService?.currentBoss != null &&
          !_bossRiftService!.currentBoss!.isDefeated) {
        final confidence = _bossRiftService!.canAttemptBoss(
          _character!,
          _bossRiftService!.currentBoss!,
        );
        if (confidence >= 70.0) {
          _startBossCombat();
        }
      }
    }

    // Check for daily rift when in town
    if (_inTown) {
      final riftActions = _automaton.checkAndEvaluateRift(
        _character!,
        _bossRiftService,
        _inTown,
      );
      for (final action in riftActions) {
        _log(action, immediate: true);
      }
    }

    // Generate daily rift if needed
    _bossRiftService?.generateDailyRift();

    _bossRushState?.save();
  }

  /// Start boss combat
  void _startBossCombat() {
    if (_character == null || _bossRiftService?.currentBoss == null) return;
    if (_inTown) return;

    final boss = _bossRiftService!.currentBoss!;
    _isBossFight = true;
    _bossCombatTurns = 0;
    _inCombat = true;
    _isResting = false;

    _currentEnemy = boss.name;
    _currentEnemyType = 'Boss';
    _enemyMaxHealth = boss.maxHealth;
    _enemyHealth = boss.currentHealth;
    _enemyAttack = boss.damage;
    _enemyEvasion = boss.evasion;
    _enemyArmor = boss.armor;

    _log('★ BOSS FIGHT STARTED ★', immediate: true);
    _log('Facing: ${boss.name}', immediate: true);
    _log(
      'Mechanic: ${boss.mechanic.displayName} - ${boss.mechanic.description}',
      immediate: true,
    );
    _log(
      'HP: ${boss.maxHealth} | ATK: ${boss.damage} | AC: ${boss.armor}',
      immediate: true,
    );

    notifyListeners();
  }

  /// Resolve boss combat turn with mechanic handling
  void _resolveBossCombatTurn() {
    if (_character == null || _bossRiftService?.currentBoss == null) return;

    final boss = _bossRiftService!.currentBoss!;
    _bossCombatTurns++;

    // Process boss mechanic at start of turn
    final mechanicActions = _automaton.processBossCombatTick(
      _character!,
      boss,
      _bossRiftService!,
    );
    for (final action in mechanicActions) {
      _log(action);
    }

    // Handle shield mechanic - skip damage if shielded
    if (boss.mechanic == BossMechanic.shieldPhases && boss.isShielded) {
      _log('${boss.name} is shielded! Your attack is nullified!');
    }

    // Handle reflective damage
    if (boss.mechanic == BossMechanic.reflective) {
      // Calculate what damage we would deal
      final weaponType =
          RPGSystem.weaponTypes[_character!.weaponType] ??
          RPGSystem.weaponTypes['balanced']!;
      final baseDamage = weaponType.baseDamage + (_character!.strength ~/ 4);
      final playerDamage = RPGSystem.calculateWeaponDamage(
        baseDamage,
        _character!.strength,
        weaponType.strRequirement,
      );
      final reflected = boss.calculateReflectedDamage(playerDamage);
      if (reflected > 0) {
        _character!.takeDamage(reflected);
        _log(
          'Reflected damage! You take $reflected damage from ${boss.name}\'s shield!',
        );
      }
    }

    // Handle minion swarm - spawn adds periodically
    if (_bossRiftService!.shouldSpawnMinions(boss)) {
      _log('${boss.name} summons minions!', immediate: true);
      // Minions would add extra damage taken - simplified as a damage tick
      final minionDamage = (boss.damage * 0.2).round();
      _character!.takeDamage(minionDamage);
      _log('Minions attack for $minionDamage damage!');
    }

    notifyListeners();
  }

  /// End boss combat with rewards
  void _endBossCombat(bool victory) {
    if (_character == null || _bossRiftService?.currentBoss == null) return;

    final boss = _bossRiftService!.currentBoss!;

    if (victory) {
      // Award essences
      final essences = _bossRiftService!.awardEssences(boss);
      _log('★ BOSS DEFEATED ★', immediate: true);
      _log(
        'Dropped essences: ${essences.map((e) => e.icon).join(' ')}',
        immediate: true,
      );

      // Process legendary drop
      if (AppFeatures.isEnabled(AppFeatures.legendaryItems)) {
        _processLegendaryDrop(boss);
      }

      // Bonus XP and gold for boss kill
      final bonusXP = (50 + boss.floor * 5) * _gameState!.effectiveMultiplier;
      final bonusGold = boss.floor * 10;
      _character!.gainExperience(bonusXP);
      _character!.gold += bonusGold;
      _log(
        'Bonus rewards: +${bonusXP.toStringAsFixed(0)} XP, +$bonusGold gold',
        immediate: true,
      );
    } else {
      _log('Boss fight failed...', immediate: true);
    }

    _isBossFight = false;
    _bossCombatTurns = 0;
    _bossRushState?.save();
  }

  /// Auto-enchant equipment tick
  void _enchantingTick() {
    if (_enchantingService == null || _character == null) return;
    if (!_inTown) return; // Only enchant in town
    if (_enchantedEquipment.isEmpty) return;

    final playstyle = _skillTree?.playstyle ?? 'balanced';
    final enchantActions = _enchantingService!.executeAutoEnchant(
      _character!,
      _enchantedEquipment,
      playstyle,
      isInTown: _inTown,
    );

    for (final action in enchantActions) {
      _log(action, immediate: true);
    }

    if (enchantActions.isNotEmpty) {
      _saveEnchantedEquipment();
      notifyListeners();
    }
  }

  /// Profession tick - handles auto-crafting in town
  void _professionTick() {
    if (_professionService == null || _character == null) return;

    // Execute auto-craft when in town
    if (_inTown) {
      final craftActions = _professionService!.executeAutoCraft(_character!);
      for (final action in craftActions) {
        _log(action, immediate: true);
      }
      if (craftActions.isNotEmpty) {
        notifyListeners();
      }
    }

    _professionState?.save();
  }

  /// Equipment Set tick - handles auto-equip with set consideration
  void _equipmentSetTick() {
    if (_equipmentSetService == null || _character == null) return;

    // Only auto-equip when in town for safety
    if (!_inTown) return;

    final equipActions = _equipmentSetService!.executeAutoEquip(
      this,
      _setInventory,
      _equippedSetItems,
    );

    for (final action in equipActions) {
      _log(action, immediate: true);
    }

    if (equipActions.isNotEmpty) {
      _saveSetEquipment();
      notifyListeners();
    }

    _equipmentSetState?.save();
  }

  void _guildHallTick() {
    if (_guildHallService == null || _character == null) return;
    if (!_guildHallService!.isUnlocked) return;

    // Update wandering echo positions
    _guildHallService!.updateEchoPositions();

    // Automation: try to upgrade rooms based on playstyle
    final playstyle = _skillTree?.playstyle ?? 'balanced';
    final upgradeCost = _guildHallService!.executeAutomation(
      _character!.gold,
      playstyle,
    );
    if (upgradeCost > 0) {
      _character!.gold -= upgradeCost;
      final roomType = _guildHallService!.getAutomationDecision(playstyle);
      final room = _guildHallService!.getRoom(roomType ?? '');
      if (room != null) {
        _log(
          'Guild Hall upgraded: ${room.name} is now level ${room.level}',
          immediate: true,
        );
      }
    }

    _guildHall?.save();
    notifyListeners();
  }

  void _gameTick() {
    if (_character == null || _gameState == null) return;
    if (!_character!.isAlive) return;

    if (!_inCombat && !_isResting) {
      final encounterChance = 0.3 + (_character!.dungeonDepth * 0.05);
      if (ProceduralGenerator.rollPercent((encounterChance * 100).floor())) {
        _startCombat();
      }
    }

    _updateNotifiers();
    _flushLogs();
    notifyListeners();
  }

  void _skillTreeTick() {
    if (_skillTree == null) return;

    _skillTree!.updateProgress(1); // 1 minute of playtime
    _skillTree!.save();

    // Notify if a new skill was unlocked
    final available = _skillTree!.getAvailableNodes();
    if (available.isNotEmpty && _skillTree!.unlockProgress >= 0.99) {
      _log('Skill tree almost ready for next unlock...', immediate: true);
    }

    notifyListeners();
  }

  void _combatTick() {
    if (_character == null || _gameState == null) return;
    if (!_character!.isAlive) return;
    if (!_inCombat) return;

    // Apply corruption HP drain from equipped corrupted sets
    if (_equipmentSetService != null) {
      final corruptionDamage = _equipmentSetService!.calculateCorruptionDamage(
        _character!.maxHealth,
      );
      if (corruptionDamage > 0) {
        _character!.takeDamage(corruptionDamage);
        _log('Corruption drains $corruptionDamage HP');

        // Log set bonus if corruption is significant
        if (corruptionDamage >= _character!.maxHealth * 0.02) {
          _log('⚠️ Void Whisperers corruption intensifies!');
        }
      }
    }

    // Use automaton for combat decisions
    final ctx = AutomatonContext(
      currentDungeonDepth: _character!.dungeonDepth,
      isInCombat: _inCombat,
      isInTown: _inTown,
      equipmentSetService: _equipmentSetService,
      setInventory: _setInventory,
      equippedSetItems: _equippedSetItems,
    );

    final autoActions = _automaton.processCombatTurn(_character!, ctx);
    for (final action in autoActions) {
      _log(action);
    }

    // Profession gathering during combat
    _gatherProfessionMaterials();

    // Check if automaton decided to flee
    if (autoActions.any((a) => a.contains('Flee'))) {
      fleeToSurface();
      return;
    }

    // Automaton may have used potion, continue with combat
    if (_isBossFight) {
      _resolveBossCombatTurn();
    }
    _resolveCombatTurn();

    // Check if enemy died
    if (_enemyHealth <= 0) {
      if (_isBossFight) {
        _endBossCombat(true);
      }
      _endCombat(true);
      return;
    }

    // Check if player died
    if (!_character!.isAlive) {
      if (_isBossFight) {
        _endBossCombat(false);
      }
      _handleDeath();
      return;
    }

    _updateNotifiers();
    notifyListeners();
  }

  /// Gather materials from professions during combat
  void _gatherProfessionMaterials() {
    if (_professionService == null || _character == null) return;

    // Check if we're in focus mode (>80% focus for astral drops)
    final isFocusMode = (_gameState?.focusPercentage ?? 0) > 80.0;

    // Mining - gather ores
    final miningEvents = _professionService!.gatherMaterials(
      professionType: ProfessionType.mining,
      monsterType: _currentEnemyType,
      isFocusMode: isFocusMode,
      dungeonDepth: _character!.dungeonDepth,
    );
    for (final event in miningEvents) {
      if (event.isAstral) {
        _log(
          '★ Astral ${event.material.displayName} gathered!',
          immediate: true,
        );
      }
    }

    // Herbalism - gather herbs
    final herbalismEvents = _professionService!.gatherMaterials(
      professionType: ProfessionType.herbalism,
      monsterType: _currentEnemyType,
      isFocusMode: isFocusMode,
      dungeonDepth: _character!.dungeonDepth,
    );
    for (final event in herbalismEvents) {
      if (event.isAstral) {
        _log(
          '★ Astral ${event.material.displayName} gathered!',
          immediate: true,
        );
      }
    }

    // Skinning - only from beasts
    final beastTypes = ['wolf', 'bear', 'boar', 'stag', 'cat', 'rat', 'bat'];
    if (beastTypes.any(
      (type) => _currentEnemyType.toLowerCase().contains(type),
    )) {
      final skinningEvents = _professionService!.gatherMaterials(
        professionType: ProfessionType.skinning,
        monsterType: _currentEnemyType,
        isFocusMode: isFocusMode,
        dungeonDepth: _character!.dungeonDepth,
      );
      for (final event in skinningEvents) {
        if (event.isAstral) {
          _log(
            '★ Astral ${event.material.displayName} gathered!',
            immediate: true,
          );
        }
      }
    }

    _professionState?.save();
  }

  void _focusTick() {
    if (_gameState == null) return;

    if (_isInApp) {
      _gameState!.updateFocus(0, 30);
    } else {
      _gameState!.updateFocus(30, 0);
    }

    _gameState!.checkZenStreak();
    focusPercent.value = _gameState!.focusPercentage;
  }

  void _startCombat() {
    if (_character == null) return;
    if (_inTown) return; // No combat in town

    _inCombat = true;
    _isResting = false;

    final template = RPGSystem.generateMonster(
      _character!.dungeonDepth,
      _character!.level,
    );

    _currentEnemy = ProceduralGenerator.generateMonster(_character!.level);

    // Assign a random monster type for bestiary tracking
    final types = BestiaryData.monsterTypes.keys.toList();
    _currentEnemyType = types[_random.nextInt(types.length)];

    // Apply spiral multipliers if enabled
    if (_spiralService != null &&
        AppFeatures.isEnabled(AppFeatures.infiniteSpiral)) {
      final modifiedStats = _spiralService!.applySpiralMultipliers(
        template.health,
        template.damage,
      );
      _enemyMaxHealth = modifiedStats['health']!;
      _enemyHealth = modifiedStats['health']!;
      _enemyAttack = modifiedStats['damage']!;
    } else {
      _enemyMaxHealth = template.health;
      _enemyHealth = template.health;
      _enemyAttack = template.damage;
    }
    _enemyEvasion = template.evasion;
    _enemyArmor = template.armor;

    _log('Encountered: $_currentEnemy');
    _log(
      'Role: ${template.role} | HP: ${template.health} | EV: ${template.evasion} | AC: ${template.armor}',
    );

    notifyListeners();
  }

  void _resolveCombatTurn() {
    if (_character == null) return;

    final char = _character!;
    final weaponType =
        RPGSystem.weaponTypes[char.weaponType] ??
        RPGSystem.weaponTypes['balanced']!;
    final armorType =
        RPGSystem.armorTypes[char.armorType] ??
        RPGSystem.armorTypes['leather']!;

    final playerAccuracy =
        RPGSystem.calculateAccuracy(
          char.weaponSkill,
          char.fightingSkill,
          char.dexterity,
        ) +
        weaponType.accuracyBonus;

    final playerEvasion = RPGSystem.calculateEvasion(
      char.dexterity,
      char.dodgingSkill,
      armorType.encumbrance,
    );

    final playerAC = armorType.armorClass + (char.armorSkill ~/ 3);

    final baseDamage = weaponType.baseDamage + (char.strength ~/ 4);
    final playerDamage = RPGSystem.calculateWeaponDamage(
      baseDamage,
      char.strength,
      weaponType.strRequirement,
    );

    final playerHitChance = RPGSystem.getHitChance(
      playerAccuracy,
      _enemyEvasion,
    );
    if (RPGSystem.attemptHit(playerAccuracy, _enemyEvasion)) {
      final damageDealt = RPGSystem.applyArmorReduction(
        playerDamage,
        _enemyArmor,
      );
      _enemyHealth -= damageDealt;
      _log(
        'You hit $_currentEnemy for $damageDealt dmg ($playerHitChance% to hit)',
      );
      char.gainSkillXP('weapon', 1);

      if (_enemyHealth <= 0) {
        // Record companion kills
        for (final companion in _companionRoster?.activeCompanions ?? []) {
          companion.kills++;
          companion.gainExperience(10);
        }
        _endCombat(true);
        return;
      }
    } else {
      _log('You miss $_currentEnemy! ($playerHitChance% to hit)');
    }

    // Companion attacks
    _processCompanionCombat();

    final monsterHitChance = RPGSystem.getHitChance(
      _enemyAttack + 10,
      playerEvasion,
    );
    if (RPGSystem.attemptHit(_enemyAttack + 10, playerEvasion)) {
      final damageTaken = RPGSystem.applyArmorReduction(_enemyAttack, playerAC);
      char.takeDamage(damageTaken);
      _log(
        '$_currentEnemy hits you for $damageTaken dmg ($monsterHitChance% to hit)',
      );
      char.gainSkillXP('armor', 1);
      char.gainSkillXP('dodging', 1);

      if (!char.isAlive) {
        _handleDeath();
        return;
      }
    } else {
      _log('$_currentEnemy misses you! ($monsterHitChance% to hit)');
      char.gainSkillXP('dodging', 2);
    }

    char.gainSkillXP('fighting', 1);
  }

  void _processCompanionCombat() {
    for (final companion in _companionRoster?.activeCompanions ?? []) {
      // Check for sacrifice
      if (_character != null &&
          _character!.currentHealth < _character!.maxHealth * 0.2) {
        if (companion.willSacrifice) {
          companion.takeDamage(companion.currentHealth);
          _character!.currentHealth = _character!.maxHealth ~/ 2;
          _companionRoster?.recordSacrifice();
          _log(
            '${companion.name} sacrificed themselves to save you!',
            immediate: true,
          );
          continue;
        }
      }

      if (!companion.isActive) continue;

      // Companion attacks
      if (_random.nextDouble() < 0.7) {
        // 70% hit chance
        final damage = companion.attack;
        _enemyHealth = (_enemyHealth - damage).toInt();
        _log('${companion.name} hits for $damage dmg');

        if (_enemyHealth <= 0) {
          companion.kills++;
          companion.gainExperience(10);
          _endCombat(true);
          return;
        }
      } else {
        _log('${companion.name} misses!');
      }
    }
  }

  void _endCombat(bool victory) {
    if (_character == null) return;

    if (victory) {
      // Apply Guild Hall bonuses to XP and gold
      final guildBonuses = _guildHallService?.getBonuses();
      final xpMultiplier = guildBonuses?['skillXpMultiplier'] ?? 1.0;
      final goldMultiplier = guildBonuses?['goldFindMultiplier'] ?? 1.0;

      // Calculate base rewards
      double expGain =
          (10 +
              ProceduralGenerator.rollDice(10) +
              (_character!.dungeonDepth * 2)) *
          _gameState!.effectiveMultiplier *
          xpMultiplier;
      double goldGain =
          ((ProceduralGenerator.rollDice(20) + _character!.dungeonDepth) *
                  goldMultiplier)
              .toDouble();

      // Apply spiral multipliers if enabled
      if (_spiralService != null &&
          AppFeatures.isEnabled(AppFeatures.infiniteSpiral)) {
        final spiralRewards = _spiralService!.applyRewardMultipliers(
          expGain,
          goldGain,
        );
        expGain = spiralRewards['xp']!;
        goldGain = spiralRewards['gold']!;

        // Track spiral progress
        _spiralService!.onGoldFound(goldGain.round());
        _spiralService!.onKill();

        // Check for dragon kill
        if (_currentEnemyType.toLowerCase().contains('dragon')) {
          _spiralService!.onDragonKilled();
        }

        // Check for tale completions
        final taleActions = _spiralService!.checkTaleProgress(this);
        for (final action in taleActions) {
          _log(action, immediate: true);
        }
      }

      _character!.gold += goldGain.round();
      _character!.gainExperience(expGain);

      // Track for skill tree playstyle
      _skillTree?.recordKill();
      _skillTree?.recordGold(goldGain.round());

      // Track for bestiary
      final newKnowledge =
          _bestiary?.recordKill(_currentEnemyType, _currentEnemy) ?? false;
      if (newKnowledge) {
        _log(
          '★ Bestiary Updated: Knowledge gained about ${_currentEnemyType}!',
          immediate: true,
        );
      }

      // Record victory for companions
      for (final companion in _companionRoster?.activeCompanions ?? []) {
        companion.recordVictory();
        companion.gainExperience(20);
      }

      _log('Victory! +${expGain.toStringAsFixed(1)} XP, +$goldGain gold');
      _log(
        'Skills: W(${_character!.weaponSkill}) F(${_character!.fightingSkill}) A(${_character!.armorSkill}) D(${_character!.dodgingSkill})',
      );

      if (ProceduralGenerator.rollPercent(30)) {
        _character!.healthPotions += 1;
        _log('Found: Health Potion');
      }

      if (ProceduralGenerator.rollPercent(15)) {
        _upgradeEquipment();
      }
    }

    _inCombat = false;
    _currentEnemy = '';

    // Use automaton for post-combat decisions
    final autoActions = _automaton.processPostCombat(_character!, victory);
    for (final action in autoActions) {
      _log(action);
    }

    // Check if automaton wants to return to town
    if (autoActions.any((a) => a.contains('returning to town'))) {
      Future.delayed(Duration(seconds: 1), () {
        returnToTown();
      });
    }

    _updateNotifiers();
    _flushAndSave();
    notifyListeners();
  }

  void _upgradeEquipment() {
    if (_character == null) return;

    // Apply Guild Hall equipment drop bonus
    final guildBonuses = _guildHallService?.getBonuses();
    final equipMultiplier = guildBonuses?['equipmentDropMultiplier'] ?? 1.0;
    final dropChance = (15 * equipMultiplier).round();

    if (!ProceduralGenerator.rollPercent(dropChance)) return;

    final weapons = ['quick', 'balanced', 'heavy', 'precise'];
    final armors = ['cloth', 'leather', 'chain', 'plate'];

    if (ProceduralGenerator.rollPercent(50)) {
      final current = weapons.indexOf(_character!.weaponType);
      if (current < weapons.length - 1) {
        _character!.weaponType = weapons[current + 1];
        final type = RPGSystem.weaponTypes[_character!.weaponType]!;
        _log('Found better weapon: ${type.name}!');
      }
    } else {
      final current = armors.indexOf(_character!.armorType);
      if (current < armors.length - 1) {
        _character!.armorType = armors[current + 1];
        final type = RPGSystem.armorTypes[_character!.armorType]!;
        _log('Found better armor: ${type.name}!');
      }
    }
  }

  void _handleDeath() {
    if (_character == null) return;

    // Calculate potential echo shards
    _pendingEchoShards =
        _gameState?.calculateEchoShards(
          _character!.experience,
          _character!.level,
          _character!.totalDeaths,
        ) ??
        0;

    // Offer ascension if we have meaningful progress
    if (_pendingEchoShards >= 10) {
      _ascensionAvailable = true;
      _log('★ ASCENSION AVAILABLE ★', immediate: true);
      _log(
        'You can ascend with $_pendingEchoShards Echo Shards',
        immediate: true,
      );
      _log('Or respawn and keep trying...', immediate: true);
    } else {
      // Not enough progress - auto-respawn
      _performRespawn();
    }

    _inCombat = false;
    _currentEnemy = '';
    _updateNotifiers();
    _flushAndSave();
    notifyListeners();
  }

  void _performRespawn() {
    if (_character == null) return;

    // Use automaton for death handling
    final autoActions = _automaton.processDeath(_character!);
    for (final action in autoActions) {
      _log(action, immediate: true);
    }

    // Return to town automatically after death
    _inTown = true;
    _character!.isAlive = true;
    _character!.healthPotions = max(3, _character!.healthPotions);

    _ascensionAvailable = false;
    _pendingEchoShards = 0;
  }

  /// Perform ascension - convert character to permanent progress
  void performAscension() {
    if (_character == null || _gameState == null) return;

    _log('☆ ASCENSION COMPLETE ☆', immediate: true);
    _log(
      'Converted progress to $_pendingEchoShards Echo Shards',
      immediate: true,
    );

    // Add Echo to Guild Hall before character is reset
    if (_guildHallService != null) {
      final fate = 'Ascended at level ${_character!.level}';
      _guildHallService!.addEcho(_character!, fate: fate);
      _log(
        '${(_character!.name)} now wanders the Guild Hall as an Echo',
        immediate: true,
      );

      // Unlock Guild Hall on first ascension
      if (_gameState!.totalAscensions == 0) {
        _guildHallService!.unlock();
        _log('★ Guild Hall Unlocked! ★', immediate: true);
        _log(
          'Visit the Echo Sanctuary to upgrade rooms and see your past heroes.',
          immediate: true,
        );
      }
      _guildHall?.save();
    }

    // Perform the ascension
    _gameState!.ascend(
      _character!.experience,
      _character!.level,
      _character!.totalDeaths,
    );

    // Reset character with meta-bonuses
    _createNewCharacterWithBonuses();

    _ascensionAvailable = false;
    _pendingEchoShards = 0;
    _inTown = true;
    _inCombat = false;
    _currentEnemy = '';

    _log('Your Echo lives on...', immediate: true);
    _log('Total Ascensions: ${_gameState!.totalAscensions}', immediate: true);
    _log('Echo Shards: ${_gameState!.echoShards}', immediate: true);

    _updateNotifiers();
    _flushAndSave();
    notifyListeners();
  }

  /// Decline ascension and just respawn
  void declineAscension() {
    _log('You chose to continue...', immediate: true);
    _performRespawn();
    _updateNotifiers();
    _flushAndSave();
    notifyListeners();
  }

  void _createNewCharacterWithBonuses() {
    final bonuses =
        _gameState?.getStartingBonuses() ??
        {
          'hpMultiplier': 1.0,
          'bonusPotions': 0,
          'xpMultiplier': 1.0,
          'startingDepth': 1,
        };

    final race = ProceduralGenerator.generateRace();
    final characterClass = ProceduralGenerator.generateClass();

    _character = Character.create('Hero', race, characterClass);

    // Apply meta-bonuses
    final hpMult = bonuses['hpMultiplier'] as double;
    _character!.maxHealth = (_character!.maxHealth * hpMult).round();
    _character!.currentHealth = _character!.maxHealth;

    _character!.healthPotions += bonuses['bonusPotions'] as int;
    _character!.dungeonDepth = bonuses['startingDepth'] as int;

    _characterBox.put('main', _character!);
    _combatLogBox.put('log', CombatLog());

    _log(
      'New Hero created with ${((hpMult - 1.0) * 100).round()}% bonus HP',
      immediate: true,
    );
    _log('Starting depth: ${_character!.dungeonDepth}', immediate: true);
  }

  /// Create a custom character from the character creation screen
  void createCustomCharacter({
    required String name,
    required String race,
    required String characterClass,
    required Map<String, int> stats,
  }) {
    // Create base character
    _character = Character.create(name, race, characterClass);

    // Apply rolled stats to core attributes
    if (stats.containsKey('STR')) {
      _character!.strength = stats['STR']!;
    }
    if (stats.containsKey('DEX')) {
      _character!.dexterity = stats['DEX']!;
    }
    if (stats.containsKey('CON')) {
      _character!.constitution = stats['CON']!;
      // Recalculate HP based on CON
      final conBonus = (_character!.constitution - 10) ~/ 2;
      _character!.maxHealth = (8 + conBonus).clamp(1, 999);
      _character!.currentHealth = _character!.maxHealth;
    }
    if (stats.containsKey('INT')) {
      _character!.intelligence = stats['INT']!;
      // Recalculate MP based on INT + WIS
      _character!.maxMana = (_character!.intelligence + _character!.wisdom)
          .clamp(0, 999);
      _character!.currentMana = _character!.maxMana;
    }
    if (stats.containsKey('WIS')) {
      _character!.wisdom = stats['WIS']!;
      // Recalculate MP based on INT + WIS
      _character!.maxMana = (_character!.intelligence + _character!.wisdom)
          .clamp(0, 999);
      _character!.currentMana = _character!.maxMana;
    }
    if (stats.containsKey('CHA')) {
      _character!.charisma = stats['CHA']!;
    }

    // Apply meta-bonuses from ascension
    final bonuses =
        _gameState?.getStartingBonuses() ??
        {
          'hpMultiplier': 1.0,
          'bonusPotions': 0,
          'xpMultiplier': 1.0,
          'startingDepth': 1,
        };

    final hpMult = bonuses['hpMultiplier'] as double;
    _character!.maxHealth = (_character!.maxHealth * hpMult).round();
    _character!.currentHealth = _character!.maxHealth;

    _character!.healthPotions += bonuses['bonusPotions'] as int;
    _character!.dungeonDepth = bonuses['startingDepth'] as int;

    _characterBox.put('main', _character!);
    _combatLogBox.put('log', CombatLog());

    _log('Welcome, $name the $race $characterClass!', immediate: true);
    _log('Your adventure begins... probably poorly.', immediate: true);

    _updateNotifiers();
    _flushAndSave();
    notifyListeners();
  }

  bool useHealthPotion() {
    if (_character == null) return false;
    if (!_inCombat && !_isResting) return false;

    if (_character!.useHealthPotion()) {
      _log('Used Potion! +${_character!.maxHealth ~/ 2} HP');
      _updateNotifiers();
      notifyListeners();
      return true;
    }
    return false;
  }

  void rest() {
    if (_character == null) return;
    if (_inCombat) {
      _log('Cannot rest in combat!', immediate: true);
      return;
    }

    _isResting = true;
    _character!.rest();
    _log('Resting... +${_character!.maxHealth ~/ 4} HP', immediate: true);
    _updateNotifiers();

    Future.delayed(Duration(seconds: 3), () {
      _isResting = false;
      _log('Rest complete.', immediate: true);
    });

    _flushAndSave();
    notifyListeners();
  }

  void fleeToSurface() {
    if (_character == null) return;

    _log('Fleeing to surface!', immediate: true);

    // Companions witness flee - loyalty drops
    for (final companion in _companionRoster?.companions ?? []) {
      companion.witnessFlee();
      if (companion.willDesert) {
        _companionRoster?.remove(companion);
        _companionRoster?.recordDesertion();
        _log(
          '${companion.name} has deserted due to cowardice!',
          immediate: true,
        );
      }
    }

    // Track for skill tree playstyle
    _skillTree?.recordFlee();

    _inCombat = false;
    _isResting = false;
    _currentEnemy = '';

    _character!.dungeonDepth = 1;
    _character!.currentHealth = max(1, _character!.currentHealth ~/ 2);
    _updateNotifiers();

    _flushAndSave();
    notifyListeners();
  }

  void _log(String message, {bool immediate = false}) {
    _pendingLogEntries.add(message);
    if (immediate) {
      _flushLogs();
    }
  }

  void _flushLogs() {
    if (_pendingLogEntries.isEmpty) return;

    for (final entry in _pendingLogEntries) {
      _combatLog?.addEntry(entry);
    }
    _pendingLogEntries.clear();
  }

  void _flushAndSave() {
    _flushLogs();
    _character?.save();
    _gameState?.save();
    _combatLog?.save();
    _bestiary?.save();
    _companionRoster?.save();
    _guildHall?.save();
    _bossRushState?.save();
    _professionState?.save();
    _transmutationState?.save();
    _alchemyState?.save();
    _spiral?.save();
  }

  void recordInteraction() {
    _gameState?.recordInteraction();
    focusPercent.value = _gameState?.focusPercentage ?? 0.0;
    notifyListeners();
  }

  void onAppPause() {
    _isInApp = false;
    _flushAndSave();
  }

  void onAppResume() {
    _isInApp = true;
    _calculateOfflineProgress();
  }

  void levelUpCharacter() {
    if (_character == null || _character!.unallocatedPoints == 0) return;

    _character!.levelUp();
    _updateNotifiers();
    _log('Level up! Now level ${_character!.level}', immediate: true);
    _flushAndSave();
    notifyListeners();
  }

  void allocateStat(String stat, int points) {
    if (_character == null || _character!.unallocatedPoints < points) return;

    switch (stat.toLowerCase()) {
      case 'strength':
        _character!.strength += points;
        break;
      case 'dexterity':
        _character!.dexterity += points;
        break;
      case 'intelligence':
        _character!.intelligence += points;
        break;
      case 'constitution':
        _character!.constitution += points;
        _character!.maxHealth += points * 5;
        _character!.currentHealth += points * 5;
        break;
    }

    _character!.unallocatedPoints -= points;
    _character!.save();
    _updateNotifiers();
    notifyListeners();
  }

  /// Purchase a meta-upgrade with Echo Shards
  bool purchaseUpgrade(String type) {
    if (_gameState == null) return false;

    final success = _gameState!.purchaseUpgrade(type);
    if (success) {
      _log('Purchased upgrade: $type', immediate: true);
      _gameState!.save();
      notifyListeners();
    }
    return success;
  }

  void descendDeeper() {
    if (_character == null || _inCombat) return;

    _character!.dungeonDepth++;

    // Track spiral floor progress
    if (_spiralService != null &&
        AppFeatures.isEnabled(AppFeatures.infiniteSpiral)) {
      _spiralService!.onFloorReached(_character!.dungeonDepth);

      // Check for floor 100 trigger
      if (_character!.dungeonDepth >= 100) {
        _checkSpiralFloorTrigger();
      }
    }

    // Generate new dungeon for deeper level
    _currentDungeonSeed = _character!.dungeonDepth;
    _dungeonGenerator = DungeonGenerator(
      width: 60,
      height: 18,
      seed: _currentDungeonSeed,
    );
    _updateRenderer();
    _log('Descending to level ${_character!.dungeonDepth}...', immediate: true);
    _character!.save();
    notifyListeners();
  }

  Character? get character => _character;
  GameState? get gameState => _gameState;
  CombatLog? get combatLog => _combatLog;
  bool get isInCombat => _inCombat;
  bool get isResting => _isResting;
  bool get isAtCriticalHealth => _character?.isAtCriticalHealth ?? false;
  String get currentEnemy => _currentEnemy;
  int get enemyHealth => _enemyHealth;
  int get enemyMaxHealth => _enemyMaxHealth;
  int get enemyAttack => _enemyAttack;
  int get enemyEvasion => _enemyEvasion;
  int get enemyArmor => _enemyArmor;
  double get effectiveMultiplier => _gameState?.effectiveMultiplier ?? 1.0;
  int get zenStreakDays => _gameState?.zenStreakDays ?? 0;

  // Town/Dungeon state
  bool get inTown => _inTown;
  bool get ascensionAvailable => _ascensionAvailable;
  int get pendingEchoShards => _pendingEchoShards;
  String get currentLocation => _inTown
      ? '🏘️ Town'
      : '⛏️ Dungeon Level ${_character?.dungeonDepth ?? 1}';
  DungeonGenerator? get dungeonGenerator => _dungeonGenerator;
  TownGenerator? get townGenerator => _townGenerator;
  DungeonRenderer? get dungeonRenderer => _cachedRenderer;

  // Spiral getters
  InfiniteSpiral? get spiral => _spiral;
  SpiralService? get spiralService => _spiralService;
  bool get showSpiral =>
      AppFeatures.isEnabled(AppFeatures.infiniteSpiral) &&
      (_spiral?.hasReachedFloor100 ?? false);
  bool get isInSpiral => _spiral?.isInSpiral ?? false;
  int get currentSpiralLoop => _spiral?.currentLoop.loopNumber ?? 1;

  void _updateRenderer() {
    if (_inTown) {
      _cachedRenderer = _townGenerator != null
          ? DungeonRenderer.town(_townGenerator!)
          : null;
    } else {
      _cachedRenderer = _dungeonGenerator != null
          ? DungeonRenderer.dungeon(_dungeonGenerator!)
          : null;
    }
  }

  String get currentMap {
    if (_inTown) {
      _townGenerator ??= TownGenerator(
        width: 50,
        height: 15,
        seed: DateTime.now().day,
      );
      return _townGenerator!.render();
    }
    _dungeonGenerator ??= DungeonGenerator(
      width: 60,
      height: 18,
      seed: _currentDungeonSeed == 0
          ? (_character?.dungeonDepth ?? 1)
          : _currentDungeonSeed,
    );
    return _dungeonGenerator!.render();
  }

  List<String> get recentCombatEntries => _combatLog?.recentEntries ?? [];

  /// Enter the dungeon from town
  void enterDungeon() {
    if (_character == null) return;
    if (!_inTown) return; // Already in dungeon

    _inTown = false;
    // Generate new dungeon for current level
    _currentDungeonSeed = _character!.dungeonDepth;
    _dungeonGenerator = DungeonGenerator(
      width: 60,
      height: 18,
      seed: _currentDungeonSeed,
    );
    _updateRenderer();
    _log('Entering the dungeon...', immediate: true);
    _log(
      'You are now at dungeon level ${_character!.dungeonDepth}',
      immediate: true,
    );
    notifyListeners();
  }

  /// Return to town from dungeon
  void returnToTown() {
    if (_character == null) return;
    if (_inTown) return; // Already in town
    if (_inCombat) {
      _log('Cannot return to town while in combat!', immediate: true);
      return;
    }

    _inTown = true;
    _updateRenderer();
    _log('Returning to town...', immediate: true);
    _log('Welcome back to safety.', immediate: true);
    _character!.currentHealth = _character!.maxHealth; // Heal in town
    _character!.currentMana = _character!.maxMana;

    // Heal companions and process maintenance
    for (final companion in _companionRoster?.companions ?? []) {
      companion.heal(companion.maxHealth);
    }

    // Process daily maintenance
    final maintenanceLogs = processCompanionMaintenance();
    for (final log in maintenanceLogs) {
      _log(log, immediate: true);
    }

    _updateNotifiers();
    _flushAndSave();
    notifyListeners();
  }

  /// Browse shops in town - uses automaton for decisions
  void browseShops() {
    if (_character == null) return;
    if (!_inTown) {
      _log('No shops in the dungeon!', immediate: true);
      return;
    }

    _log('Browsing the shops...', immediate: true);

    // Use automaton for town activities
    final inventory = <Equipment>[]; // Would come from actual inventory storage
    final playstyle = _skillTree?.playstyle ?? 'balanced';
    final autoActions = _automaton.processTownVisit(
      _character!,
      inventory,
      enchantedEquipment: _enchantedEquipment,
      enchantingService: _enchantingService,
      professionService: _professionService,
      transmutationService: _transmutationService,
      alchemyService: _alchemyService,
      transmutableItems: _getTransmutableInventory(),
      playstyle: playstyle,
      isInTown: _inTown,
      isBeforeBoss: _isBossFight,
    );

    for (final action in autoActions) {
      _log(action, immediate: true);
    }

    // Also do some random shop browsing
    if (ProceduralGenerator.rollPercent(30)) {
      _log('Found a health potion for sale!', immediate: true);
      if (_character!.gold >= 50) {
        _character!.gold -= 50;
        _character!.healthPotions++;
        _log('Bought: Health Potion (-50 gold)', immediate: true);
      } else {
        _log('Not enough gold! (Need 50)', immediate: true);
      }
    } else if (ProceduralGenerator.rollPercent(20)) {
      _log('Found a skill trainer!', immediate: true);
      _log('Weapon skill +1 through training!', immediate: true);
      _character!.gainSkillXP('weapon', 50);
    }

    _updateNotifiers();
    _character!.save();
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _focusTimer?.cancel();
    _saveTimer?.cancel();
    _combatTimer?.cancel();
    _skillTreeTimer?.cancel();
    _guildHallTimer?.cancel();
    _enchantingTimer?.cancel();
    _bossRiftTimer?.cancel();
    _professionTimer?.cancel();
    _equipmentSetTimer?.cancel();
    _transmutationTimer?.cancel();
    _alchemyTimer?.cancel();
    _flushAndSave();
    enemyHealthPercent.dispose();
    focusPercent.dispose();
    playerHealth.dispose();
    playerMaxHealth.dispose();
    potionCount.dispose();
    super.dispose();
  }

  SkillTree? get skillTree => _skillTree;
  Bestiary? get bestiary => _bestiary;
  CompanionRoster? get companionRoster => _companionRoster;
  GuildHall? get guildHall => _guildHall;
  GuildHallService? get guildHallService => _guildHallService;

  /// Check if Guild Hall should be visible (unlocked and has ascensions)
  bool get showGuildHall =>
      _guildHallService?.shouldShow(_gameState?.totalAscensions ?? 0) ?? false;

  // ==================== BOSS RUSH GETTERS AND METHODS ====================

  BossRushState? get bossRushState => _bossRushState;
  BossRiftService? get bossRiftService => _bossRiftService;
  Boss? get currentBoss => _bossRiftService?.currentBoss;
  Rift? get dailyRift => _bossRiftService?.dailyRift;
  bool get isBossFight => _isBossFight;
  int get bossCombatTurns => _bossCombatTurns;
  Map<EssenceType, int> get essenceInventory =>
      _bossRiftService?.essenceInventory ?? {};
  int get totalEssences => _bossRiftService?.totalEssences ?? 0;
  List<Boss> get defeatedBosses => _bossRiftService?.defeatedBosses ?? [];
  List<Rift> get riftHistory => _bossRiftService?.riftHistory ?? [];

  /// Check if Boss Rush should be shown
  bool get showBossRush =>
      (_character?.level ?? 0) >= 5 ||
      (_bossRushState?.totalBossesDefeated ?? 0) > 0;

  /// Generate boss for current floor
  Boss? generateBossForFloor(int floor) {
    return _bossRiftService?.generateBoss(floor);
  }

  /// Start manual boss fight
  void startBossFight() {
    if (_character == null) return;
    final floor = _character!.dungeonDepth;
    final boss = _bossRiftService?.generateBoss(floor);
    if (boss != null) {
      _startBossCombat();
    }
  }

  /// Skip current boss
  void skipBoss() {
    if (_bossRiftService?.currentBoss != null) {
      _log(
        'Skipped boss ${_bossRiftService!.currentBoss!.name}',
        immediate: true,
      );
      _bossRushState?.currentBoss = null;
      _bossRushState?.save();
      notifyListeners();
    }
  }

  /// Attempt daily rift
  void attemptDailyRift() {
    final rift = _bossRiftService?.dailyRift;
    if (rift == null) return;

    _log('Entering Rift "${rift.name}"!', immediate: true);
    _log('Modifier: ${rift.modifier.displayName}', immediate: true);
    // Rift combat would be implemented here - simplified for now
    notifyListeners();
  }

  /// Use essences for crafting
  bool useEssences(EssenceType type, int amount) {
    final result = _bossRiftService?.useEssences(type, amount) ?? false;
    if (result) {
      _bossRushState?.save();
      notifyListeners();
    }
    return result;
  }

  /// Upgrade a Guild Hall room
  bool upgradeGuildHallRoom(String roomType) {
    if (_guildHallService == null || _character == null) return false;
    if (!_guildHallService!.canAfford(roomType, _character!.gold)) return false;

    final cost = _guildHallService!.buildRoom(roomType);
    if (cost > 0) {
      _character!.gold -= cost;
      final room = _guildHallService!.getRoom(roomType);
      _log(
        'Upgraded ${room?.name ?? roomType} to level ${room?.level ?? 0} (-$cost gold)',
        immediate: true,
      );
      _guildHall?.save();
      _character!.save();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Hire a companion
  void hireCompanion(Companion companion) {
    if (_companionRoster == null) return;
    if (_character == null) return;

    if (_companionRoster!.canHire && _character!.gold >= companion.hireCost) {
      _character!.gold -= companion.hireCost;
      _companionRoster!.hire(companion);
      _log(
        'Hired ${companion.name} the ${companion.role} for ${companion.hireCost} gold',
        immediate: true,
      );
      _flushAndSave();
      notifyListeners();
    } else {
      _log(
        'Cannot hire companion: not enough gold or roster full',
        immediate: true,
      );
    }
  }

  /// Dismiss a companion
  void dismissCompanion(Companion companion) {
    if (_companionRoster == null) return;

    _companionRoster!.remove(companion);
    _log('Dismissed ${companion.name}', immediate: true);
    _flushAndSave();
    notifyListeners();
  }

  /// Get available companions in town
  List<Companion> getAvailableCompanions() {
    if (_character == null) return [];
    return CompanionMarket.generateAvailable(_character!.level);
  }

  /// Process companion daily maintenance
  List<String> processCompanionMaintenance() {
    if (_companionRoster == null || _character == null) return [];

    final logs = _companionRoster!.dailyMaintenance(_character!.gold);
    _character!.save();
    _companionRoster!.save();
    return logs;
  }

  // ==================== ENCHANTING GETTERS AND METHODS ====================

  EnchantingService? get enchantingService => _enchantingService;
  List<EnchantedEquipment> get enchantedEquipment => _enchantedEquipment;

  /// Add an enchanted equipment item
  void addEnchantedEquipment(EnchantedEquipment equipment) {
    _enchantedEquipment.add(equipment);
    _saveEnchantedEquipment();
    notifyListeners();
  }

  /// Remove an enchanted equipment item
  void removeEnchantedEquipment(EnchantedEquipment equipment) {
    _enchantedEquipment.remove(equipment);
    _saveEnchantedEquipment();
    notifyListeners();
  }

  /// Socket a gem into equipment
  bool socketGem(EnchantedEquipment equipment, int socketIndex, Gem gem) {
    if (_enchantingService == null) return false;
    final result = _enchantingService!.socketGem(equipment, socketIndex, gem);
    if (result) {
      _saveEnchantedEquipment();
      notifyListeners();
    }
    return result;
  }

  /// Remove a gem from equipment
  Gem? removeGem(EnchantedEquipment equipment, int socketIndex) {
    if (_enchantingService == null) return null;
    final gem = _enchantingService!.removeGem(equipment, socketIndex);
    if (gem != null) {
      _saveEnchantedEquipment();
      notifyListeners();
    }
    return gem;
  }

  /// Enchant an item
  EnchantmentResult enchantItem(EnchantedEquipment equipment) {
    if (_enchantingService == null) {
      return EnchantmentResult.failure('Enchanting service not available');
    }
    final result = _enchantingService!.enchant(equipment);
    _saveEnchantedEquipment();
    notifyListeners();
    return result;
  }

  /// Get the risk of enchanting an item
  String getEnchantmentRisk(EnchantedEquipment equipment) {
    if (_enchantingService == null) return '0%';
    return _enchantingService!.getRiskDisplay(equipment);
  }

  /// Get all enchantable items
  List<EnchantedEquipment> getEnchantableItems() {
    if (_enchantingService == null) return [];
    return _enchantingService!.getEnchantableItems(
      _enchantedEquipment,
      isInTown: _inTown,
    );
  }

  /// Get total bonuses from all enchanted equipment
  Map<String, double> getTotalEnchantmentBonuses() {
    final total = <String, double>{};
    for (final equipment in _enchantedEquipment) {
      final bonuses = equipment.calculateTotalBonuses();
      bonuses.forEach((stat, value) {
        total[stat] = (total[stat] ?? 0) + value;
      });
    }
    return total;
  }

  // ==================== PROFESSION GETTERS AND METHODS ====================

  ProfessionState? get professionState => _professionState;
  ProfessionService? get professionService => _professionService;

  /// Get all professions
  List<Profession> get professions => _professionState?.professions ?? [];

  /// Get profession inventory
  Map<MaterialType, int> get professionInventory =>
      _professionState?.inventory ?? {};

  /// Get recent gather log
  List<String> get recentGatherLog => _professionState?.recentGatherLog ?? [];

  /// Get total crafts completed
  int get totalCraftsCompleted => _professionState?.totalCraftsCompleted ?? 0;

  /// Get astral material count
  int get astralMaterialCount => _professionState?.astralMaterialCount ?? 0;

  /// Get profession inventory value
  int get professionInventoryValue => _professionState?.inventoryValue ?? 0;

  /// Toggle auto-crafting
  void toggleProfessionAutoCraft() {
    _professionService?.toggleAutoCraft();
    notifyListeners();
  }

  /// Get auto-craft status
  bool get professionAutoCraftEnabled =>
      _professionService?.autoCraftEnabled ?? true;

  /// Craft an item manually
  CraftResult craftItem(CraftedItemType itemType) {
    if (_professionService == null) {
      return CraftResult.failure('Profession service not available');
    }
    final result = _professionService!.craft(itemType);
    _professionState?.save();
    notifyListeners();
    return result;
  }

  /// Check if item can be crafted
  bool canCraftItem(CraftedItemType itemType) {
    return _professionService?.canCraft(itemType) ?? false;
  }

  /// Get craftable recipes
  List<CraftingRecipe> get craftableRecipes =>
      _professionService?.getCraftableRecipes() ?? [];

  /// Get materials organized by profession
  Map<ProfessionType, List<Map<String, dynamic>>> get materialsByProfession =>
      _professionService?.getMaterialsByProfession() ?? {};

  /// Check if Professions should be shown (always true once unlocked)
  bool get showProfessions =>
      (_professionState?.professions.any((p) => p.isUnlocked) ?? false);

  // ==================== EQUIPMENT SETS GETTERS AND METHODS ====================

  EquipmentSetState? get equipmentSetState => _equipmentSetState;
  EquipmentSetService? get equipmentSetService => _equipmentSetService;
  List<EquipmentSetItem> get setInventory => _setInventory;
  List<EquipmentSetItem> get equippedSetItems => _equippedSetItems;

  // Legendary Item getters
  LegendaryCollection? get legendaryCollection => _legendaryCollection;
  LegendaryItemService? get legendaryItemService => _legendaryItemService;
  List<LegendaryItem> get legendaryInventory => _legendaryInventory;
  List<LegendaryItem> get equippedLegendaries => _equippedLegendaries;

  /// Check if Equipment Sets should be shown
  bool get showEquipmentSets =>
      (_equipmentSetState?.discoveredSets.isNotEmpty ?? false) ||
      (_character?.level ?? 0) >= 5;

  /// Get all discovered sets
  List<EquipmentSet> get discoveredSets =>
      _equipmentSetState?.discoveredSets ?? [];

  /// Get active sets
  Map<SetName, ActiveSet> get activeSets =>
      _equipmentSetState?.activeSets ?? {};

  /// Get current synergy
  SetSynergy? get currentSynergy => _equipmentSetState?.activeSynergy;

  /// Get total corruption drain
  double get totalCorruptionDrain =>
      _equipmentSetState?.totalCorruptionDrain ?? 0.0;

  /// Check if any corrupted items are equipped
  bool get hasCorruptionEquipped =>
      _equipmentSetState?.hasCorruptionEquipped ?? false;

  /// Get all active set bonuses
  List<SetBonus> get activeSetBonuses =>
      _equipmentSetService?.totalActiveBonuses ?? [];

  /// Get set evaluation for an item
  SetEvaluationResult evaluateSetItem(
    EquipmentSetItem newItem,
    EquipmentSetItem? currentItem,
  ) {
    if (_equipmentSetService == null || _character == null) {
      return SetEvaluationResult(
        shouldEquip: false,
        recommendation: 'Service unavailable',
        currentStatScore: 0.0,
        newStatScore: 0.0,
        setBonusValue: 0.0,
      );
    }
    return _equipmentSetService!.evaluateSetVsStats(
      newItem,
      currentItem,
      _equipmentSetState!,
      _character!,
    );
  }

  /// Add an item to set inventory
  void addToSetInventory(EquipmentSetItem item) {
    _setInventory.add(item);
    _saveSetEquipment();
    notifyListeners();
  }

  /// Equip a set item
  void equipSetItem(EquipmentSetItem item) {
    // Remove from inventory
    _setInventory.removeWhere(
      (i) =>
          i.equipment.name == item.equipment.name &&
          i.equipment.slot == item.equipment.slot,
    );

    // Add to equipped (replacing any item in same slot)
    _equippedSetItems.removeWhere(
      (i) => i.equipment.slot == item.equipment.slot,
    );
    _equippedSetItems.add(item);

    // Recalculate active sets
    if (_equipmentSetService != null) {
      _equipmentSetState!.activeSets = _equipmentSetService!
          .calculateActiveSets(_equippedSetItems);

      // Check for synergies
      final synergy = _equipmentSetService!.detectSynergies(
        _equipmentSetState!.activeSets,
      );
      _equipmentSetState!.activeSynergy = synergy;
      if (synergy != null) {
        _equipmentSetState!.discoverSynergy(synergy);
      }
    }

    _saveSetEquipment();
    _equipmentSetState?.save();
    notifyListeners();
  }

  /// Unequip a set item
  void unequipSetItem(EquipmentSetItem item) {
    _equippedSetItems.removeWhere(
      (i) =>
          i.equipment.name == item.equipment.name &&
          i.equipment.slot == item.equipment.slot,
    );
    _setInventory.add(item);

    // Recalculate active sets
    if (_equipmentSetService != null) {
      _equipmentSetState!.activeSets = _equipmentSetService!
          .calculateActiveSets(_equippedSetItems);
      _equipmentSetState!.activeSynergy = _equipmentSetService!.detectSynergies(
        _equipmentSetState!.activeSets,
      );
    }

    _saveSetEquipment();
    _equipmentSetState?.save();
    notifyListeners();
  }

  /// Get pieces equipped for a specific set
  int getPiecesEquippedForSet(SetName setName) {
    return _equipmentSetState?.activeSets[setName]?.piecesEquipped ?? 0;
  }

  /// Check if a set bonus tier is active
  bool isSetBonusActive(SetName setName, int piecesRequired) {
    return _equipmentSetState?.activeSets[setName]?.hasBonusTier(
          piecesRequired,
        ) ??
        false;
  }

  // ==================== TRANSMUTATION & ALCHEMY GETTERS ====================

  TransmutationService? get transmutationService => _transmutationService;
  TransmutationState? get transmutationState => _transmutationState;
  AlchemyService? get alchemyService => _alchemyService;
  AlchemyState? get alchemyState => _alchemyState;

  /// Check if transmutation should be shown
  bool get showTransmutation =>
      AppFeatures.isEnabled(AppFeatures.transmutationAlchemy);

  /// Check if alchemy should be shown
  bool get showAlchemy =>
      AppFeatures.isEnabled(AppFeatures.transmutationAlchemy);

  /// Execute a transmutation
  TransmutationResult? transmute(
    TransmutationRecipe recipe,
    List<TransmutableItem> items, {
    bool useVolatile = false,
  }) {
    if (_transmutationService == null) return null;
    final result = _transmutationService!.transmute(
      recipe,
      items,
      useVolatile: useVolatile,
    );
    _transmutationState?.save();
    notifyListeners();
    return result;
  }

  /// Toggle auto-transmute
  void toggleAutoTransmute() {
    _transmutationService?.toggleAutoTransmute();
    notifyListeners();
  }

  /// Start brewing a potion
  bool brewPotion(AlchemyRecipe recipe) {
    if (_alchemyService == null) return false;
    final result = _alchemyService!.brew(recipe);
    if (result) {
      _alchemyState?.save();
      notifyListeners();
    }
    return result;
  }

  /// Collect a completed brew
  PotionType? collectBrew(BrewingSlot slot) {
    if (_alchemyService == null) return null;
    final result = _alchemyService!.collectBrew(slot);
    if (result != null) {
      _alchemyState?.save();
      notifyListeners();
    }
    return result;
  }

  /// Use a potion
  bool usePotion(PotionType type) {
    if (_alchemyService == null) return false;
    final result = _alchemyService!.applyPotionEffect(type);
    if (result) {
      _log('Used ${type.displayName}', immediate: true);
      _alchemyState?.save();
      notifyListeners();
    }
    return result;
  }

  /// Toggle auto-brew
  void toggleAutoBrew() {
    _alchemyService?.toggleAutoBrew();
    notifyListeners();
  }

  /// Get transmutation statistics
  Map<String, dynamic> getTransmutationStats() {
    return _transmutationService?.getTransmutationStats() ?? {};
  }

  /// Get alchemy statistics
  Map<String, dynamic> getAlchemyStats() {
    return _alchemyService?.getStats() ?? {};
  }
}
