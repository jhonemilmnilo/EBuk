import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BookSubjectsChips extends StatelessWidget {
  final List<String> subjects;

  const BookSubjectsChips({
    super.key,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subjects',
          style: AppTypography.sectionHeader.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: subjects.take(6).map((subject) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkNeutralLight.withValues(alpha: 0.6)
                    : AppColors.neutralLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkNeutral
                      : AppColors.neutral.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                subject,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.textDark,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

