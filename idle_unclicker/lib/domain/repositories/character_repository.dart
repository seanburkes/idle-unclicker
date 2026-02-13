import '../entities/character.dart';
import '../value_objects/character_identity.dart';

/// Repository interface for Character aggregate
///
/// This is a domain-layer interface that defines the contract
/// for character persistence. Implementations live in the
/// infrastructure layer.
///
/// DDD Pattern: Repository
abstract class CharacterRepository {
  /// Finds a character by its unique ID
  /// Returns null if not found
  Future<Character?> findById(CharacterId id);

  /// Finds the active/main character
  /// Returns null if no character exists
  Future<Character?> findActive();

  /// Saves a character (create or update)
  /// Persists all domain events as part of the transaction
  Future<void> save(Character character);

  /// Deletes a character permanently
  Future<void> delete(CharacterId id);

  /// Checks if a character with given ID exists
  Future<bool> exists(CharacterId id);

  /// Gets the total count of characters
  Future<int> count();
}
