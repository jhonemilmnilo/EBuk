import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:epub_view/epub_view.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/book.dart';
import '../../controllers/reader_settings_controller.dart';
import '../../models/reader_settings.dart';
import '../widgets/reader_appearance_sheet.dart';
import '../widgets/reader_bottom_bar.dart';
import '../widgets/reader_toc_sheet.dart';
import '../widgets/reader_top_bar.dart';

class FluidReaderScrollPhysics extends ScrollPhysics {
  const FluidReaderScrollPhysics({super.parent});

  @override
  FluidReaderScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FluidReaderScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 35.0;

  @override
  double get maxFlingVelocity => 12000.0;

  @override
  double get dragStartDistanceMotionThreshold => 2.0;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Gives a lighter, responsive feel where small thumb drags scroll more
    return offset * 1.4;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      // Amplified velocity + ultra-low friction (0.004 vs 0.015) makes a gentle flick glide far!
      return ClampingScrollSimulation(
        position: position.pixels,
        velocity: velocity * 2.4,
        friction: 0.004,
        tolerance: tolerance,
      );
    }
    return null;
  }
}

class ReaderScreen extends ConsumerStatefulWidget {
  final Book book;
  final String? localFilePath;

  const ReaderScreen({
    super.key,
    required this.book,
    this.localFilePath,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  EpubController? _epubController;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  String _currentChapterTitle = '';
  double _currentProgress = 0.0;
  String? _savedCfi;
  Offset? _tapDownPosition;

  @override
  void initState() {
    super.initState();
    _initReader();
  }

  Future<void> _initReader() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookIdStr = widget.book.id.toString();

      // Load saved position
      _savedCfi = prefs.getString('book_cfi_$bookIdStr');
      _currentProgress = prefs.getDouble('book_progress_$bookIdStr') ?? 0.0;

      // Determine local EPUB file path
      String filePath = widget.localFilePath ?? '';
      if (filePath.isEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        filePath = '${dir.path}/books/${widget.book.id}.epub';
      }

      final file = File(filePath);
      if (!await file.exists()) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Book file not found. Please download it again.';
        });
        return;
      }

      final document = EpubDocument.openFile(file);
      _epubController = EpubController(
        document: document,
        epubCfi: _savedCfi,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppStrings.corruptedBookError;
      });
    }
  }

  @override
  void dispose() {
    _saveProgress();
    _epubController?.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    if (_epubController == null) return;
    try {
      final cfi = _epubController!.generateEpubCfi();
      final prefs = await SharedPreferences.getInstance();
      final bookIdStr = widget.book.id.toString();

      if (cfi != null && cfi.isNotEmpty) {
        await prefs.setString('book_cfi_$bookIdStr', cfi);
      }
      await prefs.setDouble('book_progress_$bookIdStr', _currentProgress);

      // Save continue reading payload for Home Screen
      final continueReadingJson = jsonEncode({
        'id': widget.book.id,
        'title': widget.book.title,
        'author': widget.book.authors.isNotEmpty
            ? widget.book.authors.first
            : 'Unknown',
        'currentChapter': _currentChapterTitle.isNotEmpty
            ? _currentChapterTitle
            : 'Reading',
        'progress': _currentProgress,
        'coverUrl': widget.book.coverUrl,
      });
      await prefs.setString('last_read_book', continueReadingJson);
    } catch (_) {}
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _showAppearanceModal(
    BuildContext context,
    ReaderSettings settings,
    ReaderThemeMode activeTheme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReaderAppearanceSheet(
        settings: settings,
        activeTheme: activeTheme,
        onThemeChanged: (mode) {
          ref.read(readerSettingsControllerProvider.notifier).setTheme(mode);
        },
        onFontSizeChanged: (size) {
          ref.read(readerSettingsControllerProvider.notifier).setFontSize(size);
        },
        onToggleSerif: () {
          ref.read(readerSettingsControllerProvider.notifier).toggleSerif();
        },
      ),
    );
  }

  void _showTocModal(BuildContext context, ReaderThemeMode activeTheme) {
    if (_epubController == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReaderTocSheet(
        epubController: _epubController!,
        activeTheme: activeTheme,
        onChapterSelected: (chapter) {
          _epubController?.scrollTo(index: chapter.startIndex);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBrightness = Theme.of(context).brightness;
    final settings = ref.watch(readerSettingsControllerProvider);
    final activeTheme = settings.effectiveTheme(appBrightness);
    final bgColor = activeTheme.backgroundColor;
    final textColor = activeTheme.textColor;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    if (_errorMessage != null || _epubController == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: textColor),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? AppStrings.genericError,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeTheme == ReaderThemeMode.dark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                    foregroundColor: activeTheme == ReaderThemeMode.dark
                        ? AppColors.darkBackground
                        : AppColors.textOnPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final fontFamily = settings.isSerif ? 'serif' : 'sans-serif';

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // EPUB Viewer Engine with Non-blocking raw Pointer Listener & Fluid Scroll Physics
          Listener(
            onPointerDown: (e) => _tapDownPosition = e.position,
            onPointerUp: (e) {
              if (_tapDownPosition != null) {
                final distance = (e.position - _tapDownPosition!).distance;
                // Only toggle controls if finger barely moved (pure tap, not a scroll gesture)
                if (distance < 12) {
                  _toggleControls();
                }
              }
            },
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const FluidReaderScrollPhysics(),
              ),
              child: EpubView(
                controller: _epubController!,
                onDocumentLoaded: (doc) {
                  // Initial loaded callback
                },
                onChapterChanged: (value) {
                  setState(() {
                    _currentChapterTitle = value?.chapter?.Title?.trim() ?? '';
                    final toc = _epubController?.tableOfContents();
                    if (toc != null && toc.isNotEmpty) {
                      final currentIdx = value?.chapterNumber ?? 1;
                      _currentProgress =
                          (currentIdx / toc.length).clamp(0.0, 1.0);
                    }
                  });
                  _saveProgress();
                },
                builders: EpubViewBuilders<DefaultBuilderOptions>(
                  chapterDividerBuilder: (_) => const SizedBox.shrink(),
                  loaderBuilder: (context) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  ),
                  chapterBuilder: (
                    context,
                    builders,
                    document,
                    chapters,
                    paragraphs,
                    index,
                    chapterIndex,
                    paragraphIndex,
                    onExternalLinkPressed,
                  ) {
                    if (paragraphs.isEmpty || index >= paragraphs.length) {
                      return const SizedBox.shrink();
                    }

                    final element = paragraphs[index].element;
                    final text = element.text
                        .replaceAll('\u00A0', '')
                        .replaceAll('\n', '')
                        .trim();
                    final hasImg = element.getElementsByTagName('img').isNotEmpty ||
                        element.localName == 'img';

                    // Eliminate pure blank paragraphs or spacer lines
                    if (text.isEmpty && !hasImg) {
                      return const SizedBox.shrink();
                    }

                    // Sanitize raw HTML: Gutenberg title pages contain huge inline CSS
                    // like margin-top: 15em, height: 100%, padding-top: 200px.
                    String htmlData = element.outerHtml;
                    htmlData = htmlData.replaceAll(
                      RegExp(
                        r'(height|min-height|max-height)\s*:\s*[^;"]+;?',
                        caseSensitive: false,
                      ),
                      '',
                    );
                    htmlData = htmlData.replaceAll(
                      RegExp(
                        r'(margin|padding)(-top|-bottom)?\s*:\s*\d+(\.\d+)?(em|px|vh|%|rem|ex)[^;"]*;?',
                        caseSensitive: false,
                      ),
                      '',
                    );

                    return Html(
                      data: htmlData,
                      onLinkTap: (href, _, unused) {
                        if (href != null) onExternalLinkPressed(href);
                      },
                      style: {
                        '*': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        'html': Style(
                          padding: HtmlPaddings.symmetric(
                            horizontal: 18,
                            vertical: 0,
                          ),
                          margin: Margins.zero,
                          color: textColor,
                          fontSize: FontSize(settings.fontSize),
                          fontFamily: fontFamily,
                          lineHeight: const LineHeight(1.35),
                        ),
                        'body': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        'p': Style(
                          margin: Margins.only(top: 0, bottom: 4),
                          padding: HtmlPaddings.zero,
                          lineHeight: const LineHeight(1.35),
                        ),
                        'div': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        'h1': Style(
                          margin: Margins.only(top: 10, bottom: 6),
                          padding: HtmlPaddings.zero,
                          fontWeight: FontWeight.bold,
                        ),
                        'h2': Style(
                          margin: Margins.only(top: 8, bottom: 4),
                          padding: HtmlPaddings.zero,
                          fontWeight: FontWeight.bold,
                        ),
                        'h3': Style(
                          margin: Margins.only(top: 6, bottom: 4),
                          padding: HtmlPaddings.zero,
                          fontWeight: FontWeight.w600,
                        ),
                      },
                      extensions: [
                        TagExtension(
                          tagsToExtend: {"img"},
                          builder: (imageContext) {
                            try {
                              final src = imageContext.attributes['src']
                                  ?.replaceAll('../', '');
                              if (src != null &&
                                  document.Content?.Images?[src]?.Content !=
                                      null) {
                                final content = Uint8List.fromList(
                                  document.Content!.Images![src]!.Content!,
                                );
                                return Image.memory(content);
                              }
                            } catch (_) {}
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    );
                  },
                  options: DefaultBuilderOptions(
                    chapterPadding: EdgeInsets.zero,
                    paragraphPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),

          // Top Bar (Controls overlay)
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ReaderTopBar(
                title: widget.book.title,
                currentTheme: activeTheme,
                onBack: () {
                  _saveProgress();
                  Navigator.of(context).pop();
                },
                onOpenToc: () => _showTocModal(context, activeTheme),
                onOpenAppearance: () =>
                    _showAppearanceModal(context, settings, activeTheme),
              ),
            ),

          // Bottom Bar (Controls overlay)
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ReaderBottomBar(
                chapterTitle: _currentChapterTitle,
                progress: _currentProgress,
                currentTheme: activeTheme,
              ),
            ),
        ],
      ),
    );
  }
}
