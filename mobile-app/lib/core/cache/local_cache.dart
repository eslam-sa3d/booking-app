import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight JSON cache for offline-friendly "last loaded" data (class
/// list, session list, bookings) — not a full offline-first sync layer,
/// just "show the last thing we successfully fetched" instantly while a
/// fresh network fetch is in flight, and something reasonable if it fails.
class LocalCache {
  LocalCache._();
  static const _boxName = 'app_cache_v1';
  static Box? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static Box get _instance {
    final box = _box;
    if (box == null) throw StateError('LocalCache.init() must be called before use.');
    return box;
  }

  static Future<void> putList(String key, List<Map<String, dynamic>> items) => _instance.put(key, items);

  static List<Map<String, dynamic>>? getList(String key) {
    final raw = _instance.get(key);
    if (raw == null) return null;
    return (raw as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
