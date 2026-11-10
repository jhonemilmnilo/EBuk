import 'package:flutter/material.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CategoryGridSection extends StatelessWidget {
  final ValueChanged<String> onCategorySelected;

  const CategoryGridSection({
    super.key,
    required this.onCategorySelected,
  });

  static const List<String> categories = [
    'Fiction',
    'History',
    'Philosophy',
    'Poetry',
    'Science',
    'Biography',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.popularTopics,
          style: AppTypography.sectionHeader.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: categories.map((title) {
                return SizedBox(
                  width: itemWidth > 0 ? itemWidth : 120,
                  child: GestureDetector(
                    onTap: () => onCategorySelected(title),
                    child: Container(
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkNeutralLight.withValues(alpha: 0.5)
                            : AppColors.neutralLight.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkNeutral.withValues(alpha: 0.8)
                              : AppColors.neutral.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        title,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkText : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
