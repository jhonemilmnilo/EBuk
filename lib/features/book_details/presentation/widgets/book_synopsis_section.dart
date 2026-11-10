import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BookSynopsisSection extends StatelessWidget {
  final String? description;
  final bool isExpanded;
  final VoidCallback onToggle;

  const BookSynopsisSection({
    super.key,
    required this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasContent = description != null && description!.trim().isNotEmpty;
    final displayText = hasContent
        ? description!
        : 'A curated classic from our public-domain library. Explore the themes and characters crafted by the author in this timeless edition.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Short Summary',
          style: AppTypography.sectionHeader.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          displayText,
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textDark,
            height: 1.5,
            fontSize: 13.5,
          ),
          maxLines: isExpanded ? null : 4,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (displayText.length > 150) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                isExpanded ? 'Read less' : 'Read more...',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
