import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'presentation/widgets/atoms/game_button.dart';
import 'presentation/widgets/atoms/game_text_styles.dart';
import 'presentation/widgets/atoms/stat_chip.dart';
import 'presentation/widgets/atoms/count_badge.dart';
import 'presentation/widgets/atoms/game_progress_bar.dart';
import 'presentation/widgets/atoms/game_icon.dart';

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
                  builder: (context) => GameButton.icon(
                    icon: Icons.add,
                    onPressed: () {},
                  ),
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
                  builder: (context) => StatChip(
                    label: 'STR',
                    value: 150,
                    color: Colors.red,
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Intelligence',
                  builder: (context) => StatChip(
                    label: 'INT',
                    value: 120,
                    color: Colors.blue,
                  ),
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
                  builder: (context) => GameProgressBar(
                    current: 75,
                    max: 100,
                    color: Colors.red,
                  ),
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
                  builder: (context) => const GameIcon(
                    icon: Icons.favorite,
                    color: Colors.red,
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
