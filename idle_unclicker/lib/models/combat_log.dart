import 'package:hive/hive.dart';

part 'combat_log.g.dart';

@HiveType(typeId: 4)
class CombatLog extends HiveObject {
  @HiveField(0)
  List<String> entries;

  @HiveField(1)
  int maxEntries;

  // Performance: cache recent entries to avoid creating new list every access
  List<String>? _cachedRecentEntries;
  bool _cacheInvalid = true;

  CombatLog({
    this.entries = const [],
    this.maxEntries = 500, // Increased to 500 lines scrollback
  });

  void addEntry(String entry) {
    final list = List<String>.from(entries);
    list.add(entry);
    if (list.length > maxEntries) {
      list.removeAt(0);
    }
    entries = list;
    _cacheInvalid = true; // Invalidate cache on modification
  }

  void clear() {
    entries = [];
    _cacheInvalid = true;
  }

  // Performance: cached getter - only recalculates when entries change
  List<String> get recentEntries {
    if (_cacheInvalid || _cachedRecentEntries == null) {
      _cachedRecentEntries = entries.reversed
          .take(20)
          .toList()
          .reversed
          .toList();
      _cacheInvalid = false;
    }
    return _cachedRecentEntries!;
  }
}
