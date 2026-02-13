import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/character.dart';
import 'models/game_state.dart';
import 'models/combat_log.dart';
import 'models/equipment.dart';
import 'models/skill_tree.dart';
import 'models/bestiary.dart';
import 'models/companion.dart';
import 'models/guild_hall.dart';
import 'models/enchanting.dart';
import 'models/boss_rush.dart';
import 'models/professions.dart';
import 'models/equipment_sets.dart';
import 'models/transmutation.dart';
import 'models/alchemy.dart';
import 'models/legendary_items.dart';
import 'models/infinite_spiral.dart';
import 'providers/game_provider.dart';
import 'providers/core/game_timer_provider.dart';
import 'providers/core/character_provider.dart';
import 'providers/core/game_state_provider.dart';
import 'providers/core/dungeon_provider.dart';
import 'providers/combat/enemy_provider.dart';
import 'providers/combat/combat_provider.dart';
import 'providers/inventory/inventory_provider.dart';
import 'providers/progression/skill_tree_provider.dart';
import 'providers/features/guild_hall_provider.dart';
import 'providers/features/boss_rush_provider.dart';
import 'providers/features/profession_provider.dart';
import 'services/time_manager.dart';
import 'services/guild_hall_service.dart';
import 'services/boss_rift_service.dart';
import 'services/profession_service.dart';
import 'services/enchanting_service.dart';
import 'services/equipment_set_service.dart';
import 'services/legendary_item_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/character_creation_screen.dart';
import 'config/configuration_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load configuration first
  await ConfigurationManager.initialize();

  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(CharacterAdapter());
  Hive.registerAdapter(GameStateAdapter());
  Hive.registerAdapter(CombatLogAdapter());
  Hive.registerAdapter(EquipmentAdapter());
  Hive.registerAdapter(InventoryAdapter());
  Hive.registerAdapter(SkillTreeAdapter());
  Hive.registerAdapter(BestiaryAdapter());
  Hive.registerAdapter(CompanionAdapter());
  Hive.registerAdapter(CompanionRosterAdapter());
  Hive.registerAdapter(RoomAdapter());
  Hive.registerAdapter(EchoNPCAdapter());
  Hive.registerAdapter(GuildHallAdapter());
  Hive.registerAdapter(GemTypeAdapter());
  Hive.registerAdapter(GemTierAdapter());
  Hive.registerAdapter(PrefixTypeAdapter());
  Hive.registerAdapter(SuffixTypeAdapter());
  Hive.registerAdapter(CurseTypeAdapter());
  Hive.registerAdapter(GemAdapter());
  Hive.registerAdapter(EnchantmentAdapter());
  Hive.registerAdapter(SocketAdapter());
  Hive.registerAdapter(EnchantedEquipmentAdapter());
  Hive.registerAdapter(BossMechanicAdapter());
  Hive.registerAdapter(EssenceTypeAdapter());
  Hive.registerAdapter(RiftModifierAdapter());
  Hive.registerAdapter(BossAdapter());
  Hive.registerAdapter(EchoEntryAdapter());
  Hive.registerAdapter(RiftAdapter());
  Hive.registerAdapter(BossRushStateAdapter());
  Hive.registerAdapter(ProfessionTypeAdapter());
  Hive.registerAdapter(MaterialTypeAdapter());
  Hive.registerAdapter(CraftedItemTypeAdapter());
  Hive.registerAdapter(MaterialAdapter());
  Hive.registerAdapter(CraftingRecipeAdapter());
  Hive.registerAdapter(ProfessionAdapter());
  Hive.registerAdapter(ProfessionStateAdapter());
  Hive.registerAdapter(SetNameAdapter());
  Hive.registerAdapter(SetBonusTypeAdapter());
  Hive.registerAdapter(SetBonusAdapter());
  Hive.registerAdapter(EquipmentSetAdapter());
  Hive.registerAdapter(ActiveSetAdapter());
  Hive.registerAdapter(SetSynergyAdapter());
  Hive.registerAdapter(EquipmentSetStateAdapter());
  Hive.registerAdapter(EquipmentSetItemAdapter());

  // Open all boxes
  final characterBox = await Hive.openBox<Character>('character');
  final gameStateBox = await Hive.openBox<GameState>('gameState');
  final combatLogBox = await Hive.openBox<CombatLog>('combatLog');
  final skillTreeBox = await Hive.openBox<SkillTree>('skillTree');
  final bestiaryBox = await Hive.openBox<Bestiary>('bestiary');
  final companionBox = await Hive.openBox<CompanionRoster>('companions');
  final guildHallBox = await Hive.openBox<GuildHall>('guildHall');
  final bossRushBox = await Hive.openBox<BossRushState>('bossRush');
  final professionBox = await Hive.openBox<ProfessionState>('professions');
  final equipmentSetBox = await Hive.openBox<EquipmentSetState>(
    'equipmentSets',
  );
  final transmutationBox = await Hive.openBox<TransmutationState>(
    'transmutation',
  );
  final alchemyBox = await Hive.openBox<AlchemyState>('alchemy');
  final legendaryBox = await Hive.openBox<LegendaryCollection>('legendary');
  final spiralBox = await Hive.openBox<InfiniteSpiral>('spiral');

  final timeManager = TimeManager();

  // Load data for new providers
  final character = characterBox.get('main');
  final gameState = gameStateBox.get('state');
  final combatLog = combatLogBox.get('log');
  final skillTree = skillTreeBox.get('tree');
  final bestiary = bestiaryBox.get('bestiary');
  final guildHall = guildHallBox.get('hall');
  final bossRush = bossRushBox.get('bossrush');
  final profession = professionBox.get('professions');
  final equipmentSet = equipmentSetBox.get('sets');

  // Initialize services for new providers
  final guildHallService = guildHall != null
      ? GuildHallService(guildHall)
      : null;
  final bossRiftService = bossRush != null ? BossRiftService(bossRush) : null;
  final professionService = profession != null
      ? ProfessionService(profession)
      : null;
  final enchantingService = EnchantingService();
  final equipmentSetService = equipmentSet != null
      ? EquipmentSetService(equipmentSet)
      : null;
  final legendaryItemService = legendaryBox.get('legendary') != null
      ? LegendaryItemService(legendaryBox.get('legendary')!)
      : null;

  // Check if we have existing character data
  final hasExistingCharacter = character != null;

  runApp(
    MultiProvider(
      providers: [
        // Legacy Provider (to be phased out)
        ChangeNotifierProvider(
          create: (_) => GameProvider(
            characterBox,
            gameStateBox,
            combatLogBox,
            skillTreeBox,
            bestiaryBox,
            companionBox,
            guildHallBox,
            bossRushBox,
            professionBox,
            equipmentSetBox,
            transmutationBox,
            alchemyBox,
            legendaryBox,
            spiralBox,
            timeManager,
          ),
        ),
        // New Providers
        ChangeNotifierProvider(create: (_) => GameTimerProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              CharacterProvider(characterBox, gameState: gameState)
                ..loadCharacter(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              GameStateProvider(gameStateBox, combatLogBox)..loadGameState(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DungeonProvider()..initialize(character?.dungeonDepth ?? 1),
        ),
        ChangeNotifierProvider(
          create: (_) => EnemyProvider(bestiary: bestiary),
        ),
        ChangeNotifierProvider(
          create: (_) => SkillTreeProvider(skillTreeBox)..loadSkillTree(),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(
            enchantingService: enchantingService,
            equipmentSetService: equipmentSetService,
            legendaryItemService: legendaryItemService,
          )..loadEquipment(),
        ),
        ChangeNotifierProvider(
          create: (_) => GuildHallProvider(guildHallService: guildHallService),
        ),
        ChangeNotifierProvider(
          create: (_) => BossRushProvider(bossRiftService: bossRiftService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProfessionProvider(professionService: professionService),
        ),
      ],
      child: MainApp(hasExistingCharacter: hasExistingCharacter),
    ),
  );
}

class MainApp extends StatelessWidget {
  final bool hasExistingCharacter;

  const MainApp({super.key, required this.hasExistingCharacter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ConfigurationManager.appName,
      debugShowCheckedModeBanner: ConfigurationManager.debugMode,
      theme: ThemeData.dark(useMaterial3: false).copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Courier New'),
      ),
      home: hasExistingCharacter
          ? const AppLifecycleWrapper()
          : CharacterCreationWrapper(),
    );
  }
}

/// Wrapper for character creation that handles the transition to main game
class CharacterCreationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CharacterCreationScreen(
      onCreate: (name, race, className, stats) {
        _createCharacterAndStart(context, name, race, className, stats);
      },
    );
  }

  void _createCharacterAndStart(
    BuildContext context,
    String name,
    String race,
    String className,
    Map<String, int> stats,
  ) {
    // Use both legacy and new providers during transition
    final gameProvider = context.read<GameProvider>();
    final characterProvider = context.read<CharacterProvider>();

    // Create the character with custom stats (both providers)
    gameProvider.createCustomCharacter(
      name: name,
      race: race,
      characterClass: className,
      stats: stats,
    );

    // Also initialize new provider
    characterProvider.createCustomCharacter(
      name: name,
      race: race,
      characterClass: className,
      stats: stats,
    );

    // Navigate to main game
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppLifecycleWrapper()),
    );
  }
}

class AppLifecycleWrapper extends StatefulWidget {
  const AppLifecycleWrapper({super.key});

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle both legacy and new providers
    final gameProvider = context.read<GameProvider>();
    final gameStateProvider = context.read<GameStateProvider>();
    final gameTimerProvider = context.read<GameTimerProvider>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      gameProvider.onAppPause();
      gameStateProvider.onAppPause();
      gameTimerProvider.pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      gameProvider.onAppResume();
      gameStateProvider.onAppResume();
      gameTimerProvider.resumeAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
