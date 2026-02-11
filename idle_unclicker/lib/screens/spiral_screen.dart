import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/infinite_spiral.dart';
import '../services/spiral_service.dart';

class SpiralScreen extends StatelessWidget {
  const SpiralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final spiral = game.spiral;
        final spiralService = game.spiralService;

        if (spiral == null || spiralService == null) {
          return const Center(
            child: Text(
              'The Spiral awaits...',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final loopInfo = spiralService.getCurrentLoopInfo();
        final stats = spiralService.getSpiralStatistics();
        final talesInfo = spiralService.getTalesInfo();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with loop info
              _buildLoopHeader(loopInfo, spiral),
              const SizedBox(height: 20),

              // Legend progress (if applicable)
              if (stats['talesCompleted'] as int > 0) ...[
                _buildLegendProgress(stats),
                const SizedBox(height: 20),
              ],

              // Multipliers display
              _buildMultipliers(loopInfo),
              const SizedBox(height: 20),

              // Auto-advance toggle
              _buildAutoAdvanceToggle(context, spiral),
              const SizedBox(height: 20),

              // Tales collection
              _buildTalesSection(talesInfo),
              const SizedBox(height: 20),

              // Loop history
              if ((stats['totalLoops'] as int) > 0) ...[
                _buildLoopHistory(spiralService),
                const SizedBox(height: 20),
              ],

              // Spiral statistics
              _buildStatistics(stats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoopHeader(
    Map<String, dynamic> loopInfo,
    InfiniteSpiral spiral,
  ) {
    final loopNumber = loopInfo['loopNumber'] as int;
    final state = loopInfo['state'] as String;
    final stateIcon = loopInfo['stateIcon'] as String;
    final highestFloor = loopInfo['highestFloor'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stateIcon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loop $loopNumber',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    state,
                    style: TextStyle(
                      color: Colors.purple.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Floor progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Floor Progress',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '$highestFloor / 100',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: highestFloor / 100,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  highestFloor >= 100 ? Colors.green : Colors.purple,
                ),
                minHeight: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendProgress(Map<String, dynamic> stats) {
    final talesCompleted = stats['talesCompleted'] as int;
    final talesTotal = stats['talesTotal'] as int;
    final progress = stats['legendProgress'] as double;
    final isLegend = stats['isLegend'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isLegend
            ? const LinearGradient(colors: [Colors.amber, Colors.orange])
            : LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.2),
                  Colors.orange.withOpacity(0.2),
                ],
              ),
        border: Border.all(
          color: isLegend ? Colors.amber : Colors.amber.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLegend ? Icons.star : Icons.star_border,
                color: isLegend ? Colors.amber : Colors.amber.withOpacity(0.5),
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                isLegend ? 'LEGEND STATUS ACHIEVED' : 'Path to Legend',
                style: TextStyle(
                  color: isLegend
                      ? Colors.amber
                      : Colors.amber.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              isLegend ? Colors.amber : Colors.orange,
            ),
            minHeight: 12,
          ),
          const SizedBox(height: 8),
          Text(
            '$talesCompleted / $talesTotal Tales Completed',
            style: TextStyle(
              color: isLegend ? Colors.amber : Colors.grey,
              fontSize: 12,
            ),
          ),
          if (isLegend)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '★ Can equip 2 legendaries of same type! ★',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMultipliers(Map<String, dynamic> loopInfo) {
    final enemyHpMult = loopInfo['enemyHpMultiplier'] as double;
    final enemyDmgMult = loopInfo['enemyDamageMultiplier'] as double;
    final goldMult = loopInfo['goldMultiplier'] as double;
    final xpMult = loopInfo['xpMultiplier'] as double;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SPIRAL MULTIPLIERS',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMultiplierItem(
                  'Enemy HP',
                  '${((enemyHpMult - 1.0) * 100).toStringAsFixed(0)}%',
                  Colors.red,
                  Icons.favorite,
                ),
              ),
              Expanded(
                child: _buildMultiplierItem(
                  'Enemy DMG',
                  '${((enemyDmgMult - 1.0) * 100).toStringAsFixed(0)}%',
                  Colors.orange,
                  Icons.flash_on,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMultiplierItem(
                  'Gold',
                  '${((goldMult - 1.0) * 100).toStringAsFixed(0)}%',
                  Colors.amber,
                  Icons.monetization_on,
                ),
              ),
              Expanded(
                child: _buildMultiplierItem(
                  'XP',
                  '${((xpMult - 1.0) * 100).toStringAsFixed(0)}%',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplierItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoAdvanceToggle(BuildContext context, InfiniteSpiral spiral) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Auto-Advance',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                spiral.autoAdvanceEnabled
                    ? 'Automatically continue to next loop'
                    : 'Manual loop progression',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Switch(
            value: spiral.autoAdvanceEnabled,
            onChanged: (value) {
              context.read<GameProvider>().spiralService?.toggleAutoAdvance();
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTalesSection(Map<String, dynamic> talesInfo) {
    final completed = talesInfo['completed'] as List<dynamic>;
    final inProgress = talesInfo['inProgress'] as List<dynamic>;
    final locked = talesInfo['locked'] as List<dynamic>;
    final totalBonus = talesInfo['totalBonus'] as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TALES OF LEGEND',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Bonus: ${((totalBonus - 1.0) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Completed tales
        if (completed.isNotEmpty) ...[
          const Text(
            'COMPLETED',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: completed
                .map((tale) => _buildTaleBadge(tale, true))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // In progress tales
        if (inProgress.isNotEmpty) ...[
          const Text(
            'IN PROGRESS',
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...inProgress.map((tale) => _buildTaleProgress(tale)),
          const SizedBox(height: 16),
        ],

        // Locked tales (show first 3)
        if (locked.isNotEmpty) ...[
          const Text(
            'LOCKED',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: locked
                .take(3)
                .map((tale) => _buildTaleBadge(tale, false))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTaleBadge(dynamic tale, bool isCompleted) {
    final icon = tale['icon'] as String;
    final title = tale['title'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaleProgress(dynamic tale) {
    final icon = tale['icon'] as String;
    final title = tale['title'] as String;
    final progress = tale['progress'] as int;
    final target = tale['target'] as int;
    final percent = tale['percent'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$progress / $target',
                style: TextStyle(
                  color: Colors.orange.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildLoopHistory(SpiralService spiralService) {
    final history = spiralService.getLoopHistory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LOOP HISTORY',
          style: TextStyle(
            color: Colors.cyan,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ...history.map((loop) => _buildLoopHistoryItem(loop)),
      ],
    );
  }

  Widget _buildLoopHistoryItem(Map<String, dynamic> loop) {
    final loopNumber = loop['loopNumber'] as int;
    final highestFloor = loop['highestFloor'] as int;
    final duration = loop['duration'] as String;
    final enemyMult = loop['enemyMult'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.1),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Loop $loopNumber',
              style: const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Floor $highestFloor reached',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Duration: $duration',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            '${((enemyMult - 1.0) * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.cyan.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(Map<String, dynamic> stats) {
    final totalLoops = stats['totalLoops'] as int;
    final currentLoop = stats['currentLoop'] as int;
    final totalTime = stats['totalTime'] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SPIRAL STATISTICS',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatRow('Total Loops Completed', '$totalLoops'),
          _buildStatRow('Current Loop', '$currentLoop'),
          _buildStatRow('Total Time in Spiral', totalTime),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.withOpacity(0.8))),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
