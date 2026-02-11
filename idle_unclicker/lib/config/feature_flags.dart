import 'package:flutter/material.dart';
import 'configuration_manager.dart';

/// Feature flags for Idle Unclicker
///
/// Usage:
/// ```dart
/// if (AppFeatures.isEnabled(context, AppFeatures.ascension)) {
///   // Show ascension feature
/// }
/// ```
///
/// Or use AppFeatures.setEnabled(context, AppFeatures.ascension, true/false) to toggle

class AppFeatures {
  // Core Features
  static const String ascension = 'core.ascension';
  static const String characterCreation = 'core.characterCreation';
  static const String offlineProgression = 'core.offlineProgression';
  static const String playerAutomaton = 'core.playerAutomaton';

  // Phase 1.2 - Skill Tree (Coming Soon)
  static const String skillTree = 'phase1.skillTree';

  // Phase 1.3 - Bestiary
  static const String bestiary = 'phase1.bestiary';

  // Phase 2.1 - Mercenaries
  static const String mercenaries = 'phase2.mercenaries';

  // Phase 2.2 - Guild Hall
  static const String guildHall = 'phase2.guildHall';

  // Phase 3.1 - Equipment Enchanting
  static const String enchanting = 'phase3.enchanting';

  // Phase 3.2 - Boss Rush
  static const String bossRush = 'phase3.bossRush';

  // Phase 3.3 - Professions
  static const String professions = 'phase3.professions';

  // Phase 4.1 - Equipment Sets
  static const String equipmentSets = 'phase4.equipmentSets';

  // Phase 4.2 - Transmutation & Alchemy
  static const String transmutationAlchemy = 'phase4.transmutationAlchemy';

  // Phase 4.3 - Legendary Items
  static const String legendaryItems = 'phase4.legendaryItems';

  // Phase 5 - Infinite Spiral & Character Legacy
  static const String infiniteSpiral = 'phase5.infiniteSpiral';

  // Debug/Tools
  static const String debugMode = 'debug.debugMode';
  static const String fastCombat = 'debug.fastCombat';

  /// List of all feature flag keys
  static const List<String> all = [
    ascension,
    characterCreation,
    offlineProgression,
    playerAutomaton,
    skillTree,
    bestiary,
    mercenaries,
    guildHall,
    enchanting,
    bossRush,
    professions,
    equipmentSets,
    transmutationAlchemy,
    legendaryItems,
    infiniteSpiral,
    debugMode,
    fastCombat,
  ];

  /// Get default enabled features from config
  static List<String> get defaultEnabled {
    return all.where((f) => isEnabled(f)).toList();
  }

  /// Check if a feature is enabled (delegates to ConfigurationManager)
  static bool isEnabled(String featurePath) {
    return ConfigurationManager.isFeatureEnabled(featurePath);
  }

  /// Enable/disable a feature (runtime override)
  static void setEnabled(String featurePath, bool enabled) {
    ConfigurationManager.setFeatureOverride(featurePath, enabled);
  }

  /// Get all features with their status
  static Map<String, Map<String, dynamic>> getAllFeatures() {
    return ConfigurationManager.getAllFeatures();
  }

  /// Show debug feature flags panel
  static void showDebugPanel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Feature Flags',
          style: TextStyle(color: Colors.green),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ConfigurationManager.getAllFeatures().entries.map((
              entry,
            ) {
              final isEnabled = entry.value['enabled'] as bool;
              return ListTile(
                title: Text(
                  entry.key,
                  style: TextStyle(
                    color: isEnabled ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                subtitle: Text(
                  entry.value['description'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                trailing: Switch(
                  value: isEnabled,
                  onChanged: (value) {
                    ConfigurationManager.setFeatureOverride(entry.key, value);
                    Navigator.pop(context);
                    showDebugPanel(context);
                  },
                  activeColor: Colors.green,
                ),
              );
            }).toList(),
          ),
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
}
