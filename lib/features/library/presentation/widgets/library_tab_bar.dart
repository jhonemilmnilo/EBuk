import 'package:flutter/material.dart';
import 'package:ebuk/core/theme/app_colors.dart';
import 'package:ebuk/core/theme/app_typography.dart';
import 'package:ebuk/features/library/state/library_state.dart';

class LibraryTabBar extends StatelessWidget {
  final LibraryTab activeTab;
  final ValueChanged<LibraryTab> onTabChanged;

  const LibraryTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.neutralLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkNeutral.withValues(alpha: 0.8)
              : AppColors.neutral.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              tab: LibraryTab.downloaded,
              label: 'Downloaded',
              isSelected: activeTab == LibraryTab.downloaded,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              tab: LibraryTab.favorites,
              label: 'Favorites',
              isSelected: activeTab == LibraryTab.favorites,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required LibraryTab tab,
    required String label,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTabChanged(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppColors.darkBackground : AppColors.textOnPrimary)
                : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
