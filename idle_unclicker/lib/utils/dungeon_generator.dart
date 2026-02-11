import 'dart:math';

/// Roguelike Dungeon Generator using room-and-corridor algorithm
/// Based on classic roguelike generation (similar to NetHack/DCSS)
class DungeonGenerator {
  static const String wallH = '─';
  static const String wallV = '│';
  static const String cornerTl = '┌';
  static const String cornerTr = '┐';
  static const String cornerBl = '└';
  static const String cornerBr = '┘';
  static const String floor = '·';
  static const String door = '+';
  static const String stairsDown = '>';
  static const String stairsUp = '<';
  static const String player = '@';
  static const String gold = r'$';
  static const String potion = '!';
  static const String weapon = ')';
  static const String armor = '[';
  static const String tree = '♣';
  static const String water = '~';
  static const String statue = '♦';

  static const String monsterChars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

  final int width;
  final int height;
  final int seed;
  late Random _random;

  late List<List<String>> _grid;
  late List<Room> _rooms;
  late List<Point> _floorTiles;
  late List<Mob> _mobs;
  late List<Item> _items;
  late Point _stairsUp;
  late Point _stairsDown;

  DungeonGenerator({this.width = 60, this.height = 20, this.seed = 0}) {
    _random = Random(seed);
    _generate();
  }

  void _generate() {
    _initializeGrid();
    _generateRooms();
    _connectRooms();
    _addFeatures();
    _spawnEntities();
    _placeStairs();
  }

  void _initializeGrid() {
    // Fill with solid rock
    _grid = List.generate(height, (_) => List.generate(width, (_) => ' '));
    _rooms = [];
    _floorTiles = [];
    _mobs = [];
    _items = [];
  }

  void _generateRooms() {
    // Digging-style generation: random walk + occasional chambers.
    final targetFloorCount = ((width * height) * 0.38).round();
    int x = width ~/ 2;
    int y = height ~/ 2;
    int stepsWithoutProgress = 0;

    void carveAt(int cx, int cy) {
      if (cx <= 0 || cy <= 0 || cx >= width - 1 || cy >= height - 1) return;
      if (_grid[cy][cx] != floor) {
        _grid[cy][cx] = floor;
        _floorTiles.add(Point(cx, cy));
      }
    }

    carveAt(x, y);

    while (_floorTiles.length < targetFloorCount &&
        stepsWithoutProgress < width * height * 4) {
      final direction = _random.nextInt(4);
      switch (direction) {
        case 0:
          if (x > 2) x--;
          break;
        case 1:
          if (x < width - 3) x++;
          break;
        case 2:
          if (y > 2) y--;
          break;
        case 3:
          if (y < height - 3) y++;
          break;
      }

      final before = _floorTiles.length;
      carveAt(x, y);

      if (_random.nextDouble() < 0.12) {
        final roomW = 3 + _random.nextInt(5);
        final roomH = 3 + _random.nextInt(4);
        for (int ry = y - roomH ~/ 2; ry <= y + roomH ~/ 2; ry++) {
          for (int rx = x - roomW ~/ 2; rx <= x + roomW ~/ 2; rx++) {
            carveAt(rx, ry);
          }
        }
      }

      if (_floorTiles.length == before) {
        stepsWithoutProgress++;
      } else {
        stepsWithoutProgress = 0;
      }
    }

    // Build lightweight room metadata from cave pockets for compatibility.
    for (int i = 0; i < min(6, _floorTiles.length ~/ 40); i++) {
      final p = _floorTiles[_random.nextInt(_floorTiles.length)];
      _rooms.add(Room(max(1, p.x - 1), max(1, p.y - 1), 3, 3));
    }
  }

  void _connectRooms() {
    // Natural caves from digging are already connected by construction.
  }

  void _addFeatures() {
    // Build walls around carved floor to make cave boundaries visible.
    _applyCaveWalls();

    // Add decorative features based on seed.
    if (_random.nextBool()) {
      _addWaterFeature();
    }
    if (_random.nextBool()) {
      _addStatues();
    }
  }

