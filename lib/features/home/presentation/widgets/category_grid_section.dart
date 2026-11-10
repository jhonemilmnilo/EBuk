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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.popularTopics,
          style: AppTypography.sectionHeader,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            // Calculate item width safely from actual parent constraints
            final itemWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: categories.map((category) {
                return SizedBox(
                  width: itemWidth > 0 ? itemWidth : 120,
                  child: GestureDetector(
                    onTap: () => onCategorySelected(category),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.neutralLight.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.neutral.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
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
