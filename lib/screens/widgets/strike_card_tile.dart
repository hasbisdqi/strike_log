import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/strike_model.dart';
import '../strike_detail_screen.dart';

class StrikeCardTile extends StatelessWidget {
  final StrikeModel item;
  final VoidCallback? onDelete;

  const StrikeCardTile({
    super.key,
    required this.item,
    this.onDelete,
  });

  Widget _defaultFishPlaceholder() {
    return Container(
      width: 90,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCEEF5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDCEEF5)),
            ),
            child: const Icon(Icons.phishing, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 6),
          const Text(
            'Strike Log',
            style: TextStyle(
              color: Color(0xFF64788D),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Ekstrak data cuaca dari format tersimpan:
  /// "Cuaca: {desc}, {temp}°C, Angin {wind} km/h. ({spotCond})"
  Map<String, String>? _parseWeather(String? notes) {
    if (notes == null || notes.isEmpty) return null;
    if (!notes.toLowerCase().contains('cuaca:')) return null;

    try {
      final reg = RegExp(
        r'Cuaca:\s*([^,]+),\s*([^,°]+)°C,\s*Angin\s*([^\s\.\)]+)\s*km/h',
        caseSensitive: false,
      );
      final match = reg.firstMatch(notes);
      if (match != null) {
        return {
          'desc': match.group(1)?.trim() ?? '',
          'temp': '${match.group(2)?.trim()}°C',
          'wind': '${match.group(3)?.trim()} km/h',
        };
      }

      // Fallback format cuaca lebih sederhana
      final simpleMatch = RegExp(r'cuaca:\s*([^,\.\n]+)', caseSensitive: false).firstMatch(notes);
      if (simpleMatch != null && simpleMatch.group(1) != null) {
        return {
          'desc': simpleMatch.group(1)!.trim(),
          'temp': '',
          'wind': '',
        };
      }
    } catch (_) {}
    return null;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text(
              'Hapus Log Strike',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF172B43)),
            ),
          ],
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus catatan tangkapan "${item.fishName}"?',
          style: const TextStyle(color: Color(0xFF64788D), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64788D))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && onDelete != null) {
      onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tanggal dan waktu
    final dateStr =
        '${item.caughtAt.day.toString().padLeft(2, '0')}/${item.caughtAt.month.toString().padLeft(2, '0')}/${item.caughtAt.year} • ${item.caughtAt.hour.toString().padLeft(2, '0')}:${item.caughtAt.minute.toString().padLeft(2, '0')}';

    // Status identifikasi ikan
    final rawName = item.fishName.trim();
    final bool isUnidentified = rawName.isEmpty ||
        rawName.toLowerCase() == 'ikan misterius' ||
        rawName.toLowerCase() == 'unknown catch' ||
        rawName.toLowerCase() == 'unidentified';
    final displayName = isUnidentified ? 'Ikan belum teridentifikasi' : rawName;

    // Berat valid
    final bool hasValidWeight = item.weightKg > 0.0;
    final weightStr = hasValidWeight ? '${item.weightKg.toStringAsFixed(1)} kg' : 'Berat -';

    // Info cuaca
    final weatherData = _parseWeather(item.notes);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEEF5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009FE3).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StrikeDetailScreen(
                  item: item,
                  onDelete: onDelete,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Bagian Kiri: Thumbnail Foto Ikan (90 x 110 px, cover, rounded 16)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.photoUrl != null && item.photoUrl!.isNotEmpty
                      ? Image.network(
                          item.photoUrl!,
                          width: 90,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _defaultFishPlaceholder(),
                        )
                      : _defaultFishPlaceholder(),
                ),
                const SizedBox(width: 14),

                // 2. Bagian Kanan: Detail Informasi terhierarki
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hierarki 1: Nama Ikan & Badge Berat + Menu Opsi
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isUnidentified
                                    ? const Color(0xFF64788D)
                                    : const Color(0xFF172B43),
                                fontStyle: isUnidentified ? FontStyle.italic : FontStyle.normal,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge Berat
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7FC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Text(
                              weightStr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (onDelete != null)
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.more_vert,
                                size: 18,
                                color: Color(0xFF64788D),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (val) {
                                if (val == 'delete') {
                                  _confirmDelete(context);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus Log',
                                        style: TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Hierarki 3: Lokasi Memancing & Waktu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.spotName.isNotEmpty ? item.spotName : 'Spot belum diset',
                              style: const TextStyle(
                                color: Color(0xFF64788D),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: Color(0xFF64788D),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Hierarki 4: Kondisi Cuaca (Compact: Icon cuaca | desc | temp | angin)
                      if (weatherData != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 2,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.wb_sunny_outlined, size: 12, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    weatherData['desc'] ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF64788D),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  if (weatherData['temp']!.isNotEmpty) ...[
                                    const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
                                    Text(
                                      weatherData['temp']!,
                                      style: const TextStyle(
                                        color: Color(0xFF64788D),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (weatherData['wind']!.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.air_rounded, size: 12, color: Color(0xFF009FE3)),
                                    const SizedBox(width: 3),
                                    Text(
                                      weatherData['wind']!,
                                      style: const TextStyle(
                                        color: Color(0xFF64788D),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],

                      // Hierarki 5: Link Polygon Amoy jika tersedia
                      if (item.blockchainHash != null) ...[
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final hash = item.blockchainHash!;
                            final url = 'https://amoy.polygonscan.com/tx/$hash';
                            final uri = Uri.parse(url);
                            try {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (_) {
                              await launchUrl(uri, mode: LaunchMode.platformDefault);
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, size: 11, color: Color(0xFF7C3AED)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    item.blockNumber != null
                                        ? 'Polygon Amoy #${item.blockNumber}'
                                        : 'Polygon Amoy Verified',
                                    style: const TextStyle(
                                      color: Color(0xFF7C3AED),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.open_in_new, size: 9, color: Color(0xFF7C3AED)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
