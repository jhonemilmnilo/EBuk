import 'package:flutter/material.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class RecentSearchesSection extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const RecentSearchesSection({
    super.key,
    required this.searches,
    required this.onSelect,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.recentSearches,
              style: AppTypography.sectionHeader,
            ),
            GestureDetector(
              onTap: onClearAll,
              child: Text(
                AppStrings.clearHistory,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...searches.map(
          (query) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(query),
                    child: Text(
                      query,
                      style: AppTypography.body,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onRemove(query),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '×',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

