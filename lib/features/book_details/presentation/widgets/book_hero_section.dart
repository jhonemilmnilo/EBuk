import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/book.dart';

class BookHeroSection extends StatelessWidget {
  final Book book;

  const BookHeroSection({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large Book Cover
        Container(
          width: 105,
          height: 155,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isDark ? AppColors.darkNeutralLight : AppColors.neutralLight,
            border: Border.all(
              color: isDark
                  ? AppColors.darkNeutral
                  : AppColors.neutral.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: book.coverUrl != null && book.coverUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: book.coverUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: 300,
                  placeholder: (context, url) => _buildCoverPlaceholder(isDark),
                  errorWidget: (context, url, error) =>
                      _buildCoverPlaceholder(isDark),
                )
              : _buildCoverPlaceholder(isDark),
        ),
        const SizedBox(width: 16),

        // Title, Author, Language Meta
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                book.title,
                style: AppTypography.display.copyWith(
                  fontSize: 18,
                  height: 1.25,
                  color: isDark ? AppColors.darkText : AppColors.textDark,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                book.authorsDisplay,
                style: AppTypography.body.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Language badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkNeutral.withValues(alpha: 0.5)
                      : AppColors.neutralLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  book.languages.isNotEmpty
                      ? book.languages.first.toUpperCase()
                      : 'ENGLISH',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 11,
                    color: isDark ? AppColors.darkText : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkNeutralLight : AppColors.neutralLight,
      alignment: Alignment.center,
      child: Text(
        book.title.isNotEmpty ? book.title[0].toUpperCase() : 'B',
        style: AppTypography.display.copyWith(
          color: isDark ? AppColors.darkText : AppColors.primary,
          fontSize: 32,
        ),
      ),
    );
  }
}

