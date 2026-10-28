import 'package:flutter/material.dart';
import '../models/gear_item.dart';
import '../services/tackle_box_service.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';

class TackleBoxScreen extends StatefulWidget {
  final bool
  selectMode; // Jika true, user tap untuk memilih gear kembali ke AddStrikeScreen

  const TackleBoxScreen({super.key, this.selectMode = false});

  @override
  State<TackleBoxScreen> createState() => _TackleBoxScreenState();
}

class _TackleBoxScreenState extends State<TackleBoxScreen> {
  List<GearItem> _myGears = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Reel', 'Rod', 'Lure', 'Line'];

  @override
  void initState() {
    super.initState();
    _loadGears();
  }

  Future<void> _loadGears() async {
    setState(() => _isLoading = true);
    final list = await TackleBoxService.getUserGears();
    if (mounted) {
      setState(() {
        _myGears = list;
        _isLoading = false;
      });
    }
  }

  String _getCategoryAssetImage(String cat) {
    switch (cat.toLowerCase()) {
      case 'reel':
        return 'assets/ui/reel.png';
      case 'rod':
        return 'assets/ui/fishing_rod.png';
      case 'lure':
        return 'assets/ui/hook.png';
      case 'line':
        return 'assets/ui/ripple.png';
      default:
        return 'assets/ui/app_icon.png';
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'reel':
        return Icons.rotate_right;
      case 'rod':
        return Icons.linear_scale;
      case 'lure':
        return Icons.phishing;
      case 'line':
        return Icons.gesture;
      default:
        return Icons.build_circle_outlined;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'reel':
        return const Color(0xFF0284C7);
      case 'rod':
        return const Color(0xFF0D9488);
      case 'lure':
        return const Color(0xFFF59E0B);
      case 'line':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildBentoOverview() {
    final rodCount = _myGears
        .where((g) => g.category.toLowerCase() == 'rod')
        .length;
    final reelCount = _myGears
        .where((g) => g.category.toLowerCase() == 'reel')
        .length;
    final lureCount = _myGears
        .where((g) => g.category.toLowerCase() == 'lure')
        .length;
    final lineCount = _myGears
        .where((g) => g.category.toLowerCase() == 'line')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tackle Bento Box',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '${_myGears.length} Total Piranti',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Bento Grid Layout
          Row(
            children: [
              // Kolom 1 (Joran - Hero Card Vertikal)
              Expanded(
                flex: 11,
                child: _buildBentoCard(
                  category: 'Rod',
                  title: 'Joran (Rod)',
                  count: rodCount,
                  subtitle: rodCount > 0
                      ? '$rodCount joran siap'
                      : 'Belum ada joran',
                  imagePath: 'assets/ui/fishing_rod.png',
                  gradient: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                  isDark: true,
                  height: 176,
                  imageHeight: 70,
                ),
              ),
              const SizedBox(width: 10),
              // Kolom 2 (Reel & Kail/Lure bertingkat)
              Expanded(
                flex: 12,
                child: Column(
                  children: [
                    _buildBentoCard(
                      category: 'Reel',
                      title: 'Gulungan (Reel)',
                      count: reelCount,
                      subtitle: '$reelCount unit terpasang',
                      imagePath: 'assets/ui/reel.png',
                      gradient: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                      isDark: true,
                      height: 83,
                      imageHeight: 46,
                    ),
                    const SizedBox(height: 10),
                    _buildBentoCard(
                      category: 'Lure',
                      title: 'Umpan & Kail (Lure)',
                      count: lureCount,
                      subtitle: '$lureCount varian umpan',
                      imagePath: 'assets/ui/hook.png',
                      gradient: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      accentBorderColor: const Color(0xFFFDE68A),
                      isDark: false,
                      height: 83,
                      imageHeight: 44,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Baris Bawah: Senar Pancing (Line) - Wide Card
          _buildBentoWideLineCard(lineCount),
        ],
      ),
    );
  }

  Widget _buildBentoCard({
    required String category,
    required String title,
    required int count,
    required String subtitle,
    required String imagePath,
    required List<Color> gradient,
    Color? accentBorderColor,
    required bool isDark,
    required double height,
    required double imageHeight,
  }) {
    final isSelected =
        _selectedCategory.toLowerCase() == category.toLowerCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = isSelected ? 'Semua' : category;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.primary)
                  : (accentBorderColor ?? Colors.transparent),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? gradient.first.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -6,
                bottom: -6,
                child: Opacity(
                  opacity: isDark ? 0.9 : 0.85,
                  child: Image.asset(
                    imagePath,
                    height: imageHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.22)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count ITEM',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 11,
                            color: isDark ? gradient.first : Colors.white,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.85)
                              : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoWideLineCard(int count) {
    final isSelected = _selectedCategory.toLowerCase() == 'line';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = isSelected ? 'Semua' : 'Line';
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFFDDD6FE),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Image.asset(
                  'assets/ui/ripple.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.gesture,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Senar Pancing (Line)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$count senar PE / Mono / Leader terdaftar',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count LINE',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCatalogPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CatalogPickerSheet(
        ownedGears: _myGears,
        onGearToggled: (gear, isOwned) async {
          if (isOwned) {
            await TackleBoxService.removeGear(gear.id);
          } else {
            await TackleBoxService.addGear(gear);
          }
          await _loadGears();
        },
      ),
    );
  }

  void _openAddCustomGearDialog() {
    final nameCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    String category = 'Lure';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Tambah Alat Kustom',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Kategori Alat'),
                items: ['Reel', 'Rod', 'Lure', 'Line'].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) =>
                    setDialogState(() => category = val ?? 'Lure'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama / Seri Alat',
                  hintText: 'Misal: Abu Garcia Black Max',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specCtrl,
                decoration: const InputDecoration(
                  labelText: 'Spesifikasi / Ukuran (Opsional)',
                  hintText: 'Misal: Ratio 6.4:1, Max Drag 8kg',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final newGear = GearItem(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  category: category,
                  brand: 'Custom',
                  spec: specCtrl.text.trim(),
                  isCustom: true,
                );
                await TackleBoxService.addGear(newGear);
                if (ctx.mounted) Navigator.pop(ctx);
                await _loadGears();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'Semua'
        ? _myGears
        : _myGears
              .where(
                (g) =>
                    g.category.toLowerCase() == _selectedCategory.toLowerCase(),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.selectMode ? 'Pilih Alat Mancing' : 'Kotak Alat (Tackle Box)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppColors.primary),
            tooltip: 'Tambah Custom Gear',
            onPressed: _openAddCustomGearDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Bento Box Overview Piranti
          _buildBentoOverview(),

          // Header Action Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _openCatalogPicker,
                    icon: const Icon(Icons.library_add_check, size: 18),
                    label: const Text(
                      'Pilih dari Katalog Alat Populer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Category Filter
          Container(
            height: 48,
            color: Colors.transparent,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada alat di kategori ini',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Klik tombol "Pilih dari Katalog" untuk menambahkan.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final color = _getCategoryColor(item.category);

                      return InkWell(
                        onTap: widget.selectMode
                            ? () => Navigator.pop(context, item)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Image.asset(
                                  _getCategoryAssetImage(item.category),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        _getCategoryIcon(item.category),
                                        color: color,
                                        size: 24,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            item.category.toUpperCase(),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.brand,
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (item.spec.isNotEmpty)
                                      Text(
                                        item.spec,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (widget.selectMode)
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.primary,
                                )
                              else
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () async {
                                      setState(() {
                                        _myGears.removeWhere(
                                          (g) => g.id == item.id,
                                        );
                                      });
                                      await TackleBoxService.removeGear(
                                        item.id,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${item.name} dihapus',
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(
                                          alpha: 0.08,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 20,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CatalogPickerSheet extends StatefulWidget {
  final List<GearItem> ownedGears;
  final Function(GearItem gear, bool isOwned) onGearToggled;

  const _CatalogPickerSheet({
    required this.ownedGears,
    required this.onGearToggled,
  });

  @override
  State<_CatalogPickerSheet> createState() => _CatalogPickerSheetState();
}

class _CatalogPickerSheetState extends State<_CatalogPickerSheet> {
  late Set<String> _ownedIds;
  String _searchQuery = '';
  String _activeTab = 'Semua';

  @override
  void initState() {
    super.initState();
    _ownedIds = widget.ownedGears.map((e) => e.id).toSet();
  }

  String _getCategoryAssetImage(String cat) {
    switch (cat.toLowerCase()) {
      case 'reel':
        return 'assets/ui/reel.png';
      case 'rod':
        return 'assets/ui/fishing_rod.png';
      case 'lure':
        return 'assets/ui/hook.png';
      case 'line':
        return 'assets/ui/ripple.png';
      default:
        return 'assets/ui/app_icon.png';
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'reel':
        return Icons.rotate_right;
      case 'rod':
        return Icons.linear_scale;
      case 'lure':
        return Icons.phishing;
      case 'line':
        return Icons.gesture;
      default:
        return Icons.build_circle_outlined;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'reel':
        return const Color(0xFF0284C7);
      case 'rod':
        return const Color(0xFF0D9488);
      case 'lure':
        return const Color(0xFFF59E0B);
      case 'line':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = MasterGearCatalog.allItems.where((g) {
      final matchesTab = _activeTab == 'Semua' || g.category == _activeTab;
      final matchesQuery =
          _searchQuery.isEmpty ||
          g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesQuery;
    }).toList();

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Katalog Alat Pancing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Selesai'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari merk atau model (Shimano, Relix...)',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: const [
                  'Semua',
                  'Reel',
                  'Rod',
                  'Lure',
                  'Line',
                ].length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = const ['Semua', 'Reel', 'Rod', 'Lure', 'Line'][i];
                  final isSelected = _activeTab == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _activeTab = cat);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final item = filtered[idx];
                  final isOwned = _ownedIds.contains(item.id);
                  final color = _getCategoryColor(item.category);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isOwned
                          ? AppColors.primaryContainer.withValues(alpha: 0.45)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isOwned
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Image.asset(
                            _getCategoryAssetImage(item.category),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getCategoryIcon(item.category),
                              color: color,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.brand} • ${item.spec}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () {
                              setState(() {
                                if (isOwned) {
                                  _ownedIds.remove(item.id);
                                } else {
                                  _ownedIds.add(item.id);
                                }
                              });
                              widget.onGearToggled(item, isOwned);
                            },
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isOwned
                                    ? AppColors.error
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                isOwned ? 'Lepas' : 'Pilih',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
