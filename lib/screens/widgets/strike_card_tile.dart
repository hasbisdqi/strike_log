import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/glass_card.dart';
import '../../models/strike_model.dart';

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

    return GlassCard(
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 12, color: AppColors.tealAccent),
                      const SizedBox(width: 4),
                      Text(
                        item.blockNumber != null
                            ? 'Block #${item.blockNumber}'
                            : 'Proof-of-Catch Verified',
                        style: const TextStyle(
                          color: AppColors.tealAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
    );
  }
}
