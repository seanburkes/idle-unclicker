import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/dungeon_generator.dart';
import '../utils/rpg_system.dart';
import '../config/feature_flags.dart';
import 'ascension_screen.dart';
import 'skill_tree_screen.dart';
import 'bestiary_screen.dart';
import 'companions_screen.dart';
import 'guild_hall_screen.dart';
import 'enchanting_screen.dart';
import 'boss_rush_screen.dart';
import 'professions_screen.dart';
import 'equipment_sets_screen.dart';
import 'transmutation_screen.dart';
import 'alchemy_screen.dart';
import 'legendary_items_screen.dart';
import 'spiral_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  int _getTabCount(BuildContext context) {
    int count = 3;
    if (AppFeatures.isEnabled(AppFeatures.skillTree)) count++;
    if (AppFeatures.isEnabled(AppFeatures.bestiary)) count++;
    if (AppFeatures.isEnabled(AppFeatures.mercenaries)) count++;
    if (_shouldShowGuildHall(context)) count++;
    if (_shouldShowEnchanting(context)) count++;
    if (_shouldShowBossRush(context)) count++;
    if (_shouldShowProfessions(context)) count++;
    if (_shouldShowEquipmentSets(context)) count++;
    if (_shouldShowTransmutationAlchemy(context)) count++;
    if (_shouldShowLegendaryItems(context)) count++;
    if (_shouldShowSpiral(context)) count++;
    return count;
  }

  bool _shouldShowSpiral(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return AppFeatures.isEnabled(AppFeatures.infiniteSpiral) && game.showSpiral;
  }

  bool _shouldShowLegendaryItems(BuildContext context) {
    return AppFeatures.isEnabled(AppFeatures.legendaryItems);
  }

  bool _shouldShowTransmutationAlchemy(BuildContext context) {
    return AppFeatures.isEnabled(AppFeatures.transmutationAlchemy);
  }

  bool _shouldShowEquipmentSets(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return AppFeatures.isEnabled(AppFeatures.equipmentSets) &&
        game.showEquipmentSets;
  }

  bool _shouldShowEnchanting(BuildContext context) {
    return AppFeatures.isEnabled(AppFeatures.enchanting);
  }

  bool _shouldShowGuildHall(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return AppFeatures.isEnabled(AppFeatures.guildHall) && game.showGuildHall;
  }

  bool _shouldShowBossRush(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return AppFeatures.isEnabled(AppFeatures.bossRush) && game.showBossRush;
  }

  bool _shouldShowProfessions(BuildContext context) {
    return AppFeatures.isEnabled(AppFeatures.professions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final tabCount = _getTabCount(context);
            _tabController?.dispose();
            _tabController = TabController(length: tabCount, vsync: this);

            final children = [
              _buildMainControls(),
              _buildEquipmentTab(),
              _buildInventoryTab(),
              if (AppFeatures.isEnabled(AppFeatures.skillTree))
                const SkillTreeScreen(),
              if (AppFeatures.isEnabled(AppFeatures.bestiary))
                const BestiaryScreen(),
              if (AppFeatures.isEnabled(AppFeatures.mercenaries))
                const CompanionsScreen(),
              if (_shouldShowGuildHall(context)) const GuildHallScreen(),
              if (_shouldShowEnchanting(context)) const EnchantingScreen(),
              if (_shouldShowBossRush(context)) const BossRushScreen(),
              if (_shouldShowProfessions(context)) const ProfessionsScreen(),
              if (_shouldShowEquipmentSets(context))
                const EquipmentSetsScreen(),
              if (_shouldShowTransmutationAlchemy(context))
                const TransmutationScreen(),
              if (_shouldShowTransmutationAlchemy(context))
                const AlchemyScreen(),
              if (_shouldShowLegendaryItems(context))
                const LegendaryItemsScreen(),
              if (_shouldShowSpiral(context)) const SpiralScreen(),
            ];

            return Column(
              children: [
                _buildHeader(),
                Expanded(flex: 1, child: _buildDungeonViewport()),
                _buildTabBar(tabCount),
                Expanded(
                  flex: 1,
                  child: TabBarView(
                    controller: _tabController!,
                    children: children,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Selector<GameProvider, Map<String, dynamic>>(
      selector: (_, game) => {
        'name': game.character?.name ?? 'Loading',
        'level': game.character?.level ?? 0,
        'race': game.character?.race ?? '',
        'class': game.character?.characterClass ?? '',
        'location': game.currentLocation,
        'inTown': game.inTown,
        'hp': game.character?.currentHealth ?? 0,
        'maxHp': game.character?.maxHealth ?? 0,
        'gold': game.character?.gold ?? 0,
        'isInSpiral': game.isInSpiral,
        'currentSpiralLoop': game.currentSpiralLoop,
      },
      builder: (context, data, child) {
        final inTown = data['inTown'] as bool;
        final isInSpiral = data['isInSpiral'] as bool;
        final currentSpiralLoop = data['currentSpiralLoop'] as int;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: inTown ? Colors.yellow : Colors.green,
              width: 2,
            ),
            color: Colors.black,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${data['name']} [${data['race']} ${data['class']}]',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      // Spiral loop indicator - shown when in spiral mode
                      if (isInSpiral)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.3),
                            border: Border.all(color: Colors.purple),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '🌀 Loop $currentSpiralLoop',
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        'Lv.${data['level']}',
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Echo sanctuary button - only shown when ascension feature is enabled
                      // Echo sanctuary button - only shown when ascension feature is enabled
                      if (AppFeatures.isEnabled(AppFeatures.ascension))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AscensionScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.cyan),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '☆ Echo',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HP: ${data['hp']}/${data['maxHp']}',
                    style: TextStyle(
                      color:
                          (data['hp'] as int) <= (data['maxHp'] as int) * 0.25
                          ? Colors.red
                          : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    data['location'] as String,
                    style: TextStyle(
                      color: inTown ? Colors.yellow : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${data['gold']} 💰',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),
                      // Debug button - only shown when debugMode feature is enabled
                      if (AppFeatures.isEnabled(AppFeatures.debugMode))
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.grey,
                            size: 18,
                          ),
                          onPressed: () {
                            AppFeatures.showDebugPanel(context);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDungeonViewport() {
    return Selector<GameProvider, Map<String, dynamic>>(
      selector: (_, game) => {
        'inTown': game.inTown,
        'map': game.currentMap,
        'combat': game.isInCombat,
        'enemy': game.currentEnemy,
      },
      builder: (context, data, child) {
        final inTown = data['inTown'] as bool;
        final inCombat = data['combat'] as bool;
        final enemy = data['enemy'] as String;
        final map = data['map'] as String;
        final dungeonAscii = map.trim().isEmpty
            ? (inTown
                  ? TownGenerator(
                      width: 50,
                      height: 15,
                      seed: DateTime.now().day,
                    ).render()
                  : DungeonGenerator(
                      width: 60,
                      height: 18,
                      seed: DateTime.now().millisecondsSinceEpoch,
                    ).render())
            : map;

        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: inCombat ? Colors.red : Colors.green,
              width: 2,
            ),
            color: Colors.black,
          ),
          child: Column(
            children: [
              if (inCombat)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.red.withOpacity(0.3),
                  child: Text(
                    '⚔️ Fighting: $enemy',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        dungeonAscii,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          height: 1.0,
                          fontFamily: 'RobotoMono',
                          fontFamilyFallback: ['NotoSans', 'monospace'],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageLog() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.black,
      ),
      child: Selector<GameProvider, List<String>>(
        selector: (_, game) => game.recentCombatEntries,
        builder: (context, entries, child) {
          return ListView.builder(
            reverse: true,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  '> ${entries[entries.length - 1 - index]}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showStatAllocation(BuildContext context, GameProvider game) {
    final character = game.character;
    if (character == null || character.unallocatedPoints == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          'Allocate ${character.unallocatedPoints} Points',
          style: const TextStyle(color: Colors.green, fontSize: 14),
        ),
        content: Wrap(
          spacing: 8,
          children: [
            _buildStatButton(context, game, 'STR'),
            _buildStatButton(context, game, 'DEX'),
            _buildStatButton(context, game, 'CON'),
            _buildStatButton(context, game, 'INT'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton(
    BuildContext context,
    GameProvider game,
    String stat,
  ) {
    return ElevatedButton(
      onPressed: () {
        game.allocateStat(stat, 1);
        if (game.character?.unallocatedPoints == 0) Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        side: const BorderSide(color: Colors.green),
      ),
      child: Text(
        stat,
        style: const TextStyle(color: Colors.green, fontSize: 11),
      ),
    );
  }

  Widget _buildTabBar(int tabCount) {
    return Container(
      color: Colors.grey[900],
      child: Builder(
        builder: (context) {
          final List<Widget> tabs = [
            const Tab(icon: Icon(Icons.gamepad), text: 'Actions'),
            const Tab(icon: Icon(Icons.shield), text: 'Equipped'),
            const Tab(icon: Icon(Icons.backpack), text: 'Inventory'),
          ];

          if (AppFeatures.isEnabled(AppFeatures.skillTree)) {
            tabs.add(const Tab(icon: Icon(Icons.account_tree), text: 'Skills'));
          }

          if (AppFeatures.isEnabled(AppFeatures.bestiary)) {
            tabs.add(const Tab(icon: Icon(Icons.menu_book), text: 'Bestiary'));
          }

          if (AppFeatures.isEnabled(AppFeatures.mercenaries)) {
            tabs.add(const Tab(icon: Icon(Icons.groups), text: 'Party'));
          }

          if (_shouldShowGuildHall(context)) {
            tabs.add(
              const Tab(icon: Icon(Icons.account_balance), text: 'Guild'),
            );
          }

          if (_shouldShowEnchanting(context)) {
            tabs.add(
              const Tab(icon: Icon(Icons.auto_fix_high), text: 'Enchant'),
            );
          }

          if (_shouldShowBossRush(context)) {
            tabs.add(
              Tab(
                icon: Badge(
                  isLabelVisible: context.select<GameProvider, bool>(
                    (game) => game.bossRiftService?.isRiftAvailable ?? false,
                  ),
                  smallSize: 8,
                  child: const Icon(Icons.local_fire_department),
                ),
                text: 'Boss',
              ),
            );
          }

          if (_shouldShowProfessions(context)) {
            tabs.add(const Tab(icon: Icon(Icons.work), text: 'Professions'));
          }

          if (_shouldShowEquipmentSets(context)) {
            tabs.add(const Tab(icon: Icon(Icons.auto_awesome), text: 'Sets'));
          }

          if (_shouldShowTransmutationAlchemy(context)) {
            tabs.add(const Tab(icon: Icon(Icons.transform), text: 'Transmute'));
            tabs.add(const Tab(icon: Icon(Icons.science), text: 'Alchemy'));
          }

          if (_shouldShowLegendaryItems(context)) {
            tabs.add(
              const Tab(icon: Icon(Icons.auto_fix_high), text: 'Legendary'),
            );
          }

          if (_shouldShowSpiral(context)) {
            tabs.add(
              const Tab(icon: Icon(Icons.all_inclusive), text: 'Spiral'),
            );
          }

          return TabBar(
            controller: _tabController!,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: tabs,
          );
        },
      ),
    );
  }

  Widget _buildMainControls() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(child: _buildMessageLog()),
          const SizedBox(height: 12),
          _buildLargeControls(),
        ],
      ),
    );
  }

  Widget _buildLargeControls() {
    return Selector<GameProvider, Map<String, dynamic>>(
      selector: (_, game) => {
        'inTown': game.inTown,
        'inCombat': game.isInCombat,
        'isResting': game.isResting,
        'potions': game.character?.healthPotions ?? 0,
        'focus': game.gameState?.focusPercentage ?? 0.0,
        'multiplier': game.effectiveMultiplier,
      },
      builder: (context, data, child) {
        final inTown = data['inTown'] as bool;
        final inCombat = data['inCombat'] as bool;
        final isResting = data['isResting'] as bool;
        final potions = data['potions'] as int;
        final focus = data['focus'] as double;
        final multiplier = data['multiplier'] as double;

        return Column(
          children: [
            _buildFocusBar(focus, multiplier),
            const SizedBox(height: 12),
            if (inTown) ...[
              _buildLargeButton(
                '⛏️ Enter Dungeon',
                Colors.orange,
                () => context.read<GameProvider>().enterDungeon(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildLargeButton(
                      '🏪 Browse Shops',
                      Colors.yellow,
                      () => context.read<GameProvider>().browseShops(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLargeButton(
                      '💤 Rest at Inn',
                      Colors.blue,
                      () => context.read<GameProvider>().rest(),
                    ),
                  ),
                ],
              ),
            ] else ...[
              if (inCombat) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildLargeButton(
                        '🧪 Potion ($potions)',
                        Colors.purple,
                        () => context.read<GameProvider>().useHealthPotion(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLargeButton(
                        '🏃 Flee!',
                        Colors.red,
                        () => context.read<GameProvider>().fleeToSurface(),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildLargeButton('⬇️ Descend Deeper', Colors.green, () {
                  context.read<GameProvider>().descendDeeper();
                  context.read<GameProvider>().dungeonRenderer?.regenerate();
                }),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildLargeButton(
                        isResting ? '💤 Resting...' : '💤 Rest',
                        isResting ? Colors.grey : Colors.blue,
                        isResting
                            ? () {}
                            : () => context.read<GameProvider>().rest(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLargeButton(
                        '🏘️ Return to Town',
                        Colors.yellow,
                        () => context.read<GameProvider>().returnToTown(),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildFocusBar(double focus, double multiplier) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Focus: ',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: focus / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    focus > 80
                        ? Colors.green
                        : focus > 40
                        ? Colors.yellow
                        : Colors.red,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${focus.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: focus > 80
                      ? Colors.green
                      : focus > 40
                      ? Colors.yellow
                      : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Multiplier: ${multiplier.toStringAsFixed(1)}x',
            style: const TextStyle(color: Colors.cyan, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEquipmentTab() {
    return Selector<GameProvider, Map<String, dynamic>>(
      selector: (_, game) => {
        'weapon': game.character?.weaponType ?? 'balanced',
        'armor': game.character?.armorType ?? 'leather',
        'str': game.character?.strength ?? 10,
        'dex': game.character?.dexterity ?? 10,
        'con': game.character?.constitution ?? 10,
        'int': game.character?.intelligence ?? 10,
        'wis': game.character?.wisdom ?? 10,
        'cha': game.character?.charisma ?? 10,
        'attack': game.character?.attackPower ?? 0,
        'defense': game.character?.defense ?? 0,
      },
      builder: (context, data, child) {
        final weapon = RPGSystem.weaponTypes[data['weapon']]!;
        final armor = RPGSystem.armorTypes[data['armor']]!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EQUIPPED ITEMS',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildEquipmentSlot(
                'Weapon',
                weapon.name,
                '🗡️',
                Colors.orange,
                'DMG: ${weapon.baseDamage} | ACC: ${weapon.accuracyBonus > 0 ? "+" : ""}${weapon.accuracyBonus}',
              ),
              const SizedBox(height: 8),
              _buildEquipmentSlot(
                'Armor',
                armor.name,
                '🛡️',
                Colors.blue,
                'AC: ${armor.armorClass} | ENC: ${armor.encumbrance}',
              ),
              const Divider(color: Colors.grey, height: 24),
              const Text(
                'CHARACTER STATS',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow('STR', data['str'], Colors.red),
              _buildStatRow('DEX', data['dex'], Colors.green),
              _buildStatRow('CON', data['con'], Colors.orange),
              _buildStatRow('INT', data['int'], Colors.blue),
              _buildStatRow('WIS', data['wis'], Colors.cyan),
              _buildStatRow('CHA', data['cha'], Colors.purple),
              const Divider(color: Colors.grey, height: 24),
              const Text(
                'COMBAT STATS',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildCombatStat(
                'Attack Power',
                data['attack'].toString(),
                Colors.red,
              ),
              _buildCombatStat(
                'Defense',
                data['defense'].toString(),
                Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEquipmentSlot(
    String slot,
    String itemName,
    String icon,
    Color color,
    String stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.toUpperCase(),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Text(
                  itemName,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  stats,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String name, int value, Color color) {
    final modifier = (value - 10) ~/ 2;
    final modString = modifier >= 0 ? '+$modifier' : '$modifier';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                '$value',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  modString,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCombatStat(String name, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return Selector<GameProvider, Map<String, dynamic>>(
      selector: (_, game) => {
        'potions': game.character?.healthPotions ?? 0,
        'gold': game.character?.gold ?? 0,
        'deaths': game.character?.totalDeaths ?? 0,
        'depth': game.character?.dungeonDepth ?? 1,
        'skills': {
          'weapon': game.character?.weaponSkill ?? 0,
          'fighting': game.character?.fightingSkill ?? 0,
          'armor': game.character?.armorSkill ?? 0,
          'dodging': game.character?.dodgingSkill ?? 0,
        },
      },
      builder: (context, data, child) {
        final potions = data['potions'] as int;
        final gold = data['gold'] as int;
        final deaths = data['deaths'] as int;
        final depth = data['depth'] as int;
        final skills = data['skills'] as Map<String, int>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INVENTORY',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildInventoryItem(
                '🧪 Health Potion',
                'Restores 50% HP',
                potions,
                Colors.purple,
              ),
              const SizedBox(height: 8),
              _buildInventoryItem(
                '💰 Gold Coins',
                'Currency for shops',
                gold,
                Colors.amber,
              ),
              const Divider(color: Colors.grey, height: 24),
              const Text(
                'PROGRESS',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildProgressRow('Deepest Depth', '$depth', Colors.orange),
              _buildProgressRow('Total Deaths', '$deaths', Colors.red),
              const Divider(color: Colors.grey, height: 24),
              const Text(
                'SKILLS',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildSkillRow('Weapon', skills['weapon']!, Colors.orange),
              _buildSkillRow('Fighting', skills['fighting']!, Colors.red),
              _buildSkillRow('Armor', skills['armor']!, Colors.blue),
              _buildSkillRow('Dodging', skills['dodging']!, Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryItem(
    String name,
    String description,
    int count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'x$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRow(String name, int level, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: color, fontSize: 14)),
          Row(
            children: [
              ...List.generate(
                level.clamp(0, 10),
                (i) => Icon(Icons.star, color: color, size: 14),
              ),
              if (level > 10)
                Text(
                  ' +${level - 10}',
                  style: TextStyle(color: color, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
