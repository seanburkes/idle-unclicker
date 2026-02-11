import 'dart:convert';
import 'package:flutter/services.dart';

/// Configuration Manager - Loads and provides access to config.json
///
/// Usage:
/// ```dart
/// await ConfigurationManager.initialize();
/// if (ConfigurationManager.isFeatureEnabled('skillTree')) { ... }
/// ```
class ConfigurationManager {
  static Map<String, dynamic>? _config;
  static final Map<String, bool> _featureOverrides = {};

  /// Initialize by loading config.json from assets
  static Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString('assets/config.json');
      _config = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Failed to load config.json: $e');
      _config = _defaultConfig;
    }
  }

  /// Check if config is loaded
  static bool get isInitialized => _config != null;

  /// Get raw config map
  static Map<String, dynamic>? get rawConfig => _config;

  // ============================================================================
  // Feature Flags
  // ============================================================================

  /// Check if a feature is enabled
  static bool isFeatureEnabled(String featurePath) {
    if (_featureOverrides.containsKey(featurePath)) {
      return _featureOverrides[featurePath]!;
    }

    if (_config == null) return false;

    final features = _config!['features'] as Map<String, dynamic>?;
    if (features == null) return false;

    final parts = featurePath.split('.');

    if (parts.length == 2) {
      final category = features[parts[0]] as Map<String, dynamic>?;
      if (category == null) return false;
      final feature = category[parts[1]] as Map<String, dynamic>?;
      return feature?['enabled'] ?? false;
    } else if (parts.length == 1) {
      for (final category in features.values) {
        if (category is Map<String, dynamic>) {
          final feature = category[parts[0]] as Map<String, dynamic>?;
          if (feature != null) {
            return feature['enabled'] ?? false;
          }
        }
      }
    }

    return false;
  }

  /// Override a feature flag (runtime only)
  static void setFeatureOverride(String featurePath, bool enabled) {
    _featureOverrides[featurePath] = enabled;
  }

  /// Clear all runtime overrides
  static void clearOverrides() {
    _featureOverrides.clear();
  }

  /// Get list of all available features
  static Map<String, Map<String, dynamic>> getAllFeatures() {
    final result = <String, Map<String, dynamic>>{};

    if (_config == null) return result;

    final features = _config!['features'] as Map<String, dynamic>?;
    if (features == null) return result;

    for (final categoryEntry in features.entries) {
      final category = categoryEntry.value as Map<String, dynamic>?;
      if (category != null) {
        for (final featureEntry in category.entries) {
          final featureData = featureEntry.value as Map<String, dynamic>?;
          if (featureData != null) {
            result['${categoryEntry.key}.${featureEntry.key}'] = {
              'enabled': featureData['enabled'] ?? false,
              'description': featureData['description'] ?? '',
              'category': categoryEntry.key,
            };
          }
        }
      }
    }

    return result;
  }

  // ============================================================================
  // Gameplay Settings
  // ============================================================================

  static Map<String, dynamic>? get gameplay {
    return _config?['gameplay'] as Map<String, dynamic>?;
  }

  static Map<String, dynamic>? get offlineSettings {
    return gameplay?['offlineProgression'] as Map<String, dynamic>?;
  }

  static Map<String, dynamic>? get ascensionSettings {
    return gameplay?['ascension'] as Map<String, dynamic>?;
  }

  static Map<String, dynamic>? get combatSettings {
    return gameplay?['combat'] as Map<String, dynamic>?;
  }

  static Map<String, dynamic>? get characterSettings {
    return gameplay?['character'] as Map<String, dynamic>?;
  }

  // ============================================================================
  // UI Settings
  // ============================================================================

  static Map<String, dynamic>? get ui {
    return _config?['ui'] as Map<String, dynamic>?;
  }

  static Map<String, dynamic>? get fonts {
    return ui?['fonts'] as Map<String, dynamic>?;
  }

  static Map<String, dynamic>? get colors {
    return ui?['colors'] as Map<String, dynamic>?;
  }

  static Map<String, dynamic>? get layout {
    return ui?['layout'] as Map<String, dynamic>?;
  }

  // ============================================================================
  // Monster Settings
  // ============================================================================

  static Map<String, dynamic>? get monsters {
    return _config?['monsters'] as Map<String, dynamic>?;
  }

  static List<String> get monsterTypes {
    final types = monsters?['types'] as List<dynamic>?;
    return types?.cast<String>() ?? [];
  }

  // ============================================================================
  // Skill Tree Settings
  // ============================================================================

  static Map<String, dynamic>? get skillTree {
    return _config?['skillTree'] as Map<String, dynamic>?;
  }

  static Map<String, dynamic>? get skillBranches {
    return skillTree?['branches'] as Map<String, dynamic>?;
  }

  // ============================================================================
  // App Info
  // ============================================================================

  static Map<String, dynamic>? get app {
    return _config?['app'] as Map<String, dynamic>?;
  }

  static String get appName {
    return app?['name'] ?? 'Idle Unclicker';
  }

  static String get appVersion {
    return app?['version'] ?? '0.1.0';
  }

  static bool get debugMode {
    return app?['debugMode'] ?? false;
  }

  // ============================================================================
  // Default Config (fallback)
  // ============================================================================

  static final Map<String, dynamic> _defaultConfig = {
    'app': {'name': 'Idle Unclicker', 'version': '0.1.0', 'debugMode': false},
    'features': {
      'core': {
        'ascension': {'enabled': true},
        'characterCreation': {'enabled': true},
        'offlineProgression': {'enabled': true},
        'playerAutomaton': {'enabled': true},
      },
      'phase1': {
        'skillTree': {'enabled': false},
        'bestiary': {'enabled': false},
      },
      'phase2': {
        'mercenaries': {'enabled': false},
        'guildHall': {'enabled': false},
      },
      'phase3': {
        'enchanting': {'enabled': false},
        'bossRush': {'enabled': false},
        'professions': {'enabled': false},
      },
      'debug': {
        'debugMode': {'enabled': false},
        'fastCombat': {'enabled': false},
      },
    },
    'gameplay': {
      'offlineProgression': {'minHours': 8, 'maxCycles': 100},
    },
  };
}
