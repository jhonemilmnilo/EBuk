import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/book.dart';

class BookSearchCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookSearchCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.neutralLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkNeutral.withValues(alpha: 0.8)
              : AppColors.neutral.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Container(
                  width: 58,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDark
                        ? AppColors.darkNeutralLight
                        : AppColors.neutralLight.withValues(alpha: 0.6),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkNeutral
                          : AppColors.neutral.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 180,
                          placeholder: (context, url) => _buildPlaceholder(isDark),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(isDark),
                        )
                      : _buildPlaceholder(isDark),
                ),
                const SizedBox(width: 14),

                // Book Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        book.title,
                        style: AppTypography.title.copyWith(
                          fontSize: 15,
                          height: 1.25,
                          color: isDark ? AppColors.darkText : AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authorsDisplay,
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Badges
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (book.epubUrl != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primaryLight
                                        .withValues(alpha: 0.25)
                                    : AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Free EPUB',
                                style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (book.subjects.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkNeutralLight
                                    : AppColors.neutral.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                book.subjects.first,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkNeutralLight : AppColors.neutralLight.withValues(alpha: 0.5),
      alignment: Alignment.center,
      child: Text(
        book.title.isNotEmpty ? book.title[0].toUpperCase() : 'B',
        style: AppTypography.title.copyWith(
          color: isDark ? AppColors.darkText : AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
