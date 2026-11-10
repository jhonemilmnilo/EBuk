import 'package:flutter/material.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  const HomeSearchBar({
    super.key,
    this.onSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : AppColors.neutralLight.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkNeutral.withValues(alpha: 0.8)
                : AppColors.neutral.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.searchPlaceholder,
                style: AppTypography.body.copyWith(
                  color: isDark
                      ? AppColors.darkText.withValues(alpha: 0.85)
                      : AppColors.textMuted.withValues(alpha: 0.85),
                  fontSize: 14.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
