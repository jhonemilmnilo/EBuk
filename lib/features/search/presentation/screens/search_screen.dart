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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input on Left, Back Button on Right
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
                              ? (isDark ? AppColors.primaryLight : AppColors.primary)
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
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              style: AppTypography.body.copyWith(
                                fontSize: 15,
                                color: isDark ? AppColors.darkText : AppColors.textDark,
                              ),
                              autofocus: widget.initialTopic == null &&
                                  (widget.initialQuery == null ||
                                      widget.initialQuery!.isEmpty),
                              decoration: InputDecoration(
                                hintText: AppStrings.searchPlaceholder,
                                hintStyle: AppTypography.body.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextMuted.withValues(alpha: 0.8)
                                      : AppColors.textMuted.withValues(alpha: 0.8),
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
                                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Back button placed on the right side
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
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
              const SizedBox(height: 12),

              // Active Topic Badge if applicable
              if (searchState.topic != null && searchState.topic!.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryLight.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primaryLight.withValues(alpha: 0.4)
                              : AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'Topic: ${searchState.topic![0].toUpperCase()}${searchState.topic!.substring(1)}',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Content Body
              Expanded(
                child: _buildBody(searchState, searchNotifier, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state, BookSearchNotifier notifier, bool isDark) {
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
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
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
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
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
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
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
                      color: isDark ? AppColors.darkBackground : AppColors.textOnPrimary,
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
