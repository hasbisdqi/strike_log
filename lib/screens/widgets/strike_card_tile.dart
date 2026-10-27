import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/glass_card.dart';
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

  Widget _defaultFishIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Icon(Icons.set_meal, color: Colors.white, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${item.caughtAt.day}/${item.caughtAt.month}/${item.caughtAt.year} ${item.caughtAt.hour.toString().padLeft(2, '0')}:${item.caughtAt.minute.toString().padLeft(2, '0')}';

    return InkWell(
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
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.lg,
        child: Row(
          children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: item.photoUrl != null && item.photoUrl!.isNotEmpty
                ? Image.network(
                    item.photoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _defaultFishIcon(),
                  )
                : _defaultFishIcon(),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fishName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.spotName}${item.lureName != null ? ' • ${item.lureName}' : ''}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Catatan: ${item.notes}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
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
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.link, size: 11, color: Colors.purple),
                          const SizedBox(width: 4),
                          Text(
                            item.blockNumber != null
                                ? 'Polygon Amoy #${item.blockNumber}'
                                : 'Polygon Verified',
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.open_in_new, size: 9, color: Colors.purple),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${item.weightKg} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}
