import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'presentation/widgets/atoms/game_button.dart';
import 'presentation/widgets/atoms/game_text_styles.dart';
import 'presentation/widgets/atoms/stat_chip.dart';
import 'presentation/widgets/atoms/count_badge.dart';
import 'presentation/widgets/atoms/game_progress_bar.dart';
import 'presentation/widgets/atoms/game_icon.dart';
import 'presentation/widgets/molecules/game_card.dart';
import 'presentation/widgets/molecules/stat_row.dart';
import 'presentation/widgets/molecules/section_header.dart';
import 'presentation/widgets/molecules/item_row.dart';
import 'presentation/widgets/molecules/game_toggle.dart';
import 'presentation/widgets/organisms/inventory_panel.dart';
import 'presentation/widgets/organisms/item_grid.dart';
import 'presentation/widgets/organisms/combat_stats_panel.dart';
import 'presentation/widgets/organisms/character_header.dart';
import 'presentation/widgets/organisms/resource_bar_group.dart';
import 'presentation/widgets/organisms/action_panel.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: 'Atoms',
          children: [
            WidgetbookComponent(
              name: 'GameButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Primary',
                  builder: (context) => GameButton(
                    label: 'Attack',
                    onPressed: () {},
                    variant: GameButtonVariant.primary,
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Secondary',
                  builder: (context) => GameButton(
                    label: 'Cancel',
                    onPressed: () {},
                    variant: GameButtonVariant.secondary,
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Icon Button',
                  builder: (context) =>
                      GameButton.icon(icon: Icons.add, onPressed: () {}),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'GameTextStyles',
              useCases: [
                WidgetbookUseCase(
                  name: 'Section Header',
                  builder: (context) => const GameTextStyles(
                    text: 'INVENTORY',
                    style: GameTextStyle.sectionHeader,
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Stat Label',
                  builder: (context) => const GameTextStyles(
                    text: 'Strength',
                    style: GameTextStyle.statLabel,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StatChip',
              useCases: [
                WidgetbookUseCase(
                  name: 'Strength',
                  builder: (context) =>
                      StatChip(label: 'STR', value: 150, color: Colors.red),
                ),
                WidgetbookUseCase(
                  name: 'Intelligence',
                  builder: (context) =>
                      StatChip(label: 'INT', value: 120, color: Colors.blue),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'CountBadge',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => const CountBadge(count: 5),
                ),
                WidgetbookUseCase(
                  name: 'Large Count',
                  builder: (context) => const CountBadge(count: 99),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'GameProgressBar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Health',
                  builder: (context) =>
                      GameProgressBar(current: 75, max: 100, color: Colors.red),
                ),
                WidgetbookUseCase(
                  name: 'Mana',
                  builder: (context) => GameProgressBar(
                    current: 50,
                    max: 100,
                    color: Colors.blue,
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Experience',
                  builder: (context) => GameProgressBar(
                    current: 2500,
                    max: 5000,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'GameIcon',
              useCases: [
                WidgetbookUseCase(
                  name: 'Gold',
                  builder: (context) => const GameIcon(
                    icon: Icons.monetization_on,
                    color: Colors.amber,
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Health',
                  builder: (context) =>
                      const GameIcon(icon: Icons.favorite, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
        // Molecules
        WidgetbookCategory(
          name: 'Molecules',
          children: [
            WidgetbookComponent(
              name: 'GameCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) =>
                      const GameCard(child: Text('Card Content')),
                ),
                WidgetbookUseCase(
                  name: 'Red Border',
                  builder: (context) => const GameCard(
                    borderColor: Colors.red,
                    child: Text('Card Content'),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StatRow',
              useCases: [
                WidgetbookUseCase(
                  name: 'Basic',
                  builder: (context) =>
                      const StatRow(label: 'Strength', value: '150'),
                ),
                WidgetbookUseCase(
                  name: 'With Modifier',
                  builder: (context) => const StatRow(
                    label: 'Attack',
                    value: '250',
                    valueColor: Colors.red,
                    modifier: '+50',
                    modifierColor: Colors.green,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'SectionHeader',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => const SectionHeader(title: 'Inventory'),
                ),
                WidgetbookUseCase(
                  name: 'Custom Color',
                  builder: (context) =>
                      const SectionHeader(title: 'Stats', color: Colors.red),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'ItemRow',
              useCases: [
                WidgetbookUseCase(
                  name: 'Basic',
                  builder: (context) =>
                      ItemRow(name: 'Iron Sword', icon: Icons.shield),
                ),
                WidgetbookUseCase(
                  name: 'With Count',
                  builder: (context) => ItemRow(
                    name: 'Health Potion',
                    description: 'Restores 50 HP',
                    count: 5,
                    icon: Icons.local_drink,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'GameToggle',
              useCases: [
                WidgetbookUseCase(
                  name: 'Off',
                  builder: (context) => GameToggle(
                    label: 'Auto Craft',
                    value: false,
                    onChanged: (_) {},
                  ),
                ),
                WidgetbookUseCase(
                  name: 'On',
                  builder: (context) => GameToggle(
                    label: 'Auto Craft',
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ],
        ),
        // Organisms
        WidgetbookCategory(
          name: 'Organisms',
          children: [
            WidgetbookComponent(
              name: 'InventoryPanel',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => InventoryPanel(
                    items: const [
                      InventoryItem(
                        name: 'Iron Sword',
                        description: '+5 Attack',
                        count: 1,
                        icon: Icons.sports_martial_arts,
                      ),
                      InventoryItem(
                        name: 'Health Potion',
                        description: 'Restores 50 HP',
                        count: 5,
                        icon: Icons.local_drink,
                      ),
                      InventoryItem(
                        name: 'Gold',
                        count: 150,
                        icon: Icons.monetization_on,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'ItemGrid',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => ItemGrid(
                    items: const [
                      GridItem(
                        name: 'Sword',
                        icon: Icons.sports_martial_arts,
                        count: 1,
                      ),
                      GridItem(name: 'Shield', icon: Icons.shield, count: 2),
                      GridItem(
                        name: 'Potion',
                        icon: Icons.local_drink,
                        count: 5,
                      ),
                      GridItem(
                        name: 'Gem',
                        icon: Icons.diamond,
                        isSelected: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'CombatStatsPanel',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => const CombatStatsPanel(
                    health: 75,
                    maxHealth: 100,
                    mana: 50,
                    maxMana: 100,
                    attack: 25,
                    defense: 15,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'CharacterHeader',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => const CharacterHeader(
                    name: 'Hero',
                    characterClass: 'Warrior',
                    level: 15,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'ResourceBarGroup',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => const ResourceBarGroup(
                    health: 75,
                    maxHealth: 100,
                    mana: 50,
                    maxMana: 100,
                    energy: 80,
                    maxEnergy: 100,
                    experience: 2500,
                    maxExperience: 5000,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'ActionPanel',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => ActionPanel(
                    actions: const [
                      ActionButton(
                        label: 'Attack',
                        icon: Icons.sports_martial_arts,
                      ),
                      ActionButton(label: 'Defend', icon: Icons.shield),
                      ActionButton(label: 'Item', icon: Icons.inventory_2),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
