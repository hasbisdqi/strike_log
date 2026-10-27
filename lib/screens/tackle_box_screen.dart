import 'package:flutter/material.dart';
import '../models/gear_item.dart';
import '../services/tackle_box_service.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';

class TackleBoxScreen extends StatefulWidget {
  final bool selectMode; // Jika true, user tap untuk memilih gear kembali ke AddStrikeScreen

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Alat Kustom', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Kategori Alat'),
                items: ['Reel', 'Rod', 'Lure', 'Line'].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) => setDialogState(() => category = val ?? 'Lure'),
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
        : _myGears.where((g) => g.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

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
          // Header Action Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _openCatalogPicker,
                    icon: const Icon(Icons.library_add_check, size: 18),
                    label: const Text(
                      'Pilih dari Katalog Alat Populer',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Category Filter
          Container(
            height: 48,
            color: Colors.white,
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.background,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),

          // List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada alat di kategori ini',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Klik tombol "Pilih dari Katalog" untuk menambahkan.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(_getCategoryIcon(item.category), color: color, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: color.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
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
                                    const Icon(Icons.check_circle_outline, color: AppColors.primary)
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                      tooltip: 'Hapus dari Tackle Box',
                                      onPressed: () async {
                                        await TackleBoxService.removeGear(item.id);
                                        _loadGears();
                                      },
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
  String _searchQuery = '';
  String _activeTab = 'Semua';

  @override
  Widget build(BuildContext context) {
    final ownedIds = widget.ownedGears.map((e) => e.id).toSet();

    final filtered = MasterGearCatalog.allItems.where((g) {
      final matchesTab = _activeTab == 'Semua' || g.category == _activeTab;
      final matchesQuery = _searchQuery.isEmpty ||
          g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesQuery;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari merk atau model (Shimano, Relix...)',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Semua', 'Reel', 'Rod', 'Lure', 'Line'].map((cat) {
                final isSelected = _activeTab == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _activeTab = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final item = filtered[idx];
                final isOwned = ownedIds.contains(item.id);

                return ListTile(
                  tileColor: isOwned ? AppColors.primaryContainer.withValues(alpha: 0.5) : AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${item.brand} • ${item.spec}', style: const TextStyle(fontSize: 11)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOwned ? AppColors.error : AppColors.primary,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      widget.onGearToggled(item, isOwned);
                      setState(() {});
                    },
                    child: Text(isOwned ? 'Lepas' : 'Pilih', style: const TextStyle(fontSize: 11)),
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
