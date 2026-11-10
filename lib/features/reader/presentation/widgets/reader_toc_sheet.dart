import 'package:epub_view/epub_view.dart';
// ignore: implementation_imports
import 'package:epub_view/src/data/models/chapter.dart';
import 'package:flutter/material.dart';
import '../../../../core/strings.dart';
import '../../models/reader_settings.dart';

class ReaderTocSheet extends StatelessWidget {
  final EpubController epubController;
  final ReaderThemeMode activeTheme;
  final ValueChanged<EpubViewChapter> onChapterSelected;

  const ReaderTocSheet({
    super.key,
    required this.epubController,
    required this.activeTheme,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = activeTheme.backgroundColor;
    final textColor = activeTheme.textColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              AppStrings.tableOfContents,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: textColor.withValues(alpha: 0.15),
          ),
          Expanded(
            child: EpubViewTableOfContents(
              controller: epubController,
              itemBuilder: (context, index, chapter, itemCount) {
                final title = (chapter.title?.trim().isNotEmpty ?? false)
                    ? chapter.title!.trim()
                    : 'Chapter ${index + 1}';

                return ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () {
                    onChapterSelected(chapter);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
