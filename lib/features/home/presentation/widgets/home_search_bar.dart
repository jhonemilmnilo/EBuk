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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.neutralLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.neutral.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          AppStrings.searchPlaceholder,
          style: AppTypography.body.copyWith(
            color: AppColors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

