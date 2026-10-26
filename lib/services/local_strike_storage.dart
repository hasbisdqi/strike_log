import 'package:hive_flutter/hive_flutter.dart';
import '../models/strike_model.dart';

class LocalStrikeStorage {
  static const String boxName = 'local_strikes_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(boxName);
  }

  static Box<Map> get _box => Hive.box<Map>(boxName);

  static Future<void> cacheStrikes(List<StrikeModel> strikes) async {
    final Map<String, Map<String, dynamic>> data = {};
    for (final s in strikes) {
      data[s.id] = {
        'id': s.id,
        'user_id': s.userId,
        'fish_name': s.fishName,
        'weight_kg': s.weightKg,
        'spot_name': s.spotName,
        'lure_name': s.lureName,
        'notes': s.notes,
        'photo_url': s.photoUrl,
        'latitude': s.latitude,
        'longitude': s.longitude,
        'blockchain_hash': s.blockchainHash,
        'block_number': s.blockNumber,
        'caught_at': s.caughtAt.toIso8601String(),
      };
    }
    await _box.clear();
    await _box.putAll(data);
  }

  static List<StrikeModel> getCachedStrikes() {
    final List<StrikeModel> list = [];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw != null) {
        list.add(StrikeModel.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => b.caughtAt.compareTo(a.caughtAt));
    return list;
  }

  static Future<void> addSingle(StrikeModel strike) async {
    await _box.put(strike.id, {
      'id': strike.id,
      'user_id': strike.userId,
      'fish_name': strike.fishName,
      'weight_kg': strike.weightKg,
      'spot_name': strike.spotName,
      'lure_name': strike.lureName,
      'notes': strike.notes,
      'photo_url': strike.photoUrl,
      'latitude': strike.latitude,
      'longitude': strike.longitude,
      'blockchain_hash': strike.blockchainHash,
      'block_number': strike.blockNumber,
      'caught_at': strike.caughtAt.toIso8601String(),
    });
  }

  static Future<void> deleteSingle(String id) async {
    await _box.delete(id);
  }
}
