import 'package:flutter/material.dart';
import '../../models/reader_settings.dart';

class ReaderBottomBar extends StatelessWidget {
  final String chapterTitle;
  final double progress; // 0.0 to 1.0
  final ReaderThemeMode currentTheme;

  const ReaderBottomBar({
    super.key,
    required this.chapterTitle,
    required this.progress,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = currentTheme.backgroundColor.withValues(alpha: 0.95);
    final textColor = currentTheme.textColor;
    final percentInt = (progress * 100).clamp(0, 100).toInt();

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: textColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chapterTitle.isEmpty ? 'Reading' : chapterTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percentInt%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: textColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