  void _applyCaveWalls() {
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        if (_grid[y][x] == floor) continue;

        bool adjacentToFloor = false;
        for (int dy = -1; dy <= 1 && !adjacentToFloor; dy++) {
          for (int dx = -1; dx <= 1 && !adjacentToFloor; dx++) {
            if (dx == 0 && dy == 0) continue;
            if (_grid[y + dy][x + dx] == floor) {
              adjacentToFloor = true;
            }
          }
        }

        if (!adjacentToFloor) continue;

        final north = _grid[y - 1][x] == floor;
        final south = _grid[y + 1][x] == floor;
        final east = _grid[y][x + 1] == floor;
        final west = _grid[y][x - 1] == floor;

        if ((north || south) && !(east || west)) {
          _grid[y][x] = wallV;
        } else if ((east || west) && !(north || south)) {
          _grid[y][x] = wallH;
        } else if (south && east) {
          _grid[y][x] = cornerTl;
        } else if (south && west) {
          _grid[y][x] = cornerTr;
        } else if (north && east) {
          _grid[y][x] = cornerBl;
        } else if (north && west) {
          _grid[y][x] = cornerBr;
        } else {
          _grid[y][x] = wallH;
        }
      }
    }
  }

  void _addWaterFeature() {
    if (_floorTiles.isEmpty) return;
    final origin = _floorTiles[_random.nextInt(_floorTiles.length)];
    final poolSize = 2 + _random.nextInt(3);

    for (int dy = -poolSize; dy <= poolSize; dy++) {
      for (int dx = -poolSize; dx <= poolSize; dx++) {
        final x = origin.x + dx;
        final y = origin.y + dy;
        if (y <= 0 || y >= height - 1 || x <= 0 || x >= width - 1) continue;
        if (_grid[y][x] != floor) continue;
        final dist = sqrt((dx * dx) + (dy * dy));
        if (dist <= poolSize && _random.nextDouble() < 0.65) {
          _grid[y][x] = water;
        }
      }
    }
  }

  void _addStatues() {
    if (_floorTiles.isEmpty) return;
    final statueCount = 2 + _random.nextInt(4);
    for (int i = 0; i < statueCount; i++) {
      final p = _floorTiles[_random.nextInt(_floorTiles.length)];
      if (_grid[p.y][p.x] == floor && _random.nextDouble() < 0.6) {
        _grid[p.y][p.x] = statue;
      }
    }
  }

  void _spawnEntities() {
    if (_floorTiles.isEmpty) return;

    final monsterCount = 8 + _random.nextInt(10);
    for (int i = 0; i < monsterCount; i++) {
      int attempts = 0;
      while (attempts < 30) {
        final p = _floorTiles[_random.nextInt(_floorTiles.length)];
        if (_grid[p.y][p.x] == floor && !_isOccupied(p.x, p.y)) {
          final char = monsterChars[_random.nextInt(monsterChars.length)];
          _mobs.add(Mob(x: p.x, y: p.y, char: char, color: _getRandomColor()));
          break;
        }
        attempts++;
      }
    }

    final itemCount = 3 + _random.nextInt(5);
    for (int i = 0; i < itemCount; i++) {
      int attempts = 0;
      while (attempts < 30) {
        final p = _floorTiles[_random.nextInt(_floorTiles.length)];
        if (_grid[p.y][p.x] != floor || _isOccupied(p.x, p.y)) {
          attempts++;
          continue;
        }

        final itemType = [
          'gold',
          'potion',
          'weapon',
          'armor',
        ][_random.nextInt(4)];
        String char;
        switch (itemType) {
          case 'gold':
            char = gold;
            break;
          case 'potion':
            char = potion;
            break;
          case 'weapon':
            char = weapon;
            break;
          case 'armor':
            char = armor;
            break;
          default:
            char = gold;
        }
        _items.add(Item(x: p.x, y: p.y, char: char, type: itemType));
        break;
      }
    }
  }

  void _placeStairs() {
    if (_floorTiles.length < 2) {
      _stairsUp = Point(width ~/ 2, height ~/ 2);
      _stairsDown = Point((width ~/ 2) + 1, height ~/ 2);
      return;
    }

    final first = _floorTiles[_random.nextInt(_floorTiles.length)];
    Point farthest = first;
    int farDist = -1;

    for (final tile in _floorTiles) {
      final dx = tile.x - first.x;
      final dy = tile.y - first.y;
      final dist = dx * dx + dy * dy;
      if (dist > farDist) {
        farDist = dist;
        farthest = tile;
      }
    }

    _stairsUp = first;
    _stairsDown = farthest;
  }

  bool _isOccupied(int x, int y) {
    for (final mob in _mobs) {
      if (mob.x == x && mob.y == y) return true;
    }
    for (final item in _items) {
      if (item.x == x && item.y == y) return true;
    }
    return false;
  }

  String _getRandomColor() {
    final colors = [
      'red',
      'green',
      'yellow',
      'blue',
      'magenta',
      'cyan',
      'white',
    ];
    return colors[_random.nextInt(colors.length)];
  }

  /// Render the dungeon as ASCII string
  String render({Point? playerPos}) {
    final buffer = StringBuffer();

    // Create render grid copy
    final renderGrid = List.generate(
      height,
      (y) => List.generate(width, (x) => _grid[y][x]),
    );

    // Place mobs
    for (final mob in _mobs) {
      if (mob.y >= 0 && mob.y < height && mob.x >= 0 && mob.x < width) {
        renderGrid[mob.y][mob.x] = mob.char;
      }
    }

    // Place items
    for (final item in _items) {
      if (item.y >= 0 && item.y < height && item.x >= 0 && item.x < width) {
        renderGrid[item.y][item.x] = item.char;
      }
    }

    // Place stairs
    renderGrid[_stairsDown.y][_stairsDown.x] = stairsDown;
    renderGrid[_stairsUp.y][_stairsUp.x] = stairsUp;

    // Place player
    final px = playerPos?.x ?? _stairsUp.x;
    final py = playerPos?.y ?? _stairsUp.y;
    if (py >= 0 && py < height && px >= 0 && px < width) {
      renderGrid[py][px] = player;
    }

    // Build string
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        buffer.write(renderGrid[y][x]);
      }
      if (y < height - 1) buffer.writeln();
    }

    return buffer.toString();
  }

  List<Mob> get mobs => _mobs;
  List<Item> get items => _items;
  List<Room> get rooms => _rooms;
}

