import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

class LeaderboardEntry {
  final String id;
  final String anglerName;
  final int score;
  final String? biggestFishName;
  final double biggestFishWeight;
  final DateTime updatedAt;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.id,
    required this.anglerName,
    required this.score,
    this.biggestFishName,
    required this.biggestFishWeight,
    required this.updatedAt,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, String? currentUserId) {
    return LeaderboardEntry(
      id: map['id']?.toString() ?? '',
      anglerName: map['angler_name'] as String? ?? 'Angler',
      score: (map['score'] as num?)?.toInt() ?? 0,
      biggestFishName: map['biggest_fish_name'] as String?,
      biggestFishWeight: (map['biggest_fish_weight'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
      isCurrentUser: currentUserId != null && map['user_id'] == currentUserId,
    );
  }
}

class GameLeaderboardService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Fetch Top 20 Global Leaderboard
  static Future<List<LeaderboardEntry>> fetchTopLeaderboard() async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      final response = await _client
          .from('game_leaderboard')
          .select()
          .order('score', ascending: false)
          .limit(20);

      final List data = response as List;
      return data.map((item) => LeaderboardEntry.fromMap(item, currentUserId)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Submit or update current player's highscore
  static Future<void> submitScore({
    required int addedScore,
    required String fishName,
    required double fishWeight,
  }) async {
    try {
      final user = _client.auth.currentUser;
      final userId = user?.id;
      final email = user?.email ?? 'Angler';
      final displayName = email.split('@').first;
      final formattedName = displayName.isNotEmpty
          ? displayName[0].toUpperCase() + displayName.substring(1)
          : 'Angler';

      if (userId == null) {
        // Guest mode fallback
        await _client.from('game_leaderboard').insert({
          'angler_name': 'Tamu ($formattedName)',
          'score': addedScore,
          'biggest_fish_name': fishName,
          'biggest_fish_weight': fishWeight,
          'updated_at': DateTime.now().toIso8601String(),
        });
        return;
      }

      // Check existing entry
      final existing = await _client
          .from('game_leaderboard')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        // First entry
        await _client.from('game_leaderboard').insert({
          'user_id': userId,
          'angler_name': formattedName,
          'score': addedScore,
          'biggest_fish_name': fishName,
          'biggest_fish_weight': fishWeight,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        final currentScore = (existing['score'] as num?)?.toInt() ?? 0;
        final currentMaxWeight = (existing['biggest_fish_weight'] as num?)?.toDouble() ?? 0.0;
        final newTotalScore = currentScore + addedScore;

        final shouldUpdateFish = fishWeight > currentMaxWeight;

        await _client.from('game_leaderboard').update({
          'angler_name': formattedName,
          'score': newTotalScore,
          if (shouldUpdateFish) 'biggest_fish_name': fishName,
          if (shouldUpdateFish) 'biggest_fish_weight': fishWeight,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
      }
    } catch (_) {}
  }
}
