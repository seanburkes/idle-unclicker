import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/character_creation_generator.dart';

class CharacterCreationScreen extends StatefulWidget {
  final Function(
    String name,
    String race,
    String className,
    Map<String, int> stats,
  )
  onCreate;

  const CharacterCreationScreen({super.key, required this.onCreate});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final Random _random = Random();

  // Options presented to player
  late List<MapEntry<String, String>> _raceOptions;
  late List<MapEntry<String, String>> _classOptions;
  late List<MapEntry<String, String>> _sillyStatDescriptions;

  // Selected values
  String? _selectedRace;
  String? _selectedClass;

  // Stats
  final Map<String, int> _finalStats = {};
  final Map<String, List<int>> _rollingStats = {};
  bool _isRolling = false;
  bool _hasRolled = false;

  // Animation
  late AnimationController _diceController;
  Timer? _rollTimer;

  @override
  void initState() {
    super.initState();
    _generateOptions();
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diceController.dispose();
    _rollTimer?.cancel();
    super.dispose();
  }

  void _generateOptions() {
    _raceOptions = CharacterCreationGenerator.getRandomRaces();
    _classOptions = CharacterCreationGenerator.getRandomClasses();
    _sillyStatDescriptions = CharacterCreationGenerator.getRandomSillyStats();

    // Pre-populate name with a suggestion
    _nameController.text = CharacterCreationGenerator.getRandomNameSuggestion();
  }

  void _rollStats() {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
      _hasRolled = false;
      _finalStats.clear();
      _rollingStats.clear();
    });

    // Core stats
    final coreStats = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
    final allStats = [
      ...coreStats,
      ..._sillyStatDescriptions.map((e) => e.key),
    ];

    // Initialize rolling animation sequences
    for (final stat in allStats) {
      _rollingStats[stat] = CharacterCreationGenerator.generateRollSequence();
    }

    // Animate dice rolling
    int tick = 0;
    _rollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        for (final stat in allStats) {
          if (tick < _rollingStats[stat]!.length) {
            // Show rolling number
          }
        }
      });

      tick++;
      if (tick >= 10) {
        timer.cancel();
        _finalizeStats(allStats);
      }
    });

    // Animate dice shake
    _diceController.forward(from: 0);
  }

  void _finalizeStats(List<String> allStats) {
    setState(() {
      for (final stat in allStats) {
        _finalStats[stat] = CharacterCreationGenerator.rollStat();
      }
      _isRolling = false;
      _hasRolled = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _createCharacter() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your character needs a name!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedRace == null || _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a race and class!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_hasRolled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roll for your stats first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    widget.onCreate(
      _nameController.text.trim(),
      _selectedRace!,
      _selectedClass!,
      _finalStats,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Center(
                child: Column(
                  children: [
                    Text(
                      'CREATE YOUR HERO',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '(Results may vary. No refunds.)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name input
              _buildSectionTitle('NAME YOUR CHARACTER'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter name...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.casino, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        _nameController.text =
                            CharacterCreationGenerator.getRandomNameSuggestion();
                      });
                    },
                    tooltip: 'Random name',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Race selection
              _buildSectionTitle('CHOOSE YOUR ORIGIN'),
              const SizedBox(height: 8),
              ..._raceOptions.map((race) => _buildRaceCard(race)),
              const SizedBox(height: 24),

              // Class selection
              _buildSectionTitle('CHOOSE YOUR PATH'),
              const SizedBox(height: 8),
              ..._classOptions.map((cls) => _buildClassCard(cls)),
              const SizedBox(height: 24),

              // Stats section
              _buildSectionTitle('ROLL FOR STATS'),
              const SizedBox(height: 8),
              Text(
                'Rolling 3d6 for each stat. May the odds be ever in your favor.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 12),

              // Roll button
              if (!_hasRolled) ...[
                Center(
                  child: AnimatedBuilder(
                    animation: _diceController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isRolling
                            ? _diceController.value * 4 * 3.14159
                            : 0,
                        child: ElevatedButton.icon(
                          onPressed: _isRolling ? null : _rollStats,
                          icon: const Icon(Icons.casino),
                          label: Text(_isRolling ? 'Rolling...' : 'ROLL DICE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Display rolled stats
                _buildStatsDisplay(),
              ],

              const SizedBox(height: 32),

              // Warning message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        CharacterCreationGenerator.getInevitableDoomMessage(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createCharacter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canCreate()
                        ? Colors.green
                        : Colors.grey[800],
                    foregroundColor: _canCreate() ? Colors.black : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text(
                    'BEGIN ADVENTURE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  bool _canCreate() {
    return _nameController.text.trim().isNotEmpty &&
        _selectedRace != null &&
        _selectedClass != null &&
        _hasRolled;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.green,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildRaceCard(MapEntry<String, String> race) {
    final isSelected = _selectedRace == race.key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRace = race.key;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.black,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.key,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    race.value,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(MapEntry<String, String> cls) {
    final isSelected = _selectedClass == cls.key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedClass = cls.key;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.black,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.key,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cls.value,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsDisplay() {
    final coreStats = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
    final sillyStatKeys = _sillyStatDescriptions.map((e) => e.key).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Core stats
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ...coreStats.map(
                (stat) => _buildStatBox(stat, _getStatColor(stat)),
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          // Silly stats
          const Text(
            'BONUS STATS',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ...sillyStatKeys.map((stat) => _buildSillyStatBox(stat)),
            ],
          ),
          const SizedBox(height: 12),
          // Reroll button
          TextButton.icon(
            onPressed: _isRolling ? null : _rollStats,
            icon: const Icon(Icons.refresh),
            label: const Text('REROLL STATS'),
            style: TextButton.styleFrom(foregroundColor: Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String stat, Color color) {
    final value = _finalStats[stat] ?? 0;
    final modifier = (value - 10) ~/ 2;
    final modString = modifier >= 0 ? '+$modifier' : '$modifier';

    return Container(
      width: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            stat,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            modString,
            style: TextStyle(
              color: modifier >= 0 ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSillyStatBox(String stat) {
    final value = _finalStats[stat] ?? 0;
    final description = _sillyStatDescriptions
        .firstWhere((e) => e.key == stat, orElse: () => const MapEntry('', ''))
        .value;

    return Tooltip(
      message: description,
      child: Container(
        width: 70,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              stat,
              style: const TextStyle(
                color: Colors.purple,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatColor(String stat) {
    switch (stat) {
      case 'STR':
        return Colors.red;
      case 'DEX':
        return Colors.green;
      case 'CON':
        return Colors.orange;
      case 'INT':
        return Colors.blue;
      case 'WIS':
        return Colors.cyan;
      case 'CHA':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
