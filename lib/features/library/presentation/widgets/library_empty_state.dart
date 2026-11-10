import 'package:flutter/material.dart';
import 'package:ebuk/core/strings.dart';
import 'package:ebuk/core/theme/app_colors.dart';
import 'package:ebuk/core/theme/app_typography.dart';
import 'package:ebuk/features/library/state/library_state.dart';

class LibraryEmptyState extends StatelessWidget {
  final LibraryTab activeTab;
  final VoidCallback onSearchPrompt;

  const LibraryEmptyState({
    super.key,
    required this.activeTab,
    required this.onSearchPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDownloaded = activeTab == LibraryTab.downloaded;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDownloaded
                  ? Icons.menu_book_outlined
                  : Icons.favorite_border_outlined,
              size: 54,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isDownloaded
                  ? AppStrings.emptyLibraryTitle
                  : 'No Favorites Yet',
              style: AppTypography.title.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isDownloaded
                  ? AppStrings.emptyLibrarySubtitle
                  : 'Books you mark as favorite will be easily accessible right here.',
              style: AppTypography.caption.copyWith(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onSearchPrompt,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Browse Books',
                  style: AppTypography.button.copyWith(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
