import 'dart:math';

class ProceduralGenerator {
  static final Random _random = Random.secure();

  static final List<String> _racePrefixes = [
    'Half',
    'Double',
    'Triple',
    'Demi',
    'Semi',
    'Enchanted',
    'Cursed',
    'Blessed',
    'Elder',
    'Young',
    'Ancient',
    'Neo',
    'Cyber',
  ];

  static final List<String> _raceCores = [
    'Orc',
    'Elf',
    'Human',
    'Dwarf',
    'Gnome',
    'Halfling',
    'Goblin',
    'Troll',
    'Dragon',
    'Giant',
    'Slime',
    'Robot',
    'Android',
    'Motorcycle',
    'Toaster',
    'Sandwich',
    'Corporate',
    'Bureaucrat',
    'Manager',
    'Employee',
    'Contractor',
    'Freelancer',
  ];

  static final List<String> _classPrefixes = [
    'Ur',
    'Arch',
    'Grand',
    'Senior',
    'Junior',
    'Associate',
    'Executive',
    'Chief',
    'Vice',
    'Assistant',
    'Deputy',
    'Regional',
  ];

  static final List<String> _classCores = [
    'Paladin',
    'Wizard',
    'Rogue',
    'Fighter',
    'Cleric',
    'Monk',
    'Ranger',
    'Warlock',
    'Sorcerer',
    'Bard',
    'Druid',
    'Barbarian',
    'Knight',
    'Princess',
    'Prince',
    'King',
    'Queen',
    'Jester',
    'Mimic',
    'Accountant',
    'Manager',
    'Analyst',
    'Consultant',
    'Developer',
    'Designer',
    'Marketing',
    'Sales',
    'HR',
    'Operations',
  ];

  static final List<String> _classSuffixes = [
    'of Doom',
    'of Light',
    'of Darkness',
    'of Shadow',
    'of Flames',
    'of Ice',
    'of Thunder',
    'of Finance',
    'of Operations',
    'of Sales',
    'of Marketing',
    'of HR',
    'of IT',
    'the Destroyer',
    'the Builder',
    'the Analyst',
  ];

  static final List<String> _monsterAdjectives = [
    'small',
    'tiny',
    'sick',
    'crippled',
    'undernourished',
    'weak',
    'average',
    'normal',
    'healthy',
    'strong',
    'greater',
    'massive',
    'enormous',
    'giant',
    'titanic',
    'legendary',
    'mythic',
  ];

  static final List<String> _monsterTypes = [
    'Elemental',
    'Giant',
    'Dragon',
    'Goblin',
    'Orc',
    'Troll',
    'Slime',
    'Beast',
    'Construct',
    'Undead',
    'Demon',
    'Angel',
    'Fae',
    'Accountant',
    'Manager',
    'Consultant',
    'Intern',
    'Contractor',
    'Beholder',
    'Mimic',
    'Ooze',
    'Blob',
    'Gelatinous Cube',
  ];

  static final List<String> _monsterElements = [
    'Fire',
    'Ice',
    'Thunder',
    'Earth',
    'Wind',
    'Water',
    'Light',
    'Dark',
    'Nature',
    'Arcane',
    'Cosmic',
    'Void',
    'Excel',
    'PowerPoint',
    'Email',
    'Meeting',
    'Deadline',
    'Budget',
  ];

  static final List<String> _weaponPrefixes = [
    'Rusty',
    'Broken',
    'Bent',
    'Tarnished',
    'Dull',
    'Polished',
    'Sharp',
    'Keen',
    'Vicious',
    'Deadly',
    'Legendary',
    'Mythic',
  ];

  static final List<String> _weaponTypes = [
    'Sword',
    'Axe',
    'Mace',
    'Spear',
    'Dagger',
    'Staff',
    'Wand',
    'Bow',
    'Crossbow',
    'Hammer',
    'Flail',
    'Whip',
    'Claw',
    'Keyboard',
    'Mouse',
    'Monitor',
    'Printer',
    'Stapler',
    'Pen',
    'Marker',
    'Whiteboard',
    'Projector',
  ];

  static final List<String> _armorMaterials = [
    'Cloth',
    'Leather',
    'Hide',
    'Studded',
    'Chain',
    'Scale',
    'Plate',
    'Mithril',
    'Adamantine',
    'Dragon',
    'Demon',
    'Paper',
    'Cardboard',
    'Plastic',
    'Fiberglass',
    'Carbon',
  ];

