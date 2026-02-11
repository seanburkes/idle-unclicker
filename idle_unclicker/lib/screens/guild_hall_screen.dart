import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/guild_hall.dart';
import '../services/guild_hall_service.dart';
import '../providers/game_provider.dart';

class GuildHallScreen extends StatelessWidget {
  const GuildHallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'GUILD HALL',
          style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final guildHall = game.guildHall;
          final guildService = game.guildHallService;

          if (guildHall == null || guildService == null) {
            return const Center(
              child: Text(
                'Guild Hall initializing...',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          if (!guildService.isUnlocked) {
            return _buildLockedState();
          }

          final summary = guildService.getSummary();
          final rooms = guildService.getAllRooms();
          final echoes = guildService.getWanderingEchoes();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with stats
                _buildHeader(summary),
                const SizedBox(height: 24),

                // Echoes display
                if (echoes.isNotEmpty) ...[
                  _buildEchoesSection(echoes),
                  const SizedBox(height: 24),
                ],

                // Rooms section
                const Text(
                  'ROOMS',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...rooms.map((room) => _buildRoomCard(room, game)),

                const SizedBox(height: 24),

                // Total bonuses
                _buildBonusesSection(guildService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLockedState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, color: Colors.grey[600], size: 48),
            const SizedBox(height: 16),
            const Text(
              'GUILD HALL LOCKED',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete your first Ascension to unlock the Echo Sanctuary.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your past heroes will wander here forever.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'ECHO SANCTUARY',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'Room Levels',
                '${summary['totalLevels']}/${summary['maxLevels']}',
              ),
              _buildStatColumn('Echoes', '${summary['echoCount']}'),
              _buildStatColumn('Invested', '${summary['totalInvested']}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }

  Widget _buildEchoesSection(List<EchoNPC> echoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WANDERING ECHOES',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.black,
          ),
          child: Stack(
            children: echoes.asMap().entries.map((entry) {
              final index = entry.key;
              final echo = entry.value;
              // Position echoes in different spots
              final positions = [
                Alignment(-0.7, -0.5),
                Alignment(0.7, 0.3),
                Alignment(-0.3, 0.6),
                Alignment(0.5, -0.4),
              ];
              final position = positions[index % positions.length];

              return Align(
                alignment: position,
                child: Tooltip(
                  message: '${echo.displayTitle}\n${echo.fate}',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(echo.classColor.replaceFirst('#', '0xFF')),
                      ).withOpacity(0.2),
                      border: Border.all(
                        color: Color(
                          int.parse(echo.classColor.replaceFirst('#', '0xFF')),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '👤',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(
                              int.parse(
                                echo.classColor.replaceFirst('#', '0xFF'),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          echo.name.split(' ').first,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(Room room, GameProvider game) {
    final canAfford =
        game.guildHallService?.canAfford(
          room.type,
          game.character?.gold ?? 0,
        ) ??
        false;
    final isMaxLevel = room.isMaxLevel;

    Color roomColor;
    switch (room.type) {
      case 'trainingHall':
        roomColor = Colors.red;
        break;
      case 'treasury':
        roomColor = Colors.amber;
        break;
      case 'library':
        roomColor = Colors.blue;
        break;
      case 'smithy':
        roomColor = Colors.orange;
        break;
      default:
        roomColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: roomColor),
        borderRadius: BorderRadius.circular(8),
        color: roomColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(room.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name.toUpperCase(),
                      style: TextStyle(
                        color: roomColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      room.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: roomColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Lv.${room.level}/${GuildHall.maxRoomLevel}',
                  style: TextStyle(
                    color: roomColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (!isMaxLevel) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Upgrade Cost: ${room.upgradeCost}g',
                    style: TextStyle(
                      color: canAfford ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: canAfford
                      ? () => game.upgradeGuildHallRoom(room.type)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roomColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('UPGRADE'),
                ),
              ],
            ),
          ],
          if (isMaxLevel) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Maximum Level Reached',
                  style: TextStyle(color: Colors.green, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBonusesSection(GuildHallService guildService) {
    final bonuses = guildService.getBonuses();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE BONUSES',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildBonusRow(
            '🏋️ Skill XP',
            '+${(((bonuses['skillXpMultiplier'] ?? 1.0) - 1.0) * 100).toStringAsFixed(0)}%',
            Colors.red,
          ),
          _buildBonusRow(
            '💰 Gold Find',
            '+${(((bonuses['goldFindMultiplier'] ?? 1.0) - 1.0) * 100).toStringAsFixed(0)}%',
            Colors.amber,
          ),
          _buildBonusRow(
            '📚 Bestiary Rate',
            '+${(((bonuses['bestiaryRateMultiplier'] ?? 1.0) - 1.0) * 100).toStringAsFixed(0)}%',
            Colors.blue,
          ),
          _buildBonusRow(
            '⚒️ Equipment Quality',
            '+${(((bonuses['equipmentDropMultiplier'] ?? 1.0) - 1.0) * 100).toStringAsFixed(0)}%',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildBonusRow(String icon, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              icon.split(' ').last,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
