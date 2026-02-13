import 'package:hive/hive.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../../domain/value_objects/character_identity.dart';
import '../../domain/value_objects/vitals.dart';
import '../../domain/value_objects/experience.dart';
import '../../domain/value_objects/stats.dart';

/// Hive implementation of CharacterRepository
///
/// Infrastructure layer - handles persistence details
class HiveCharacterRepository implements CharacterRepository {
  static const String boxName = 'characters';
  static const String activeCharacterKey = 'active_character';

  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(boxName);
    return _box!;
  }

  @override
  Future<Character?> findById(CharacterId id) async {
    final b = await box;
    final data = b.get(id.value);
    if (data == null) return null;
    return _fromMap(id.value, data);
  }

  @override
  Future<Character?> findActive() async {
    final b = await box;
    final activeId = b.get(activeCharacterKey)?['id'] as String?;
    if (activeId == null) return null;
    return findById(CharacterId(activeId));
  }

  @override
  Future<void> save(Character character) async {
    final b = await box;
    final data = _toMap(character);

    await b.put(character.id.value, data);

    // Update active character reference
    await b.put(activeCharacterKey, {'id': character.id.value});

    // Clear domain events after successful save
    character.clearDomainEvents();
  }

  @override
  Future<void> delete(CharacterId id) async {
    final b = await box;
    await b.delete(id.value);
  }

  @override
  Future<bool> exists(CharacterId id) async {
    final b = await box;
    return b.containsKey(id.value);
  }

  @override
  Future<int> count() async {
    final b = await box;
    // Subtract 1 for the active_character entry
    return b.length - (b.containsKey(activeCharacterKey) ? 1 : 0);
  }

  // === Mapping Methods ===

  Character _fromMap(String id, Map<dynamic, dynamic> data) {
    return Character(
      id: CharacterId(id),
      identity: CharacterIdentity(
        name: data['name'] ?? 'Unknown',
        race: data['race'] ?? 'Human',
        characterClass: data['characterClass'] ?? 'Warrior',
      ),
      level: data['level'] ?? 1,
      experience: Experience(
        current: (data['experience'] ?? 0.0).toDouble(),
        expToNext: (data['experienceToNext'] ?? 100.0).toDouble(),
      ),
      stats: CharacterStats(
        strength: data['strength'] ?? 10,
        dexterity: data['dexterity'] ?? 10,
        intelligence: data['intelligence'] ?? 10,
        constitution: data['constitution'] ?? 10,
        wisdom: data['wisdom'] ?? 10,
        charisma: data['charisma'] ?? 10,
      ),
      health: Health(
        current: data['currentHealth'] ?? 100,
        max: data['maxHealth'] ?? 100,
      ),
      mana: Mana(
        current: data['currentMana'] ?? 50,
        max: data['maxMana'] ?? 50,
      ),
      unallocatedPoints: data['unallocatedPoints'] ?? 0,
      isAlive: data['isAlive'] ?? true,
      totalDeaths: data['totalDeaths'] ?? 0,
      dungeonDepth: data['dungeonDepth'] ?? 1,
      healthPotions: data['healthPotions'] ?? 3,
      gold: data['gold'] ?? 0,
      weaponType: data['weaponType'] ?? 'balanced',
      armorType: data['armorType'] ?? 'leather',
      weaponSkill: SkillExperience(
        level: data['weaponSkill'] ?? 0,
        currentXP: data['weaponSkillXP'] ?? 0,
      ),
      fightingSkill: SkillExperience(
        level: data['fightingSkill'] ?? 0,
        currentXP: data['fightingSkillXP'] ?? 0,
      ),
      armorSkill: SkillExperience(
        level: data['armorSkill'] ?? 0,
        currentXP: data['armorSkillXP'] ?? 0,
      ),
      dodgingSkill: SkillExperience(
        level: data['dodgingSkill'] ?? 0,
        currentXP: data['dodgingSkillXP'] ?? 0,
      ),
    );
  }

  Map<String, dynamic> _toMap(Character character) {
    return {
      'name': character.identity.name,
      'race': character.identity.race,
      'characterClass': character.identity.characterClass,
      'level': character.level,
      'experience': character.experience.current,
      'experienceToNext': character.experience.expToNext,
      'strength': character.stats.strength,
      'dexterity': character.stats.dexterity,
      'intelligence': character.stats.intelligence,
      'constitution': character.stats.constitution,
      'wisdom': character.stats.wisdom,
      'charisma': character.stats.charisma,
      'currentHealth': character.health.current,
      'maxHealth': character.health.max,
      'currentMana': character.mana.current,
      'maxMana': character.mana.max,
      'unallocatedPoints': character.unallocatedPoints,
      'isAlive': character.isAlive,
      'totalDeaths': character.totalDeaths,
      'dungeonDepth': character.dungeonDepth,
      'healthPotions': character.healthPotions,
      'gold': character.gold,
      'weaponType': character.weaponType,
      'armorType': character.armorType,
      'weaponSkill': character.weaponSkill.level,
      'weaponSkillXP': character.weaponSkill.currentXP,
      'fightingSkill': character.fightingSkill.level,
      'fightingSkillXP': character.fightingSkill.currentXP,
      'armorSkill': character.armorSkill.level,
      'armorSkillXP': character.armorSkill.currentXP,
      'dodgingSkill': character.dodgingSkill.level,
      'dodgingSkillXP': character.dodgingSkill.currentXP,
    };
  }
}