  static final List<String> _armorPieces = [
    'Helm',
    'Chest',
    'Legs',
    'Boots',
    'Gloves',
    'Bracers',
    'Pauldrons',
    'Greaves',
    'Vambraces',
    'Cuirass',
    'Gauntlets',
  ];

  static final List<String> _suffixes = [
    'of Power',
    'of Wisdom',
    'of Strength',
    'of Agility',
    'of Intelligence',
    'of Fortitude',
    'of Luck',
    'of Budget Cuts',
    'of Layoffs',
    'of Meetings',
    'of Overtime',
    'of Weekend Work',
    'of Unpaid Internships',
    'the Destroyer',
    'the Protector',
    'the Analyzer',
  ];

  static String generateRace() {
    final usePrefix = _random.nextBool();
    final prefix = usePrefix ? _randomElement(_racePrefixes) : '';
    final core = _randomElement(_raceCores);
    return usePrefix ? '$prefix $core' : core;
  }

  static String generateClass() {
    final parts = <String>[];

    if (_random.nextDouble() < 0.4) {
      parts.add(_randomElement(_classPrefixes));
    }

    parts.add(_randomElement(_classCores));

    if (_random.nextDouble() < 0.2) {
      parts.add(_randomElement(_classSuffixes));
    }

    return parts.join(' ');
  }

  static String generateCharacterClass() {
    return '${generateRace()} ${generateClass()}';
  }

  static String generateMonster(int playerLevel) {
    final element = _randomElement(_monsterElements);
    final type = _randomElement(_monsterTypes);

    String adjective = '';
    final roll = _random.nextInt(100);
    if (roll < 20) {
      adjective = _randomElement(_monsterAdjectives.sublist(0, 5));
    } else if (roll > 80) {
      adjective = _randomElement(_monsterAdjectives.sublist(10));
    }

    if (adjective.isNotEmpty) {
      return '$adjective $element $type';
    }
    return '$element $type';
  }

  static String generateWeapon() {
    final parts = <String>[
      _randomElement(_weaponPrefixes),
      _randomElement(_weaponTypes),
    ];

    if (_random.nextDouble() < 0.3) {
      parts.add(_randomElement(_suffixes));
    }

    return parts.join(' ');
  }

  static String generateArmor() {
    final parts = <String>[
      _randomElement(_armorMaterials),
      _randomElement(_armorPieces),
    ];

    if (_random.nextDouble() < 0.3) {
      parts.add(_randomElement(_suffixes));
    }

    return parts.join(' ');
  }

  static String generateEquipment(String slot) {
    if (slot == 'Weapon') {
      return generateWeapon();
    }
    return generateArmor();
  }

  static String generateTrap() {
    final traps = [
      'Spike Trap',
      'Poison Gas',
      'Falling Rocks',
      'Tripwire',
      'Bear Trap',
      'Pitfall',
      'Arrow Trap',
      'Magic Sigil',
      'Sudden Meeting',
      'Unexpected Email',
      'Budget Review',
      'Performance Review',
      'Team Building Exercise',
    ];
    return _randomElement(traps);
  }

  static String generateHardship() {
    final hardships = [
      'Tax Audit',
      'Budget Cuts',
      'Layoffs',
      'Merger',
      'Restructuring',
      'Downsizing',
      'Outsourcing',
      'Unpaid Overtime',
      'Weekend Work',
      'Holiday Shift',
      ' micromanagement',
      'Bureaucracy',
      'Red Tape',
      'Server Downtime',
      'Software Update',
      'Password Expired',
    ];
    return _randomElement(hardships);
  }

  static String generateAbility() {
    final abilities = [
      'Slack Off',
      'Power Nap',
      'Coffee Break',
      'Email Dodge',
      'Meeting Skip',
      'Deadline Extension',
      'Budget Manipulation',
      'Blame Shift',
      'Credit Steal',
      'Office Politics',
      'Spreadsheet Mastery',
      'Presentation Wizard',
      'Conference Call Nap',
      'Invisible Worker',
      'Silent Quitting',
      'Quiet Firing',
    ];
    return _randomElement(abilities);
  }

  static T _randomElement<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  static int rollDice(int sides, {int count = 1}) {
    int total = 0;
    for (int i = 0; i < count; i++) {
      total += _random.nextInt(sides) + 1;
    }
    return total;
  }

  static bool rollPercent(int chance) {
    return _random.nextInt(100) < chance;
  }
}