/// Town generator with varied layouts
class TownGenerator {
  static const String grass = '.';
  static const String road = '#';
  static const String tree = '^';
  static const String water = '~';
  static const String wall = '%';
  static const String house = 'H';
  static const String shop = 'S';
  static const String inn = 'I';
  static const String temple = 'T';
  static const String gate = '+';
  static const String bridge = '=';
  static const String plaza = ':';
  static const String player = '@';

  final int width;
  final int height;
  final int seed;
  late Random _random;
  String? _cachedTown;

  TownGenerator({this.width = 50, this.height = 15, this.seed = 0}) {
    _random = Random(seed);
  }

  String render() {
    _cachedTown ??= _generateOverworldTown();
    return _cachedTown!;
  }

  String _generateOverworldTown() {
    final grid = List.generate(
      height,
      (_) => List.generate(width, (_) => grass),
    );
    final centerX = width ~/ 2;
    final centerY = height ~/ 2;

    // Edge wall + four gates.
    for (int x = 0; x < width; x++) {
      grid[0][x] = wall;
      grid[height - 1][x] = wall;
    }
    for (int y = 0; y < height; y++) {
      grid[y][0] = wall;
      grid[y][width - 1] = wall;
    }
    final gates = [
      Point(centerX, 0),
      Point(centerX, height - 1),
      Point(0, centerY),
      Point(width - 1, centerY),
    ];
    for (final g in gates) {
      grid[g.y][g.x] = gate;
    }

    // Roads connecting gates through a central plaza.
    for (int x = 1; x < width - 1; x++) {
      grid[centerY][x] = road;
    }
    for (int y = 1; y < height - 1; y++) {
      grid[y][centerX] = road;
    }
    for (int y = centerY - 1; y <= centerY + 1; y++) {
      for (int x = centerX - 2; x <= centerX + 2; x++) {
        if (y > 0 && y < height - 1 && x > 0 && x < width - 1) {
          grid[y][x] = plaza;
        }
      }
    }

    // River line with at least one bridge.
    final riverColumn = 2 + _random.nextInt(max(3, width - 4));
    for (int y = 1; y < height - 1; y++) {
      grid[y][riverColumn] = water;
    }
    grid[centerY][riverColumn] = bridge;
    if (centerY + 1 < height - 1) {
      grid[centerY + 1][riverColumn] = bridge;
    }

    // Place key buildings near roads.
    final structures = <Map<String, dynamic>>[
      {'x': centerX - 9, 'y': centerY - 3, 'char': inn},
      {'x': centerX + 8, 'y': centerY - 3, 'char': shop},
      {'x': centerX - 9, 'y': centerY + 3, 'char': house},
      {'x': centerX + 8, 'y': centerY + 3, 'char': temple},
    ];
    for (final s in structures) {
      final sx = (s['x'] as int).clamp(1, width - 2);
      final sy = (s['y'] as int).clamp(1, height - 2);
      if (grid[sy][sx] != water) {
        grid[sy][sx] = s['char'] as String;
      }
    }

    // Scatter trees outside roads/plaza.
    final treeCount = (width * height * 0.08).round();
    for (int i = 0; i < treeCount; i++) {
      final x = 1 + _random.nextInt(width - 2);
      final y = 1 + _random.nextInt(height - 2);
      if (grid[y][x] == grass && _random.nextDouble() < 0.65) {
        grid[y][x] = tree;
      }
    }

    // Player starts in the town center.
    grid[centerY][centerX] = player;

    final buffer = StringBuffer();
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        buffer.write(grid[y][x]);
      }
      if (y < height - 1) buffer.writeln();
    }
    return buffer.toString();
  }
}

// Helper classes
class Room {
  final int x, y, width, height;

  Room(this.x, this.y, this.width, this.height);

  Point get center => Point(x + width ~/ 2, y + height ~/ 2);

  bool intersectsWithPadding(Room other, int padding) {
    return x - padding < other.x + other.width + padding &&
        x + width + padding > other.x - padding &&
        y - padding < other.y + other.height + padding &&
        y + height + padding > other.y - padding;
  }
}

class Point {
  final int x, y;
  Point(this.x, this.y);
}

class Mob {
  final int x, y;
  final String char;
  final String color;

  Mob({
    required this.x,
    required this.y,
    required this.char,
    required this.color,
  });
}

class Item {
  final int x, y;
  final String char;
  final String type;

  Item({
    required this.x,
    required this.y,
    required this.char,
    required this.type,
  });
}
