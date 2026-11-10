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
    final percentInt = (book.progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.continueReading,
          style: AppTypography.sectionHeader,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neutralLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.neutral.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Minimalist placeholder / cover box
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  book.title.isNotEmpty ? book.title[0] : 'B',
                  style: AppTypography.title.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Book details & progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTypography.title.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      style: AppTypography.caption,
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
                              value: book.progress,
                              minHeight: 5,
                              backgroundColor: AppColors.neutralLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percentInt%',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Resume Button
              GestureDetector(
                onTap: onResume,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Resume',
                    style: AppTypography.button.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

