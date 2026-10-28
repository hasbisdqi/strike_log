import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../services/game_leaderboard_service.dart';

class GameLeaderboardSheet extends StatefulWidget {
  const GameLeaderboardSheet({super.key});

  @override
  State<GameLeaderboardSheet> createState() => _GameLeaderboardSheetState();
}

class _GameLeaderboardSheetState extends State<GameLeaderboardSheet> {
  late Future<List<LeaderboardEntry>> _futureLeaderboard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureLeaderboard = GameLeaderboardService.fetchTopLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 26),
                    SizedBox(width: 8),
                    Text(
                      'Peringkat Angler Online',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _loadData();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Muat ulang',
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0)),
          Expanded(
            child: FutureBuilder<List<LeaderboardEntry>>(
              future: _futureLeaderboard,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final entries = snapshot.data ?? [];

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.leaderboard_outlined, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada skor tercatat',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Jadilah angler pertama yang mendaratkan strike!',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    final rank = index + 1;

                    Color rankBadgeColor = const Color(0xFFF1F5F9);
                    Color rankTextColor = const Color(0xFF475569);
                    if (rank == 1) {
                      rankBadgeColor = const Color(0xFFFEF3C7);
                      rankTextColor = const Color(0xFFD97706);
                    } else if (rank == 2) {
                      rankBadgeColor = const Color(0xFFE2E8F0);
                      rankTextColor = const Color(0xFF475569);
                    } else if (rank == 3) {
                      rankBadgeColor = const Color(0xFFFFEDD5);
                      rankTextColor = const Color(0xFFC2410C);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: item.isCurrentUser ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.isCurrentUser ? AppColors.primary : const Color(0xFFE2E8F0),
                          width: item.isCurrentUser ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: rankBadgeColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: rankTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.anglerName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: item.isCurrentUser ? AppColors.primary : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (item.isCurrentUser) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'KAMU',
                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.biggestFishName != null
                                      ? 'PB: ${item.biggestFishName} (${item.biggestFishWeight.toStringAsFixed(1)} kg)'
                                      : 'Tangkapan pertama',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.score}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const Text(
                                'Poin',
                                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
