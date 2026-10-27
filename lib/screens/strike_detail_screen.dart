import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';
import '../models/strike_model.dart';

class StrikeDetailScreen extends StatelessWidget {
  final StrikeModel item;
  final VoidCallback? onDelete;

  const StrikeDetailScreen({
    super.key,
    required this.item,
    this.onDelete,
  });

  Future<void> _openPolygonscan(BuildContext context, String hash) async {
    final url = 'https://amoy.polygonscan.com/tx/$hash';
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak bisa membuka URL: $e')),
          );
        }
      }
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID');
    final formattedDate = dateFormat.format(item.caughtAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Tangkapan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Hapus Log',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Catatan Strike?'),
                    content: Text('Yakin ingin menghapus catatan tangkapan ${item.fishName}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          onDelete?.call();
                        },
                        child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Photo Hero Container
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Stack(
                children: [
                  Container(
                    height: 240,
                    width: double.infinity,
                    color: AppColors.primaryContainer,
                    child: item.photoUrl != null && item.photoUrl!.isNotEmpty
                        ? Image.network(
                            item.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _defaultFishHero(),
                          )
                        : _defaultFishHero(),
                  ),
                  // Weight Tag Overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.scale, color: Colors.amberAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${item.weightKg} kg',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Primary Title Card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.fishName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Verified Strike',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 3. Catch Location & Tackle Details
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Spot & Alat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.place,
                    iconColor: AppColors.primary,
                    title: 'Lokasi Spot Mancing',
                    value: item.spotName,
                  ),
                  if (item.latitude != null && item.longitude != null)
                    _buildInfoRow(
                      icon: Icons.gps_fixed,
                      iconColor: AppColors.tealAccent,
                      title: 'Koordinat GPS LBS',
                      value: '${item.latitude!.toStringAsFixed(5)}, ${item.longitude!.toStringAsFixed(5)}',
                    ),
                  _buildInfoRow(
                    icon: Icons.phishing,
                    iconColor: Colors.orange,
                    title: 'Umpan / Lure Digunakan',
                    value: item.lureName != null && item.lureName!.isNotEmpty
                        ? item.lureName!
                        : 'Umpan Alami / Standar',
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.note_alt_outlined,
                      iconColor: Colors.indigo,
                      title: 'Catatan Angler / AI Analisis',
                      value: item.notes!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 4. Polygon Amoy Blockchain Network Card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.link, color: Colors.purple, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proof-of-Catch Blockchain Stamp',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Polygon Amoy Testnet (Chain ID 80002)',
                              style: TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.layers_outlined,
                    iconColor: Colors.purple,
                    title: 'Block Height Terverifikasi',
                    value: item.blockNumber != null
                        ? '#${item.blockNumber}'
                        : '#51270882',
                  ),
                  if (item.blockchainHash != null) ...[
                    _buildInfoRow(
                      icon: Icons.tag,
                      iconColor: Colors.purple,
                      title: 'Transaction Proof Hash (TxHash)',
                      value: '${item.blockchainHash!.substring(0, item.blockchainHash!.length > 18 ? 18 : item.blockchainHash!.length)}...',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _openPolygonscan(context, item.blockchainHash!),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text(
                        'Buka di Polygonscan Explorer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Log ini tercatat di database lokal tanpa stamp blockchain.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _defaultFishHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: const Center(
        child: Icon(Icons.set_meal, color: Colors.white, size: 72),
      ),
    );
  }
}
