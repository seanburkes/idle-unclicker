import 'dart:math';

/// Silly character creation options for first-time players
class CharacterCreationGenerator {
  static final Random _random = Random();

  // Silly races with descriptions
  static final Map<String, String> _sillyRaces = {
    'Sentient Turnip':
        'Root vegetable given consciousness by a typo in a spell',
    'Gazebo': 'Nobody knows how you became aware. You just... are.',
    'Spoon Enthusiast': 'Humanoid, but really into spoons. Uncomfortably so.',
    'Part-Time Ghost': 'Only spectral on weekends and bank holidays',
    'Retired Meme': 'You were funny in 2012. Now you dungeon dive.',
    'Aggressive Breadstick': 'Crispy. Salty. Vengeful.',
    'Garden Gnome': 'Escaped lawn ornament seeking purpose',
    'Definitely Not A Mimic':
        'Totally normal adventurer. Pay no attention to the hinges.',
    'Caffeinated Squirrel':
        'Too much coffee. Unlimited energy. Poor impulse control.',
    'Unfinished Drawing': 'The artist got bored halfway through your legs',
    'Sentient Pile of Laundry':
        'You\'re clean-ish and you\'re mobile. That\'s enough.',
    'Budget Wizard': 'Could only afford 60% of wizard school tuition',
  };

  // Silly classes with descriptions
  static final Map<String, String> _sillyClasses = {
    'Aggressive Hugger': 'Attack enemies with unwanted physical affection',
    'Part-Time Lich': 'Only mostly undead. Full dental benefits.',
    'Professional Procrastinator':
        'Will deal damage eventually, maybe tomorrow',
    'Tax Accountant': 'Your audits are lethal and your deductions devastating',
    'Passive-Aggressive Bard':
        'Insults enemies until they lose the will to live',
    'Disc Golfer': 'Throws enchanted frisbees with questionable aerodynamics',
    'Overly Enthusiastic Intern': 'Underpaid but eager to please and/or stab',
    'Retired Clown': 'Honks of doom. Fear the rubber chicken.',
    'Amateur Philosopher': 'Bores enemies with existential dread',
    'Cat Herder': 'Somehow wrangles chaos itself into combat formation',
    'Mall Santa': 'Knows when you\'ve been naughty. Punishes accordingly.',
    'Unlicensed Therapist':
        'Fixes your emotional damage by causing physical damage',
  };

  // Regular stats
  static final List<String> _coreStats = [
    'STR', // Strength
    'DEX', // Dexterity
    'CON', // Constitution
    'INT', // Intelligence
    'WIS', // Wisdom
    'CHA', // Charisma
  ];

  // Silly additional stats
  static final Map<String, String> _sillyStats = {
    'LUK': 'Luck - Affects nothing. Or everything. Nobody knows.',
    'CHAOS': 'Chaos - Makes dice rolls more dramatic',
    'SPARK': 'Sparkle - How shiny you are in direct sunlight',
    'RIzz': 'Rizz - Your inexplicable ability to charm inanimate objects',
    'VIBE': 'Vibe - The energy you bring to the dungeon',
    'SASS': 'Sass - Backtalk damage multiplier',
    'GNUT': 'Gumption - Sheer stubbornness as a measurable quantity',
    'MOIST': 'Moistness - Resistance to fire, weakness to disgust',
  };

  /// Get 3 random race options
  static List<MapEntry<String, String>> getRandomRaces() {
    final races = _sillyRaces.entries.toList()..shuffle(_random);
    return races.take(3).toList();
  }

  /// Get 3 random class options
  static List<MapEntry<String, String>> getRandomClasses() {
    final classes = _sillyClasses.entries.toList()..shuffle(_random);
    return classes.take(3).toList();
  }

  /// Get 2 random silly stats to add to the core 6
  static List<MapEntry<String, String>> getRandomSillyStats() {
    final stats = _sillyStats.entries.toList()..shuffle(_random);
    return stats.take(2).toList();
  }

  /// Roll 3d6 for a stat
  static int rollStat() {
    return _random.nextInt(6) +
        1 +
        _random.nextInt(6) +
        1 +
        _random.nextInt(6) +
        1;
  }

  /// Roll with dramatic flair (for animation)
  static List<int> generateRollSequence() {
    // Returns a sequence of numbers for animation
    return List.generate(10, (_) => _random.nextInt(16) + 3);
  }

  /// Get a funny random name suggestion
  static String getRandomNameSuggestion() {
    final prefixes = [
      'Sir',
      'Lady',
      'Captain',
      'Doctor',
      'Professor',
      'Grandpa',
      'Auntie',
      'Deputy',
      'Junior',
      'The Other',
      'Fake',
      'Assistant',
    ];

    final names = [
      'Flumbles',
      'Zorp',
      'Chadwick',
      'Bingles',
      'Skippy',
      'Mort',
      'Blibble',
      'Crouton',
      'Jerry (the other one)',
      'Stinky',
      'Noodle',
      'Dingus',
      'Carl',
      'Beef',
      'Todd',
      'Sparkles',
      'Gorb',
    ];

    final suffixes = [
      'the Slightly Brave',
      'the Confused',
      'III',
      'Jr.',
      'the Unwise',
      '(not that one)',
      'of Questionable Intent',
      'the Dungeon-Curious',
      '(they/them)',
      'esquire',
      'from Accounting',
      'the Reluctant',
    ];

    final prefix = prefixes[_random.nextInt(prefixes.length)];
    final name = names[_random.nextInt(names.length)];
    final suffix = _random.nextInt(3) == 0
        ? ''
        : ' ${suffixes[_random.nextInt(suffixes.length)]}';

    return '$prefix $name$suffix';
  }

  /// Get a funny death-preparation message
  static String getInevitableDoomMessage() {
    final messages = [
      'Warning: Character will likely die horribly.',
      'Terms of Service: Death is guaranteed.',
      'Fun fact: 100% of adventurers die eventually!',
      'Insurance Status: Denied.',
      'Life expectancy: Surprisingly short!',
      'Please sign the waiver acknowledging your impending doom.',
      'Remember: It\'s not "dying," it\'s "becoming an Echo."',
      'Your character has a 401(k) and named you beneficiary. Cute.',
    ];
    return messages[_random.nextInt(messages.length)];
  }
}
