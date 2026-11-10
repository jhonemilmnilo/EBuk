import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ebuk/core/strings.dart';
import 'package:ebuk/core/theme/app_colors.dart';
import 'package:ebuk/core/theme/app_typography.dart';
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

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialQuery ?? '');

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Initial search if query or topic is supplied
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((widget.initialQuery != null && widget.initialQuery!.isNotEmpty) ||
          (widget.initialTopic != null && widget.initialTopic!.isNotEmpty)) {
        ref.read(searchControllerProvider.notifier).search(
              query: widget.initialQuery,
              topic: widget.initialTopic,
            );
        if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
          ref.read(homeControllerProvider.notifier).addRecentSearch(widget.initialQuery!);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final searchNotifier = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Text Button and Search Input
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        'Back',
                        style: AppTypography.title.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.neutralLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.neutral.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _textController,
                        style: AppTypography.body,
                        autofocus: widget.initialTopic == null &&
                            (widget.initialQuery == null || widget.initialQuery!.isEmpty),
                        decoration: InputDecoration(
                          hintText: AppStrings.searchPlaceholder,
                          hintStyle: AppTypography.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
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
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Topic Badge if any
              if (searchState.topic != null && searchState.topic!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Topic: ${searchState.topic![0].toUpperCase()}${searchState.topic!.substring(1)}',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],

              // Content Body based on SearchStatus
              Expanded(
                child: _buildBody(searchState, searchNotifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state, BookSearchNotifier notifier) {
    switch (state.status) {
      case SearchStatus.initial:
        return Center(
          child: Text(
            AppStrings.searchInitialPrompt,
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        );

      case SearchStatus.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Searching...',
                style: AppTypography.body,
              ),
            ],
          ),
        );

      case SearchStatus.empty:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.noResultsTitle,
                style: AppTypography.title,
              ),
              SizedBox(height: 6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppStrings.noResultsSubtitle,
                  style: AppTypography.caption,
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
              const Text(
                'Unable to connect.',
                style: AppTypography.title,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.errorMessage ?? AppStrings.networkError,
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => notifier.search(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.retry,
                    style: AppTypography.button,
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
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final book = state.books[index];
            return BookSearchCard(
              book: book,
              onTap: () {
                // Book details navigation will be attached next
              },
            );
          },
        );
    }
  }
}
