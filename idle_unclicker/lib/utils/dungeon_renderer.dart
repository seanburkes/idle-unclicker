import 'dungeon_generator.dart';

/// Renders dungeon and town maps as ASCII art
class DungeonRenderer {
  DungeonGenerator? _dungeon;
  TownGenerator? _town;
  final int _width;
  final int _height;
  final int _seed;
  bool _isInTown = false;

  /// Create renderer with explicit dimensions (for testing/compatibility)
  DungeonRenderer({int width = 60, int height = 20, int seed = 0})
    : _width = width,
      _height = height,
      _seed = seed,
      _dungeon = DungeonGenerator(width: width, height: height, seed: seed),
      _town = null;

  /// Create renderer for dungeon view
  DungeonRenderer.dungeon(DungeonGenerator dungeon)
    : _dungeon = dungeon,
      _town = null,
      _width = dungeon.width,
      _height = dungeon.height,
      _seed = dungeon.seed,
      _isInTown = false;

  /// Create renderer for town view
  DungeonRenderer.town(TownGenerator town)
    : _town = town,
      _dungeon = null,
      _width = 50,
      _height = 15,
      _seed = 0,
      _isInTown = true;

  /// Regenerate the current dungeon (call when descending)
  void regenerate() {
    if (_dungeon != null) {
      _dungeon = DungeonGenerator(
        width: _dungeon!.width,
        height: _dungeon!.height,
        seed: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// Render the current map as ASCII string
  String render({bool inTown = false}) {
    if (inTown && _town != null) {
      return _town!.render();
    }
    if (_dungeon != null) {
      return _dungeon!.render();
    }
    if (inTown) {
      return _generateDefaultTown();
    }
    return _generateDefaultDungeon();
  }

  /// Generate a simple fallback town if generator is null
  String _generateDefaultTown() {
    final buffer = StringBuffer();
    buffer.writeln('┌' + '─' * (_width - 2) + '┐');
    for (int y = 1; y < _height - 1; y++) {
      buffer.write('│');
      for (int x = 1; x < _width - 1; x++) {
        if (x == _width ~/ 2 && y == _height ~/ 2) {
          buffer.write('◊');
        } else if (x == 2 && y == _height ~/ 2) {
          buffer.write('@');
        } else if ((x + y) % 7 == 0) {
          buffer.write('♣');
        } else {
          buffer.write('·');
        }
      }
      buffer.writeln('│');
    }
    buffer.write('└' + '─' * (_width - 2) + '┘');
    return buffer.toString();
  }

  /// Generate a simple fallback dungeon if generator is null
  String _generateDefaultDungeon() {
    final buffer = StringBuffer();
    buffer.writeln('#' * _width);
    for (int y = 1; y < _height - 1; y++) {
      buffer.write('#');
      for (int x = 1; x < _width - 1; x++) {
        if (x == _width ~/ 2 && y == _height ~/ 2) {
          buffer.write('@');
        } else {
          buffer.write('·');
        }
      }
      buffer.writeln('#');
    }
    buffer.write('#' * _width);
    return buffer.toString();
  }
}
