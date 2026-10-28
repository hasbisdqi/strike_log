import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gear_item.dart';
import '../core/supabase_config.dart';

class TackleBoxService {
  static const String _boxName = 'user_tackle_box';
  static Box? _box;

  static Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  /// Ambil semua gear milik user (offline Hive + Supabase sync)
  static Future<List<GearItem>> getUserGears() async {
    final box = await _getBox();
    final isInitialized = box.get('is_initialized', defaultValue: false) as bool;

    if (!isInitialized) {
      final defaultGears = [
        MasterGearCatalog.allItems[0], // Shimano Stradic
        MasterGearCatalog.allItems[6], // Relix Cangkek
        MasterGearCatalog.allItems[11], // Rapala X-Rap
        MasterGearCatalog.allItems[17], // PE Duraking
      ];
      await box.put('is_initialized', true);
      await saveUserGears(defaultGears);
      return defaultGears;
    }

    final rawList = box.get('items', defaultValue: <dynamic>[]) as List;
    List<GearItem> localGears = rawList.map((item) {
      if (item is Map) {
        return GearItem.fromJson(Map<String, dynamic>.from(item));
      } else if (item is String) {
        return GearItem.fromJson(jsonDecode(item) as Map<String, dynamic>);
      }
      return GearItem.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();

    return localGears;
  }

  /// Simpan list gear ke Hive
  static Future<void> saveUserGears(List<GearItem> items) async {
    final box = await _getBox();
    final rawList = items.map((e) => e.toJson()).toList();
    await box.put('items', rawList);

    // Sync online ke Supabase jika ada auth session
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        await SupabaseConfig.client.from('profiles').upsert({
          'id': user.id,
          'tackle_box': rawList,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
  }

  /// Tambah satu gear
  static Future<void> addGear(GearItem item) async {
    final current = await getUserGears();
    if (!current.any((g) => g.id == item.id || g.name.toLowerCase() == item.name.toLowerCase())) {
      current.add(item);
      await saveUserGears(current);
    }
  }

  /// Hapus gear
  static Future<void> removeGear(String id) async {
    final current = await getUserGears();
    current.removeWhere((g) => g.id == id);
    await saveUserGears(current);
  }
}
