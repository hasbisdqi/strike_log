import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/supabase_config.dart';
import '../core/theme/app_tokens.dart';

import '../models/strike_model.dart';
import '../services/strike_service.dart';
import 'login_screen.dart';
import 'add_strike_screen.dart';
import 'strike_detector_screen.dart';
import 'reel_the_fish_game_screen.dart';
import 'currency_time_converter_screen.dart';
import 'strikebot_screen.dart';
import 'feedback_course_screen.dart';
import 'privacy_security_screen.dart';
import 'about_app_screen.dart';
import 'strike_map_screen.dart';
import 'tackle_box_screen.dart';
import 'widgets/strike_card_tile.dart';

class MainNavigationScreen extends StatefulWidget {
  final String? userEmail;

  const MainNavigationScreen({super.key, this.userEmail});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final StrikeService _strikeService = StrikeService();
  List<StrikeModel> _strikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStrikes();
  }

  Future<void> _loadStrikes() async {
    setState(() => _isLoading = true);
    try {
      final data = await _strikeService.getStrikes();
      if (mounted) {
        setState(() {
          _strikes = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAddStrikePage() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddStrikeScreen()),
    );

    if (created == true) {
      _loadStrikes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeScreen(
        userEmail: widget.userEmail,
        strikes: _strikes,
        isLoading: _isLoading,
        onRefresh: _loadStrikes,
      ),
      _LogsScreen(
        strikes: _strikes,
        isLoading: _isLoading,
        onRefresh: _loadStrikes,
        onAddTap: _openAddStrikePage,
        onDelete: (id) async {
          await _strikeService.deleteStrike(id);
          _loadStrikes();
        },
      ),
      _StatisticsScreen(strikes: _strikes),
      _ProfileScreen(
        userEmail: widget.userEmail,
        strikes: _strikes,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF009FE3).withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Beranda',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavBarItem(
                  icon: Icons.phishing_outlined,
                  activeIcon: Icons.phishing,
                  label: 'Logs',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                // Blue FAB button in center
                GestureDetector(
                  onTap: _openAddStrikePage,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                  ),
                ),
                _NavBarItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Statistik',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  final String? userEmail;
  final List<StrikeModel> strikes;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _HomeScreen({
    this.userEmail,
    required this.strikes,
    required this.isLoading,
    required this.onRefresh,
  });

  String _getDisplayName() {
    if (userEmail == null || userEmail!.isEmpty) return 'Angler';
    final part = userEmail!.split('@').first.trim();
    if (part.isEmpty) return 'Angler';
    return part[0].toUpperCase() + part.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter valid positive weights
    final validWeights = strikes.map((e) => e.weightKg).where((w) => w > 0.0).toList();
    final totalWeight = validWeights.fold<double>(0.0, (sum, w) => sum + w);
    final maxWeight = validWeights.isEmpty
        ? 0.0
        : validWeights.reduce((a, b) => a > b ? a : b);

    // Total unique spots visited
    final visitedSpots = strikes
        .map((s) => s.spotName.trim())
        .where((s) => s.isNotEmpty && s.toLowerCase() != 'spot rahasia' && s.toLowerCase() != 'unknown spot')
        .toSet()
        .length;

    final displayName = _getDisplayName();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // A. Header (Compact, modern, fishing-themed, not too tall)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STRIKE LOG',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Halo, $displayName',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // B. Summary Statistics (Unified Hero Card)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A), // Deep angler navy
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.waves, color: Color(0xFF38BDF8), size: 16),
                              SizedBox(width: 6),
                              Text(
                                'RINGKASAN LOGBOOK',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${strikes.length} Strike',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Tangkapan',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${strikes.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'ekor',
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 38,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Berat',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      totalWeight > 0.0 ? totalWeight.toStringAsFixed(1) : '0.0',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'kg',
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'PB: ${maxWeight > 0.0 ? maxWeight.toStringAsFixed(1) : '0.0'} kg',
                                style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined, color: Color(0xFF38BDF8), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '$visitedSpots Spot',
                                style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // C. Fitur & Alat Mancing
                const Text(
                  'Fitur & Alat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    _FeatureToolTile(
                      icon: Icons.vibration,
                      label: 'Sensor Joran',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StrikeDetectorScreen()),
                        );
                      },
                    ),
                    _FeatureToolTile(
                      icon: Icons.map_outlined,
                      label: 'Peta Spot',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StrikeMapScreen(strikes: strikes)),
                        );
                      },
                    ),
                    _FeatureToolTile(
                      icon: Icons.smart_toy_outlined,
                      label: 'StrikeBot AI',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StrikeBotScreen()),
                        );
                      },
                    ),
                    _FeatureToolTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'Kotak Alat',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TackleBoxScreen()),
                        );
                      },
                    ),
                    _FeatureToolTile(
                      icon: Icons.sports_esports_outlined,
                      label: 'Mini Game',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReelTheFishGameScreen()),
                        );
                      },
                    ),
                    _FeatureToolTile(
                      icon: Icons.currency_exchange,
                      label: 'Kurs & Waktu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CurrencyTimeConverterScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // D. Strike Terbaru
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Strike Terbaru',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        fontSize: 16,
                      ),
                    ),
                    if (strikes.isNotEmpty)
                      Text(
                        '${strikes.length} Tangkapan',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (strikes.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF009FE3).withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7FC),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFBAE6FD)),
                          ),
                          child: const Icon(Icons.phishing, size: 30, color: AppColors.primary),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Belum ada strike tercatat',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tekan tombol + di bawah untuk mencatat hasil tangkapan pertamamu!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: strikes.take(5).length,
                    itemBuilder: (context, index) {
                      final item = strikes[index];
                      return StrikeCardTile(item: item);
                    },
                  ),

                const SizedBox(height: 110), // Padding to prevent bottom nav overlap
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureToolTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF0F172A), size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogsScreen extends StatefulWidget {
  final List<StrikeModel> strikes;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final VoidCallback? onAddTap;
  final Function(String) onDelete;

  const _LogsScreen({
    required this.strikes,
    required this.isLoading,
    required this.onRefresh,
    this.onAddTap,
    required this.onDelete,
  });

  @override
  State<_LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<_LogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isUnidentified(String name) {
    final lower = name.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'ikan misterius' ||
        lower == 'unknown catch' ||
        lower == 'unidentified';
  }

  @override
  Widget build(BuildContext context) {
    // Kategori Filter Statis & Relevan
    final staticFilters = [
      'Semua',
      'Ikan belum teridentifikasi',
      'Ikan teridentifikasi',
      'Relevan',
      'Tidak relevan',
    ];

    // Filter dinamis dari nama ikan yang ada di data
    final dynamicFish = widget.strikes
        .map((s) => s.fishName.trim())
        .where((name) => !_isUnidentified(name))
        .toSet()
        .toList();

    final allFilterChips = [...staticFilters, ...dynamicFish];

    // Search and filter logic
    final query = _searchController.text.toLowerCase().trim();
    final filteredStrikes = widget.strikes.where((s) {
      final matchesSearch = query.isEmpty ||
          s.fishName.toLowerCase().contains(query) ||
          s.spotName.toLowerCase().contains(query) ||
          (s.lureName?.toLowerCase().contains(query) ?? false) ||
          (s.notes?.toLowerCase().contains(query) ?? false);

      if (!matchesSearch) return false;

      // Filter category check
      if (_selectedFilter == 'Semua') {
        return true;
      } else if (_selectedFilter == 'Ikan belum teridentifikasi') {
        return _isUnidentified(s.fishName);
      } else if (_selectedFilter == 'Ikan teridentifikasi') {
        return !_isUnidentified(s.fishName);
      } else if (_selectedFilter == 'Relevan') {
        // Tangkapan yang memiliki data lengkap (berat > 0, spot valid, atau ada foto/blockchain)
        return s.weightKg > 0.0 &&
            s.spotName.trim().isNotEmpty &&
            s.spotName.toLowerCase() != 'spot rahasia';
      } else if (_selectedFilter == 'Tidak relevan') {
        // Tangkapan yang belum ada berat atau spot belum diset
        return s.weightKg <= 0.0 ||
            s.spotName.trim().isEmpty ||
            s.spotName.toLowerCase() == 'spot rahasia';
      } else {
        // Filter nama spesies spesifik
        return s.fishName.trim().toLowerCase() == _selectedFilter.toLowerCase();
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: widget.onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Compact (Judul, Subtitle, & Tombol Peta Spot)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 14, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Daftar Strike & Riwayat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172B43),
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Dokumentasi hasil memancingmu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64788D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action button: Peta Spot
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDCEEF5)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF009FE3).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        tooltip: 'Lihat di Peta',
                        icon: const Icon(Icons.map_outlined, color: AppColors.primary, size: 22),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StrikeMapScreen(strikes: widget.strikes),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDCEEF5), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF009FE3).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF172B43)),
                    decoration: InputDecoration(
                      hintText: 'Cari ikan, spot, atau umpan...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64788D)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Filter Chips (Horizontal Scrollable)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemCount: allFilterChips.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final name = allFilterChips[index];
                      final isSelected = _selectedFilter == name;
                      return ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF172B43),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFDCEEF5),
                            width: 1.2,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = name);
                        },
                      );
                    },
                  ),
                ),
              ),

              // 4. Daftar Strike / Empty State
              Expanded(
                child: widget.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : filteredStrikes.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(28, 50, 28, 120),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: const Color(0xFFDCEEF5)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF009FE3).withValues(alpha: 0.05),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF7FC),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFBAE6FD)),
                                        ),
                                        child: const Icon(
                                          Icons.phishing_rounded,
                                          size: 34,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        widget.strikes.isEmpty
                                            ? 'Belum ada strike tercatat'
                                            : 'Tidak ada hasil yang cocok',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF172B43),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        widget.strikes.isEmpty
                                            ? 'Mulai dokumentasikan pengalaman memancingmu.'
                                            : 'Coba ubah kata kunci pencarian atau ganti filter kategori.',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF64788D),
                                          fontSize: 13,
                                          height: 1.35,
                                        ),
                                      ),
                                      if (widget.strikes.isEmpty && widget.onAddTap != null) ...[
                                        const SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: widget.onAddTap,
                                          icon: const Icon(Icons.add_rounded, size: 20),
                                          label: const Text(
                                            'Tambah Log Pertama',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
                            itemCount: filteredStrikes.length,
                            itemBuilder: (context, index) {
                              final item = filteredStrikes[index];
                              return StrikeCardTile(
                                item: item,
                                onDelete: () => widget.onDelete(item.id),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsScreen extends StatelessWidget {
  final List<StrikeModel> strikes;
  const _StatisticsScreen({required this.strikes});

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;

    // Hitung spot frekuensi
    final spotCounts = <String, int>{};
    final lureCounts = <String, int>{};
    final fishCounts = <String, int>{};

    for (final s in strikes) {
      spotCounts[s.spotName] = (spotCounts[s.spotName] ?? 0) + 1;
      fishCounts[s.fishName] = (fishCounts[s.fishName] ?? 0) + 1;
      if (s.lureName != null && s.lureName!.isNotEmpty) {
        lureCounts[s.lureName!] = (lureCounts[s.lureName!] ?? 0) + 1;
      }
    }

    // Hitung strike 7 hari terakhir
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final dailyCounts = <int, int>{};
    for (int i = 0; i < 7; i++) {
      dailyCounts[i] = 0;
    }

    for (final s in strikes) {
      final sDate = DateTime(s.caughtAt.year, s.caughtAt.month, s.caughtAt.day);
      for (int i = 0; i < 7; i++) {
        if (sDate.isAtSameMomentAs(last7Days[i])) {
          dailyCounts[i] = (dailyCounts[i] ?? 0) + 1;
          break;
        }
      }
    }

    final maxDaily = dailyCounts.values.isEmpty
        ? 5.0
        : (dailyCounts.values.reduce((a, b) => a > b ? a : b).toDouble());
    final chartMaxY = (maxDaily < 4 ? 4 : maxDaily + 1).toDouble();

    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FC),
      appBar: AppBar(
        title: const Text('Statistik Mancing', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line / Bar Chart Card: Tren 7 Hari
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aktivitas Strike Mingguan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Frekuensi tangkapan 7 hari terakhir',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '7 Hari',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: chartMaxY,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => const Color(0xFF0F172A),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${rod.toY.toInt()} Strike',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    final idx = val.toInt();
                                    if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                                    final date = last7Days[idx];
                                    final dayLabel = dayNames[date.weekday - 1];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        dayLabel,
                                        style: TextStyle(
                                          color: idx == 6 ? primaryColor : Colors.grey.shade600,
                                          fontWeight: idx == 6 ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: (chartMaxY / 4).ceilToDouble().clamp(1.0, 10.0),
                                  getTitlesWidget: (val, meta) {
                                    if (val % 1 != 0) return const SizedBox.shrink();
                                    return Text(
                                      '${val.toInt()}',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: (chartMaxY / 4).ceilToDouble().clamp(1.0, 10.0),
                              getDrawingHorizontalLine: (val) => FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(7, (i) {
                              final count = (dailyCounts[i] ?? 0).toDouble();
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: count,
                                    gradient: LinearGradient(
                                      colors: i == 6
                                          ? [const Color(0xFF38BDF8), primaryColor]
                                          : [const Color(0xFF93C5FD), const Color(0xFF60A5FA)],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    width: 14,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Distribusi Jenis Ikan (Pie Chart)
            if (fishCounts.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Komposisi Ikan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 36,
                              sections: _buildPieSections(fishCounts),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: _buildPieLegends(fishCounts),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),

            // Highlight Cards (Spot Gacor & Lure)
            _StatInsightCard(
              title: 'Spot Paling Gacor',
              subtitle: _getTopKey(spotCounts),
              icon: Icons.place,
              color: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 10),
            _StatInsightCard(
              title: 'Umpan Terfavorit',
              subtitle: _getTopKey(lureCounts),
              icon: Icons.phishing,
              color: const Color(0xFF0D9488),
            ),
            const SizedBox(height: 120), // Extra bottom padding for floating navbar
          ],
        ),
      ),
    );
  }

  static String _getTopKey(Map<String, int> map) {
    if (map.isEmpty) return 'Belum ada data';
    String topKey = '';
    int topCount = 0;
    map.forEach((k, v) {
      if (v > topCount) {
        topKey = k;
        topCount = v;
      }
    });
    return '$topKey ($topCount Strike)';
  }

  static final List<Color> _palette = [
    const Color(0xFF0284C7),
    const Color(0xFF38BDF8),
    const Color(0xFF0D9488),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  List<PieChartSectionData> _buildPieSections(Map<String, int> map) {
    int idx = 0;
    return map.entries.take(5).map((e) {
      final color = _palette[idx % _palette.length];
      idx++;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.value}',
        color: color,
        radius: 36,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  List<Widget> _buildPieLegends(Map<String, int> map) {
    int idx = 0;
    return map.entries.take(5).map((e) {
      final color = _palette[idx % _palette.length];
      idx++;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            e.key,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
          ),
        ],
      );
    }).toList();
  }
}

class _StatInsightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatInsightCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  final String? userEmail;
  final List<StrikeModel> strikes;

  const _ProfileScreen({this.userEmail, required this.strikes});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await SupabaseConfig.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;
    final totalWeight = strikes.fold<double>(0.0, (sum, item) => sum + item.weightKg);
    final uniqueFish = strikes.map((e) => e.fishName.toLowerCase().trim()).toSet().length;

    // Angler Rank berdasarkan jumlah strike
    String rankTitle = 'Angler Pemula';
    IconData rankIcon = Icons.military_tech_outlined;
    Color rankColor = Colors.brown;
    if (strikes.length >= 20) {
      rankTitle = 'Master Angler 👑';
      rankColor = Colors.amber.shade700;
    } else if (strikes.length >= 10) {
      rankTitle = 'Angler Senior ⭐';
      rankColor = Colors.blue.shade700;
    } else if (strikes.length >= 3) {
      rankTitle = 'Angler Hobi 🎣';
      rankColor = Colors.teal;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FC),
      appBar: AppBar(
        title: const Text(
          'Profil Pemancing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Translucent Profile Header Card
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.70),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 52, color: primaryColor),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: rankColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.verified, size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        userEmail?.split('@').first.toUpperCase() ?? 'PEMANCING',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail ?? 'pemancing@strikelog.com',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: rankColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(rankIcon, size: 16, color: rankColor),
                            const SizedBox(width: 6),
                            Text(
                              rankTitle,
                              style: TextStyle(
                                color: rankColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Mini Stats Grid
            Row(
              children: [
                Expanded(
                  child: _ProfileStatItem(
                    label: 'Strike',
                    value: '${strikes.length}',
                    icon: Icons.phishing,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProfileStatItem(
                    label: 'Spesies Ikan',
                    value: '$uniqueFish',
                    icon: Icons.set_meal,
                    color: const Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProfileStatItem(
                    label: 'Total Berat',
                    value: '${totalWeight.toStringAsFixed(1)} kg',
                    icon: Icons.scale,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Translucent Clean Account Options
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.shield_outlined,
                        title: 'Privasi & Keamanan',
                        subtitle: 'Pengaturan akun, biometric login, dan password',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrivacySecurityScreen(userEmail: userEmail),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, indent: 56, color: Colors.grey.shade200),
                      _ProfileMenuItem(
                        icon: Icons.rate_review_outlined,
                        title: 'Saran & Kesan Kuliah PAM',
                        subtitle: 'Ulasan praktikum pemrograman mobile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FeedbackCourseScreen()),
                          );
                        },
                      ),
                      Divider(height: 1, indent: 56, color: Colors.grey.shade200),
                      _ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Tentang Aplikasi',
                        subtitle: 'Strike Log v1.0.0 • Pemancing Mania',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                elevation: 0,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Keluar dari Akun',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 120), // Extra bottom padding for floating navbar
          ],
        ),
      ),
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0284C7), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
