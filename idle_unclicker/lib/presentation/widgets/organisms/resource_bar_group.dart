import 'package:flutter/material.dart';
import '../atoms/game_progress_bar.dart';

class ResourceBarGroup extends StatelessWidget {
  final double health;
  final double maxHealth;
  final double mana;
  final double maxMana;
  final double energy;
  final double maxEnergy;
  final double experience;
  final double maxExperience;

  const ResourceBarGroup({
    super.key,
    required this.health,
    required this.maxHealth,
    required this.mana,
    required this.maxMana,
    required this.energy,
    required this.maxEnergy,
    required this.experience,
    required this.maxExperience,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GameProgressBar(current: health, max: maxHealth, color: Colors.red),
        const SizedBox(height: 8),
        GameProgressBar(current: mana, max: maxMana, color: Colors.blue),
        const SizedBox(height: 8),
        GameProgressBar(current: energy, max: maxEnergy, color: Colors.orange),
        const SizedBox(height: 8),
        GameProgressBar(
          current: experience,
          max: maxExperience,
          color: Colors.purple,
        ),
      ],
    );
  }
}
