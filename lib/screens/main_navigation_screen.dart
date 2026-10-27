import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/supabase_config.dart';

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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavBarItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
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
                    GestureDetector(
                      onTap: _openAddStrikePage,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                    _NavBarItem(
                      icon: Icons.leaderboard_outlined,
                      activeIcon: Icons.leaderboard,
                      label: 'Statistik',
                      isSelected: _currentIndex == 2,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                    _NavBarItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profil',
                      isSelected: _currentIndex == 3,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                  ],
                ),
              ),
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
    final color = isSelected ? const Color(0xFF0284C7) : Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalWeight = strikes.fold<double>(0.0, (sum, item) => sum + item.weightKg);
    final maxWeight = strikes.isEmpty
        ? 0.0
        : strikes.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF), // Soft fresh sky-blue tint
      appBar: AppBar(
        title: const Text(
          'Strike Log',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner with Translucent Glassmorphism
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.88),
                          const Color(0xFF38BDF8).withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(Icons.phishing, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Salam Satu Joran! 🎣',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail ?? 'pemancing@strikelog.com',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
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
              const SizedBox(height: 18),

              // Translucent Stat Badges
              Row(
                children: [
                  Expanded(
                    child: _TranslucentSummaryCard(
                      title: 'Total Strike',
                      value: '${strikes.length} Ekor',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TranslucentSummaryCard(
                      title: 'Ikan Terbesar (PB)',
                      value: '${maxWeight.toStringAsFixed(1)} Kg',
                      icon: Icons.emoji_events_outlined,
                      color: const Color(0xFF0EA5E9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Translucent Total Weight Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.scale, color: Color(0xFF0284C7), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Akumulasi Tangkapan',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${totalWeight.toStringAsFixed(1)} Kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Angler Tool Hub (Fitur Utama Cepat)
              Text(
                'Fitur & Alat Mancing',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      _QuickActionTile(
                        icon: Icons.vibration,
                        label: 'Sensor Joran',
                        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StrikeDetectorScreen()),
                          );
                        },
                      ),
                      _QuickActionTile(
                        icon: Icons.map_outlined,
                        label: 'Peta Spot',
                        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StrikeMapScreen(strikes: strikes)),
                          );
                        },
                      ),
                      _QuickActionTile(
                        icon: Icons.smart_toy_outlined,
                        label: 'StrikeBot AI',
                        gradientColors: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StrikeBotScreen()),
                          );
                        },
                      ),
                      _QuickActionTile(
                        icon: Icons.inventory_2_outlined,
                        label: 'Kotak Alat',
                        gradientColors: const [Color(0xFFF97316), Color(0xFFC2410C)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TackleBoxScreen()),
                          );
                        },
                      ),
                      _QuickActionTile(
                        icon: Icons.sports_esports_outlined,
                        label: 'Mini Game',
                        gradientColors: const [Color(0xFFF472B6), Color(0xFFDB2777)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReelTheFishGameScreen()),
                          );
                        },
                      ),
                      _QuickActionTile(
                        icon: Icons.currency_exchange,
                        label: 'Kurs & Waktu',
                        gradientColors: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CurrencyTimeConverterScreen()),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Strike Terbaru',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.phishing, size: 48, color: Colors.blue.shade200),
                          const SizedBox(height: 10),
                          const Text(
                            'Belum ada strike tercatat',
                            style: TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Klik tombol + di bawah untuk mencatat strike pertamamu!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: strikes.take(5).length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = strikes[index];
                    return StrikeCardTile(item: item);
                  },
                ),
              const SizedBox(height: 120), // Extra bottom padding for floating navbar
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TranslucentSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TranslucentSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
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
  final Function(String) onDelete;

  const _LogsScreen({
    required this.strikes,
    required this.isLoading,
    required this.onRefresh,
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

  @override
  Widget build(BuildContext context) {
    // Unique fish names for filter chips
    final fishNames = ['Semua', ...widget.strikes.map((s) => s.fishName).toSet()];

    // Search and filter logic
    final query = _searchController.text.toLowerCase().trim();
    final filteredStrikes = widget.strikes.where((s) {
      final matchesSearch = query.isEmpty ||
          s.fishName.toLowerCase().contains(query) ||
          s.spotName.toLowerCase().contains(query) ||
          (s.lureName?.toLowerCase().contains(query) ?? false) ||
          (s.notes?.toLowerCase().contains(query) ?? false);

      final matchesFilter = _selectedFilter == 'Semua' || s.fishName == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        title: const Text('Daftar Strike & Riwayat', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Lihat di Peta',
            icon: const Icon(Icons.map_outlined, color: Color(0xFF0284C7)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StrikeMapScreen(strikes: widget.strikes),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: Column(
          children: [
            // Search Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari ikan, spot, atau umpan...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0284C7)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
              ),
            ),

            // Filter Chips Horizontal Scroll
            if (fishNames.length > 2)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: fishNames.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final name = fishNames[index];
                    final isSelected = _selectedFilter == name;
                    return ChoiceChip(
                      label: Text(name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : const Color(0xFF0F172A))),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0284C7),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: isSelected ? const Color(0xFF0284C7) : Colors.grey.shade300),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedFilter = name);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),

            // Content List
            Expanded(
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredStrikes.isEmpty
                      ? ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 80),
                              child: Column(
                                children: [
                                  Icon(Icons.phishing, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.strikes.isEmpty
                                        ? 'Belum Ada Catatan Strike'
                                        : 'Tidak Ada Hasil yang Cocok',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.strikes.isEmpty
                                        ? 'Gunakan tombol + untuk menambahkan'
                                        : 'Coba ubah kata kunci pencarian atau filter',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          itemCount: filteredStrikes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
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
    );
  }
}

class _StatisticsScreen extends StatelessWidget {
  final List<StrikeModel> strikes;
  const _StatisticsScreen({required this.strikes});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0284C7);

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
      backgroundColor: const Color(0xFFF0F9FF),
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
    const primaryColor = Color(0xFF0284C7);
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
      backgroundColor: const Color(0xFFF0F9FF),
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
