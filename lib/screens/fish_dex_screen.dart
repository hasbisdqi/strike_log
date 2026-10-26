import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';
import '../models/strike_model.dart';
import '../services/strike_service.dart';

class FishDexScreen extends StatefulWidget {
  final List<StrikeModel> strikes;

  const FishDexScreen({super.key, required this.strikes});

  @override
  State<FishDexScreen> createState() => _FishDexScreenState();
}

class _FishDexScreenState extends State<FishDexScreen> {
  late List<StrikeModel> _currentStrikes;
  final StrikeService _strikeService = StrikeService();
  bool _isLoading = false;

  // Master Pokedex spesies ikan target pancing di Indonesia
  final List<Map<String, dynamic>> _masterEncyclopedia = [
    {
      'name': 'Ikan Kakap Merah (Red Snapper)',
      'alias': 'Lutjanus campechanus',
      'habitat': 'Karang Laut Dalam & Muara',
      'icon': Icons.set_meal,
    },
    {
      'name': 'Ikan Gabus / Channa Striata',
      'alias': 'Snakehead Hunter',
      'habitat': 'Rawa, Danau & Sungai Berlumut',
      'icon': Icons.water,
    },
    {
      'name': 'Ikan Nila Badot (Nile Tilapia)',
      'alias': 'Oreochromis niloticus',
      'habitat': 'Waduk, Kolam & Danau Air Tawar',
      'icon': Icons.set_meal_outlined,
    },
    {
      'name': 'Ikan Kerapu Cantang (Grouper)',
      'alias': 'Epinephelus fuscoguttatus',
      'habitat': 'Batu Karang & Dermaga Laut',
      'icon': Icons.waves,
    },
    {
      'name': 'Ikan Barramundi (Kakap Putih)',
      'alias': 'Lates calcarifer',
      'habitat': 'Muara Payau & Mangrove',
      'icon': Icons.phishing,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentStrikes = widget.strikes;
    _refreshFromDatabase();
  }

  Future<void> _refreshFromDatabase() async {
    setState(() => _isLoading = true);
    final data = await _strikeService.getStrikes();
    if (mounted) {
      setState(() {
        _currentStrikes = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grouping caught fish by normalized lowercase name
    final Map<String, List<StrikeModel>> caughtGroups = {};
    for (final s in _currentStrikes) {
      final name = s.fishName.trim().toLowerCase();
      caughtGroups.putIfAbsent(name, () => []).add(s);
    }

    final totalUnlocked = _masterEncyclopedia.where((e) {
      final target = (e['name'] as String).toLowerCase();
      return caughtGroups.keys.any((k) => k.contains(target) || target.contains(k));
    }).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Koleksi Ikan (FishDex)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFromDatabase,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Progress Header Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.collections_bookmark, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ensiklopedia Angler',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '$totalUnlocked dari ${_masterEncyclopedia.length} Spesies Terkoleksi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${((totalUnlocked / _masterEncyclopedia.length) * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Master Encyclopedia Cards
            ..._masterEncyclopedia.map((master) {
              final masterName = master['name'] as String;
              final targetLower = masterName.toLowerCase();

              // Check if user has caught this fish
              final matchKey = caughtGroups.keys.firstWhere(
                (k) => k.contains(targetLower) || targetLower.contains(k),
                orElse: () => '',
              );

              final isUnlocked = matchKey.isNotEmpty;
              final caughtList = isUnlocked ? caughtGroups[matchKey]! : <StrikeModel>[];
              final maxWeight = isUnlocked
                  ? caughtList.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b)
                  : 0.0;
              final samplePhoto = isUnlocked
                  ? caughtList.firstWhere(
                      (e) => e.photoUrl != null && e.photoUrl!.isNotEmpty,
                      orElse: () => caughtList.first,
                    ).photoUrl
                  : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: AppRadius.lg,
                  backgroundColor: isUnlocked
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.grey.shade100.withValues(alpha: 0.8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: isUnlocked && samplePhoto != null && samplePhoto.isNotEmpty
                            ? Image.network(
                                samplePhoto,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _defaultFishIcon(isUnlocked),
                              )
                            : _defaultFishIcon(isUnlocked),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUnlocked ? masterName : '??? (Belum Ditemukan)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              master['alias'] as String,
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isUnlocked
                                  ? 'Tertangkap: ${caughtList.length}x • Rekor: $maxWeight kg'
                                  : 'Habitat: ${master['habitat']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isUnlocked ? AppColors.tealAccent : AppColors.textSecondary,
                                fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? AppColors.primaryContainer
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          isUnlocked ? 'Unlocked 🎣' : 'Locked 🔒',
                          style: TextStyle(
                            color: isUnlocked ? AppColors.primaryDark : AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Additional custom catches not in master template
            ...caughtGroups.entries.where((entry) {
              final k = entry.key;
              return !_masterEncyclopedia.any((m) {
                final target = (m['name'] as String).toLowerCase();
                return k.contains(target) || target.contains(k);
              });
            }).map((entry) {
              final fishName = entry.value.first.fishName;
              final maxWeight = entry.value.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: AppRadius.lg,
                  child: Row(
                    children: [
                      _defaultFishIcon(true),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fishName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Spesies Unik • Tertangkap: ${entry.value.length}x • Rekor: $maxWeight kg',
                              style: const TextStyle(fontSize: 11, color: AppColors.tealAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.amberAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Text('Spesial ⭐', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.bottomNavPadding),
          ],
        ),
      ),
    );
  }

  Widget _defaultFishIcon(bool isUnlocked) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isUnlocked ? null : Colors.grey.shade300,
        gradient: isUnlocked ? AppColors.primaryGradient : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        isUnlocked ? Icons.set_meal : Icons.lock_outline,
        color: isUnlocked ? Colors.white : Colors.grey.shade500,
        size: 26,
      ),
    );
  }
}
