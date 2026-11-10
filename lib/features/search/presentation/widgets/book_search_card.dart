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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.neutralLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.neutral.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 50,
                height: 72,
                child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book.coverUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 150,
                        placeholder: (context, url) => Container(
                          color: AppColors.neutralLight,
                          alignment: Alignment.center,
                          child: Text(
                            book.title.isNotEmpty ? book.title[0] : 'B',
                            style: AppTypography.title.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.neutralLight,
                          alignment: Alignment.center,
                          child: Text(
                            book.title.isNotEmpty ? book.title[0] : 'B',
                            style: AppTypography.title.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.neutralLight,
                        alignment: Alignment.center,
                        child: Text(
                          book.title.isNotEmpty ? book.title[0] : 'B',
                          style: AppTypography.title.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Book Title & Author Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    book.title,
                    style: AppTypography.title.copyWith(
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authorsDisplay,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.languages.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      book.languages.join(', ').toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

