import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/companion.dart';
import '../providers/game_provider.dart';

class CompanionsScreen extends StatelessWidget {
  const CompanionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'COMPANIONS',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final roster = game.companionRoster;
          if (roster == null) {
            return const Center(
              child: Text(
                'Companion system initializing...',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Party stats
                _buildPartyStats(roster),
                const SizedBox(height: 24),

                // Current companions
                const Text(
                  'YOUR PARTY',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (roster.companions.isEmpty)
                  _buildEmptyParty()
                else
                  ...roster.companions.map(
                    (c) => _buildCompanionCard(c, context),
                  ),

                const SizedBox(height: 24),

                // Available to hire (only in town)
                if (game.inTown) ...[
                  const Text(
                    'AVAILABLE FOR HIRE',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHiringSection(game, roster),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartyStats(CompanionRoster roster) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'Party Size',
                '${roster.companions.length}/${roster.maxCompanions}',
              ),
              _buildStatColumn('Power', '${roster.partyPower}'),
              _buildStatColumn('Deserted', '${roster.totalDeserted}'),
            ],
          ),
          if (roster.missingRoles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Missing: ${roster.missingRoles.join(', ')}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
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
            color: Colors.orange,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyParty() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Your party is empty.\nHire companions in town!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCompanionCard(Companion companion, BuildContext context) {
    final roleColors = {
      'tank': Colors.blue,
      'healer': Colors.green,
      'dps': Colors.red,
      'scout': Colors.purple,
    };

    final roleIcons = {
      'tank': Icons.shield,
      'healer': Icons.healing,
      'dps': Icons.sports_kabaddi,
      'scout': Icons.visibility,
    };

    final color = roleColors[companion.role] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(roleIcons[companion.role], color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companion.name,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${companion.role.toUpperCase()} - Lv.${companion.level}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(companion.status, style: const TextStyle(fontSize: 12)),
                  if (!companion.isActive)
                    TextButton(
                      onPressed: () {
                        // Would need method to revive
                      },
                      child: const Text(
                        'Revive',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // HP bar
          Row(
            children: [
              const Text(
                'HP: ',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: companion.maxHealth > 0
                      ? companion.currentHealth / companion.maxHealth
                      : 0,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    companion.currentHealth > companion.maxHealth * 0.5
                        ? Colors.green
                        : Colors.red,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${companion.currentHealth}/${companion.maxHealth}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Loyalty bar
          Row(
            children: [
              const Text(
                'Loyalty: ',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: companion.loyalty,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    companion.loyalty > 0.5 ? Colors.orange : Colors.red,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(companion.loyalty * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'ATK: ${companion.attack}',
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                'DEF: ${companion.defense}',
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                'Kills: ${companion.kills}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHiringSection(GameProvider game, CompanionRoster roster) {
    final available = game.getAvailableCompanions();

    if (available.isEmpty) {
      return const Text(
        'No mercenaries available right now.',
        style: TextStyle(color: Colors.grey),
      );
    }

    if (!roster.canHire) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Your party is full! Dismiss a companion first.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      children: available.map((companion) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companion.name,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${companion.role.toUpperCase()} - Lv.${companion.level}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      companion.roleDescription,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${companion.hireCost}💰',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${companion.dailyCost}/day',
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: (game.character?.gold ?? 0) >= companion.hireCost
                        ? () => game.hireCompanion(companion)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: const Text('HIRE'),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
