import '../entities/game_state.dart';
import '../entities/guild_hall.dart';

/// Repository interface for GameState
abstract class GameStateRepository {
  /// Get the global game state
  Future<GameState?> getGameState();

  /// Save game state
  Future<void> save(GameState gameState);

  /// Check if game state exists
  Future<bool> exists();
}

/// Repository interface for GuildHall
abstract class GuildHallRepository {
  /// Find Guild Hall by game state ID
  Future<GuildHall?> findByGameStateId(String gameStateId);

  /// Save Guild Hall
  Future<void> save(GuildHall guildHall);

  /// Check if Guild Hall exists
  Future<bool> exists(String gameStateId);
}
