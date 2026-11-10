import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/book.dart';

class LibraryBookCard extends StatelessWidget {
  final Book book;
  final double progress; // 0.0 to 1.0
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const LibraryBookCard({
    super.key,
    required this.book,
    required this.progress,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentInt = (progress * 100).toInt();

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Book Cover
                Container(
                  width: 54,
                  height: 78,
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
                          memCacheWidth: 160,
                          placeholder: (context, url) =>
                              _buildPlaceholder(isDark),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(isDark),
                        )
                      : _buildPlaceholder(isDark),
                ),
                const SizedBox(width: 14),

                // Title, Author, Reading Progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 3),
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

                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress > 0 ? progress : 0.0,
                                minHeight: 5,
                                backgroundColor: isDark
                                    ? AppColors.darkNeutral
                                    : AppColors.neutralLight,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$percentInt%',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3-Dots Options Button
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.more_vert),
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
      color: isDark
          ? AppColors.darkNeutralLight
          : AppColors.neutralLight.withValues(alpha: 0.5),
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

