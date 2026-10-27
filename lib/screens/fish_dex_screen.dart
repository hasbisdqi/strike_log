import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';
import '../models/strike_model.dart';
import '../services/strike_service.dart';
import '../services/fishial_api_service.dart';

class FishDexScreen extends StatefulWidget {
  final List<StrikeModel> strikes;

  const FishDexScreen({super.key, required this.strikes});

  @override
  State<FishDexScreen> createState() => _FishDexScreenState();
}

class _FishDexScreenState extends State<FishDexScreen> {
  late List<StrikeModel> _currentStrikes;
  final StrikeService _strikeService = StrikeService();
  List<FishialSpecies> _speciesList = FishialApiService.defaultFishialSpecies;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentStrikes = widget.strikes;
    _loadFishialSpecies();
  }

  Future<void> _loadFishialSpecies() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _strikeService.getStrikes(),
      FishialApiService.fetchFishialSpeciesList(),
    ]);

    if (mounted) {
      setState(() {
        _currentStrikes = results[0] as List<StrikeModel>;
        _speciesList = results[1] as List<FishialSpecies>;
        _isLoading = false;
      });
    }
  }

  bool _isFishMatch(String speciesName, String sciName, Set<String> userCaughtNames) {
    final spec = speciesName.toLowerCase();
    final sci = sciName.toLowerCase();

    for (final caught in userCaughtNames) {
      if (caught.isEmpty) continue;
      if (spec.contains(caught) || caught.contains(spec)) return true;
      if (sci.isNotEmpty && (sci.contains(caught) || caught.contains(sci))) return true;

      // Token check (e.g. "kakap", "snapper", "gabus", "nila")
      final tokens = spec.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '').split(' ');
      for (final t in tokens) {
        if (t.length >= 4 && caught.contains(t)) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Collect all unique caught fish names from user logs
    final userCaughtNames = _currentStrikes
        .map((s) => s.fishName.trim().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toSet();

    final filteredSpecies = _speciesList.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.commonName.toLowerCase().contains(q) ||
          item.scientificName.toLowerCase().contains(q) ||
          item.habitat.toLowerCase().contains(q);
    }).toList();

    final totalUnlocked = _speciesList.where((item) {
      return _isFishMatch(item.commonName, item.scientificName, userCaughtNames);
    }).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FishDex (Fishial.AI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFishialSpecies,
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
                    child: const Icon(Icons.verified, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Powered by Fishial.AI Species',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalUnlocked dari ${_speciesList.length} Spesies Terbuka',
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
                      '${_speciesList.isEmpty ? 0 : ((totalUnlocked / _speciesList.length) * 100).toInt()}%',
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
            const SizedBox(height: AppSpacing.md),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari taksonomi (misal: Snapper, Grouper, Nila)...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
            const SizedBox(height: AppSpacing.md),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Fishial Species Cards
            ...filteredSpecies.map((species) {
              final isUnlocked = _isFishMatch(
                species.commonName,
                species.scientificName,
                userCaughtNames,
              );

              // Find user's best catch for this species if unlocked
              StrikeModel? matchedStrike;
              if (isUnlocked) {
                final specLower = species.commonName.toLowerCase();
                try {
                  matchedStrike = _currentStrikes.firstWhere((s) {
                    final name = s.fishName.toLowerCase();
                    return specLower.contains(name) || name.contains(specLower);
                  });
                } catch (_) {
                  matchedStrike = _currentStrikes.isNotEmpty ? _currentStrikes.first : null;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: AppRadius.lg,
                  backgroundColor: isUnlocked
                      ? Colors.white.withValues(alpha: 0.95)
                      : Colors.grey.shade100.withValues(alpha: 0.85),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: isUnlocked && matchedStrike?.photoUrl != null && matchedStrike!.photoUrl!.isNotEmpty
                            ? Image.network(
                                matchedStrike.photoUrl!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildFishAvatar(isUnlocked),
                              )
                            : _buildFishAvatar(isUnlocked),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    species.commonName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                if (isUnlocked)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'TERCATAT',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              species.scientificName,
                              style: TextStyle(
                                color: isUnlocked ? AppColors.primary : Colors.grey.shade500,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              species.habitat,
                              style: TextStyle(
                                color: isUnlocked ? AppColors.textSecondary : Colors.grey.shade400,
                                fontSize: 10,
                              ),
                            ),
                            if (isUnlocked && matchedStrike != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Rekor Pribadi: ${matchedStrike.weightKg} kg • ${matchedStrike.spotName}',
                                style: const TextStyle(
                                  color: AppColors.tealAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFishAvatar(bool isUnlocked) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        isUnlocked ? Icons.set_meal : Icons.lock,
        color: isUnlocked ? AppColors.primary : Colors.grey.shade600,
        size: 26,
      ),
    );
  }
}
