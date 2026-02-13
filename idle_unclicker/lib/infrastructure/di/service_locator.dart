import 'package:hive/hive.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/guild_hall.dart';
import '../../domain/repositories/character_repository.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/meta_progression_repository.dart';
import '../../domain/services/combat_service.dart';
import '../../domain/services/equipment_service.dart';
import '../../domain/services/meta_progression_service.dart';
import '../../application/services/combat_application_service.dart';
import '../../application/services/equipment_application_service.dart';
import '../../application/services/meta_progression_application_service.dart';
import '../repositories/hive_character_repository.dart';
import '../repositories/hive_equipment_repository.dart';
import '../repositories/hive_game_state_repository.dart';
import '../repositories/hive_guild_hall_repository.dart';

/// Simple Service Locator for Dependency Injection
///
/// Provides centralized access to all services and repositories
/// throughout the application. This is a lightweight implementation
/// that doesn't require external packages.
class ServiceLocator {
  static final Map<Type, Object> _services = {};
  static final Map<Type, Object Function()> _factories = {};
  static bool _initialized = false;

  /// Check if initialized
  static bool get isInitialized => _initialized;

  /// Initialize all services and repositories
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Hive boxes
    await _initializeHive();

    // Register repositories
    await _registerRepositories();

    // Register domain services
    _registerDomainServices();

    // Register application services
    _registerApplicationServices();

    _initialized = true;
  }

  /// Register a singleton service
  static void registerSingleton<T extends Object>(T instance) {
    _services[T] = instance;
  }

  /// Register a lazy singleton (factory that creates on first access)
  static void registerLazySingleton<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Get a registered service
  static T get<T extends Object>() {
    if (!_initialized) {
      throw StateError(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }

    // Return existing singleton
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }

    // Create from factory
    if (_factories.containsKey(T)) {
      final instance = _factories[T]!() as T;
      _services[T] = instance;
      return instance;
    }

    throw StateError('Service of type $T not registered');
  }

  /// Check if a service is registered
  static bool isRegistered<T extends Object>() {
    return _services.containsKey(T) || _factories.containsKey(T);
  }

  /// Initialize Hive boxes
  static Future<void> _initializeHive() async {
    // Hive is already initialized in main.dart
    // Just ensure boxes are open
    await Hive.openBox<Map>('characters');
    await Hive.openBox<Map>('equipment');
    await Hive.openBox<Map>('character_inventories');
    await Hive.openBox<Map>('game_state');
    await Hive.openBox<Map>('guild_halls');
  }

  /// Register all repositories
  static Future<void> _registerRepositories() async {
    // Character Repository
    if (!isRegistered<CharacterRepository>()) {
      registerLazySingleton<CharacterRepository>(
        () => HiveCharacterRepository(),
      );
    }

    // Equipment Repository
    if (!isRegistered<EquipmentRepository>()) {
      registerLazySingleton<EquipmentRepository>(
        () => HiveEquipmentRepository(),
      );
    }

    // Character Inventory Repository
    if (!isRegistered<CharacterInventoryRepository>()) {
      registerLazySingleton<CharacterInventoryRepository>(
        () => HiveCharacterInventoryRepository(get<EquipmentRepository>()),
      );
    }

    // Game State Repository
    if (!isRegistered<GameStateRepository>()) {
      registerLazySingleton<GameStateRepository>(
        () => HiveGameStateRepository(),
      );
    }

    // Guild Hall Repository
    if (!isRegistered<GuildHallRepository>()) {
      registerLazySingleton<GuildHallRepository>(
        () => HiveGuildHallRepository(),
      );
    }
  }

  /// Register domain services
  static void _registerDomainServices() {
    // Combat Service
    if (!isRegistered<CombatService>()) {
      registerLazySingleton<CombatService>(() => CombatService());
    }

    // Equipment Service
    if (!isRegistered<EquipmentService>()) {
      registerLazySingleton<EquipmentService>(() => EquipmentService());
    }

    // Meta-Progression Service
    if (!isRegistered<MetaProgressionService>()) {
      registerLazySingleton<MetaProgressionService>(
        () => MetaProgressionService(),
      );
    }
  }

  /// Register application services
  static void _registerApplicationServices() {
    // Combat Application Service
    if (!isRegistered<CombatApplicationService>()) {
      registerLazySingleton<CombatApplicationService>(
        () => CombatApplicationService(
          characterRepository: get<CharacterRepository>(),
          combatService: get<CombatService>(),
        ),
      );
    }

    // Equipment Application Service
    if (!isRegistered<EquipmentApplicationService>()) {
      registerLazySingleton<EquipmentApplicationService>(
        () => EquipmentApplicationService(
          equipmentRepository: get<EquipmentRepository>(),
          inventoryRepository: get<CharacterInventoryRepository>(),
          characterRepository: get<CharacterRepository>(),
          equipmentService: get<EquipmentService>(),
        ),
      );
    }

    // Meta-Progression Application Service
    if (!isRegistered<MetaProgressionApplicationService>()) {
      registerLazySingleton<MetaProgressionApplicationService>(
        () => MetaProgressionApplicationService(
          gameStateRepository: get<GameStateRepository>(),
          guildHallRepository: get<GuildHallRepository>(),
          characterRepository: get<CharacterRepository>(),
          metaProgressionService: get<MetaProgressionService>(),
        ),
      );
    }
  }

  /// Reset all registrations (useful for testing)
  static void reset() {
    _services.clear();
    _factories.clear();
    _initialized = false;
  }
}

/// Extension for easy access to services
extension ServiceLocatorExtension on Object {
  /// Get service from locator
  T locate<T extends Object>() => ServiceLocator.get<T>();
}
