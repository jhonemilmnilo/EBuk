import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/continue_reading_book.dart';

class ContinueReadingCard extends StatelessWidget {
  final ContinueReadingBook book;
  final VoidCallback onResume;

  const ContinueReadingCard({
    super.key,
    required this.book,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentInt = (book.progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.continueReading,
          style: AppTypography.sectionHeader.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface
                : AppColors.neutralLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColors.darkNeutral
                  : AppColors.neutral.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cover image / placeholder
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkNeutralLight
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkNeutral
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book.coverUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 140,
                        errorWidget: (context, url, error) => _buildFallback(isDark),
                        placeholder: (context, url) => _buildFallback(isDark),
                      )
                    : _buildFallback(isDark),
              ),
              const SizedBox(width: 12),
              // Book details & progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTypography.title.copyWith(
                        fontSize: 15,
                        color: isDark ? AppColors.darkText : AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: book.progress.clamp(0.0, 1.0),
                              minHeight: 5,
                              backgroundColor: isDark
                                  ? AppColors.darkNeutral
                                  : AppColors.neutralLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percentInt%',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Resume Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.primaryLight : AppColors.primary,
                  foregroundColor:
                      isDark ? AppColors.darkBackground : AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onResume,
                child: const Text('Resume'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(bool isDark) {
    return Text(
      book.title.isNotEmpty ? book.title[0] : 'B',
      style: AppTypography.title.copyWith(
        color: isDark ? AppColors.darkText : AppColors.primary,
      ),
    );
  }
}
