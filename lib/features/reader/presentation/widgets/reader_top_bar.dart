import 'package:flutter/material.dart';
import '../../models/reader_settings.dart';

class ReaderTopBar extends StatelessWidget {
  final String title;
  final ReaderThemeMode currentTheme;
  final VoidCallback onBack;
  final VoidCallback onOpenToc;
  final VoidCallback onOpenAppearance;

  const ReaderTopBar({
    super.key,
    required this.title,
    required this.currentTheme,
    required this.onBack,
    required this.onOpenToc,
    required this.onOpenAppearance,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = currentTheme.backgroundColor.withValues(alpha: 0.95);
    final iconColor = currentTheme.textColor;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 8,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: iconColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 20),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: iconColor,
                fontFamily: 'serif',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onOpenToc,
            icon: Icon(Icons.format_list_bulleted, color: iconColor, size: 22),
            tooltip: 'Table of Contents',
          ),
          IconButton(
            onPressed: onOpenAppearance,
            icon: Icon(Icons.tune_rounded, color: iconColor, size: 22),
            tooltip: 'Appearance',
          ),
        ],
      ),
    );
  }
}

