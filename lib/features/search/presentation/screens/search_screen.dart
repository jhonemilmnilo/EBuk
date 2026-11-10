import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ebuk/core/strings.dart';
import 'package:ebuk/core/theme/app_colors.dart';
import 'package:ebuk/core/theme/app_typography.dart';
import 'package:ebuk/features/book_details/presentation/screens/book_details_screen.dart';
import 'package:ebuk/features/home/controllers/home_controller.dart';
import 'package:ebuk/features/search/controllers/search_controller.dart';
import 'package:ebuk/features/search/presentation/widgets/book_search_card.dart';
import 'package:ebuk/features/search/state/search_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? initialTopic;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialTopic,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _textController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static const List<String> _popularSuggestions = [
    'Pride and Prejudice',
    'Frankenstein',
    'The Great Gatsby',
    '1984',
    'Sherlock Holmes',
    'Jane Eyre',
    'Dracula',
    'Moby Dick',
    'Alice in Wonderland',
    'The Picture of Dorian Gray',
    'War and Peace',
    'Crime and Punishment',
    'The Metamorphosis',
    'A Tale of Two Cities',
    'Little Women',
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialQuery ?? '');
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((widget.initialQuery != null && widget.initialQuery!.isNotEmpty) ||
          (widget.initialTopic != null && widget.initialTopic!.isNotEmpty)) {
        ref.read(searchControllerProvider.notifier).search(
              query: widget.initialQuery,
              topic: widget.initialTopic,
            );
        if (widget.initialQuery != null &&
            widget.initialQuery!.trim().isNotEmpty) {
          ref
              .read(homeControllerProvider.notifier)
              .addRecentSearch(widget.initialQuery!);
        }
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchControllerProvider.notifier).loadNextPage();
    }
  }

  List<String> _getFilteredSuggestions(String query) {
    if (query.trim().isEmpty) return const [];
    final lower = query.trim().toLowerCase();
    return _popularSuggestions
        .where((s) => s.toLowerCase().contains(lower) && s.toLowerCase() != lower)
        .take(5)
        .toList();
  }

  void _handleBack() {
    ref.read(searchControllerProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final searchNotifier = ref.read(searchControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final suggestions = _getFilteredSuggestions(_textController.text);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(searchControllerProvider.notifier).reset();
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Bar + Right-side Back Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.neutralLight.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? (isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary)
                                : (isDark
                                    ? AppColors.darkNeutral.withValues(alpha: 0.8)
                                    : AppColors.neutral.withValues(alpha: 0.4)),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                focusNode: _focusNode,
                                style: AppTypography.body.copyWith(
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.textDark,
                                ),
                                autofocus: widget.initialTopic == null &&
                                    (widget.initialQuery == null ||
                                        widget.initialQuery!.isEmpty),
                                decoration: InputDecoration(
                                  hintText: AppStrings.searchPlaceholder,
                                  hintStyle: AppTypography.body.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                            .withValues(alpha: 0.8)
                                        : AppColors.textMuted
                                            .withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                  searchNotifier.onQueryChanged(val);
                                },
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    ref
                                        .read(homeControllerProvider.notifier)
                                        .addRecentSearch(val.trim());
                                    searchNotifier.search(query: val.trim());
                                  }
                                },
                              ),
                            ),
                            if (_textController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _textController.clear();
                                  setState(() {});
                                  searchNotifier.onQueryChanged('');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.textMuted,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Back button on the right that cleans up state
                    IconButton(
                      onPressed: _handleBack,
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? AppColors.darkText : AppColors.primary,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Active Topic Badge with an 'x' dismiss button
                if (searchState.topic != null &&
                    searchState.topic!.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 6,
                          top: 4,
                          bottom: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryLight.withValues(alpha: 0.22)
                              : AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.primaryLight.withValues(alpha: 0.45)
                                : AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Topic: ${searchState.topic![0].toUpperCase()}${searchState.topic!.substring(1)}',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // 'x' dismiss button to remove topic filter
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                searchNotifier.clearTopic();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isDark
                                          ? AppColors.darkText
                                          : AppColors.primary)
                                      .withValues(alpha: 0.18),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Live Suggestions Row while user is typing
                if (suggestions.isNotEmpty &&
                    searchState.status != SearchStatus.loading) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: suggestions.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 4),
                          child: GestureDetector(
                            onTap: () {
                              _textController.text = s;
                              _textController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: s.length),
                              );
                              setState(() {});
                              ref
                                  .read(homeControllerProvider.notifier)
                                  .addRecentSearch(s);
                              searchNotifier.search(query: s);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : AppColors.neutralLight
                                        .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkNeutral
                                      : AppColors.neutral
                                          .withValues(alpha: 0.4),
                                  width: 0.9,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.north_west,
                                    size: 13,
                                    color: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s,
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Content Body
                Expanded(
                  child: _buildBody(searchState, searchNotifier, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      SearchState state, BookSearchNotifier notifier, bool isDark) {
    switch (state.status) {
      case SearchStatus.initial:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  size: 48,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'Discover Free Classics',
                  style: AppTypography.title.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.searchInitialPrompt,
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    color:
                        isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case SearchStatus.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                strokeWidth: 2.8,
              ),
              const SizedBox(height: 16),
              Text(
                'Searching catalog...',
                style: AppTypography.body.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textDark,
                ),
              ),
            ],
          ),
        );

      case SearchStatus.empty:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 48,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.noResultsTitle,
                style: AppTypography.title.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppStrings.noResultsSubtitle,
                  style: AppTypography.caption.copyWith(
                    color:
                        isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );

      case SearchStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_outlined,
                size: 48,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to connect.',
                style: AppTypography.title.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  state.errorMessage ?? AppStrings.networkError,
                  style: AppTypography.caption.copyWith(
                    color:
                        isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => notifier.search(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.retry,
                    style: AppTypography.button.copyWith(
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case SearchStatus.success:
        return ListView.builder(
          controller: _scrollController,
          itemCount: state.books.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.books.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final book = state.books[index];
            return BookSearchCard(
              book: book,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookDetailsScreen(book: book),
                  ),
                );
              },
            );
          },
        );
    }
  }
}
