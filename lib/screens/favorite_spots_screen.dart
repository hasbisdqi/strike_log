import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';
import '../models/strike_model.dart';

class FavoriteSpotsScreen extends StatelessWidget {
  final List<StrikeModel> strikes;

  const FavoriteSpotsScreen({super.key, required this.strikes});

  @override
  Widget build(BuildContext context) {
    // Grouping by spot
    final Map<String, List<StrikeModel>> spotGroups = {};
    for (final s in strikes) {
      final name = s.spotName.trim();
      spotGroups.putIfAbsent(name, () => []).add(s);
    }

    // Sort by most frequent strikes
    final sortedSpots = spotGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Spot Mancing Favorit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: sortedSpots.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Belum Ada Spot Tersimpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Spot akan otomatis terdata saat kamu mencatat strike!', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: sortedSpots.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final spotName = sortedSpots[index].key;
                final list = sortedSpots[index].value;
                final strikeCount = list.length;
                final hasGps = list.any((s) => s.latitude != null && s.longitude != null);
                final gpsSample = list.firstWhere((s) => s.latitude != null && s.longitude != null, orElse: () => list.first);

                return GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: AppRadius.lg,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.location_on, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spotName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$strikeCount Kali Strike Berhasil 🎣',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            if (hasGps && gpsSample.latitude != null)
                              Text(
                                'GPS: ${gpsSample.latitude!.toStringAsFixed(4)}, ${gpsSample.longitude!.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                      ),
                      if (index == 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.amberAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Text('Top Spot ⭐', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
