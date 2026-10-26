import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/strike_model.dart';
import 'local_strike_storage.dart';

class StrikeService {
  final SupabaseClient _client = SupabaseConfig.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  // Dual DB: Ambil dari Supabase, simpan ke Hive cache lokal.
  // Jika offline / error jaringan, gabungkan dengan data lokal Hive yang belum tersinkron.
  Future<List<StrikeModel>> getStrikes() async {
    final localData = LocalStrikeStorage.getCachedStrikes();

    try {
      final response = await _client
          .from('strikes')
          .select()
          .order('caught_at', ascending: false);

      final onlineList = (response as List<dynamic>)
          .map((e) => StrikeModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Gabungkan strike lokal yang belum ada di online
      final onlineIds = onlineList.map((e) => e.id).toSet();
      final localOnly = localData.where((e) => !onlineIds.contains(e.id)).toList();

      final combined = [...localOnly, ...onlineList];
      combined.sort((a, b) => b.caughtAt.compareTo(a.caughtAt));

      // Update cache lokal
      await LocalStrikeStorage.cacheStrikes(combined);
      return combined;
    } catch (_) {
      // Fallback offline
      return localData;
    }
  }

  Future<String?> uploadPhoto(File file) async {
    final userId = currentUserId;
    if (userId == null) return null;

    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('strike_photos').upload(
          fileName,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );

    final publicUrl = _client.storage.from('strike_photos').getPublicUrl(fileName);
    return publicUrl;
  }

  Future<void> addStrike({
    required String fishName,
    required double weightKg,
    required String spotName,
    String? lureName,
    String? notes,
    String? photoUrl,
    double? latitude,
    double? longitude,
    String? blockchainHash,
    int? blockNumber,
    DateTime? caughtAt,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Pengguna belum masuk');

    final now = caughtAt ?? DateTime.now();

    try {
      final res = await _client.from('strikes').insert({
        'user_id': userId,
        'fish_name': fishName,
        'weight_kg': weightKg,
        'spot_name': spotName,
        'lure_name': lureName,
        'notes': notes,
        'photo_url': photoUrl,
        'latitude': latitude,
        'longitude': longitude,
        'blockchain_hash': blockchainHash,
        'block_number': blockNumber,
        'caught_at': now.toIso8601String(),
      }).select().single();

      final created = StrikeModel.fromJson(res);
      await LocalStrikeStorage.addSingle(created);
    } catch (err) {
      // Simpan lokal jika kondisi offline / kolom baru belum dimigrasi di remote DB
      final offlineStrike = StrikeModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        fishName: fishName,
        weightKg: weightKg,
        spotName: spotName,
        lureName: lureName,
        notes: notes,
        photoUrl: photoUrl,
        latitude: latitude,
        longitude: longitude,
        blockchainHash: blockchainHash,
        blockNumber: blockNumber,
        caughtAt: now,
      );
      await LocalStrikeStorage.addSingle(offlineStrike);
    }
  }

  Future<void> deleteStrike(String id) async {
    try {
      await _client.from('strikes').delete().eq('id', id);
    } catch (_) {}
    await LocalStrikeStorage.deleteSingle(id);
  }
}
