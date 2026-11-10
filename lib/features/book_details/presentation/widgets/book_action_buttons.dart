import 'package:flutter/material.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../state/book_details_state.dart';

class BookActionButtons extends StatelessWidget {
  final BookDetailsState state;
  final VoidCallback onDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onReadNow;
  final VoidCallback onToggleFavorite;

  const BookActionButtons({
    super.key,
    required this.state,
    required this.onDownload,
    required this.onCancelDownload,
    required this.onReadNow,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Primary Action Button (Download / Downloading / Read Now)
        _buildPrimaryButton(context, isDark),
        const SizedBox(height: 12),

        // Secondary Action Button (Add to Favorites)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark
                    ? AppColors.darkNeutral.withValues(alpha: 0.8)
                    : AppColors.neutral,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.neutralLight.withValues(alpha: 0.25),
            ),
            onPressed: onToggleFavorite,
            icon: Icon(
              state.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: state.isFavorite
                  ? (isDark ? Colors.redAccent : AppColors.primary)
                  : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              size: 20,
            ),
            label: Text(
              state.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              style: AppTypography.button.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Error message if any
        if (state.errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            state.errorMessage!,
            style: AppTypography.caption.copyWith(
              color: isDark ? Colors.redAccent : Colors.red.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDark) {
    switch (state.downloadState) {
      case DownloadState.notDownloaded:
      case DownloadState.error:
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppColors.primaryLight : AppColors.primary,
              foregroundColor:
                  isDark ? AppColors.darkBackground : AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            onPressed: onDownload,
            child: Text(
              AppStrings.download,
              style: AppTypography.button.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

      case DownloadState.downloading:
        final percent = (state.downloadProgress * 100).toInt();
        return Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.neutralLight,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: state.downloadProgress > 0
                        ? state.downloadProgress
                        : null,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? AppColors.darkNeutral
                        : AppColors.neutralLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onCancelDownload,
                icon: const Icon(Icons.close, size: 20),
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );

      case DownloadState.downloaded:
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppColors.primaryLight : AppColors.primary,
              foregroundColor:
                  isDark ? AppColors.darkBackground : AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            onPressed: onReadNow,
            icon: const Icon(Icons.menu_book, size: 20),
            label: Text(
              AppStrings.readNow,
              style: AppTypography.button.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
    }
  }
}

