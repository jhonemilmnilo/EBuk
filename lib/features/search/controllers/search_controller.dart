import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ebuk/data/api/api_providers.dart';
import 'package:ebuk/data/api/gutendex_api_client.dart';
import 'package:ebuk/features/search/state/search_state.dart';

class BookSearchNotifier extends StateNotifier<SearchState> {
  final GutendexApiClient apiClient;
  Timer? _debounceTimer;

  BookSearchNotifier({required this.apiClient}) : super(const SearchState());

  /// Sets search query and debounces network request (400ms)
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty && state.topic == null) {
      state = state.copyWith(
        query: query,
        status: SearchStatus.initial,
        books: const [],
        clearNextUrl: true,
      );
      return;
    }

    state = state.copyWith(query: query);

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      search(query: query, topic: state.topic);
    });
  }

  /// Direct search execution
  Future<void> search({String? query, String? topic}) async {
    _debounceTimer?.cancel();

    final activeQuery = query ?? state.query;
    final activeTopic = topic ?? state.topic;

    if (activeQuery.trim().isEmpty && (activeTopic == null || activeTopic.isEmpty)) {
      state = state.copyWith(status: SearchStatus.initial, books: const []);
      return;
    }

    state = state.copyWith(
      status: SearchStatus.loading,
      query: activeQuery,
      topic: activeTopic,
      errorMessage: null,
    );

    try {
      final result = await apiClient.searchBooks(
        query: activeQuery,
        topic: activeTopic,
      );

      if (result.books.isEmpty) {
        state = state.copyWith(
          status: SearchStatus.empty,
          books: const [],
          clearNextUrl: true,
        );
      } else {
        state = state.copyWith(
          status: SearchStatus.success,
          books: result.books,
          nextUrl: result.nextUrl,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Pagination for infinite scroll
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await apiClient.searchBooks(customUrl: state.nextUrl);
      state = state.copyWith(
        isLoadingMore: false,
        books: [...state.books, ...result.books],
        nextUrl: result.nextUrl,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Reset search state completely when leaving the screen
  void reset() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchControllerProvider =
    StateNotifierProvider.autoDispose<BookSearchNotifier, SearchState>((ref) {
  final apiClient = ref.watch(gutendexApiClientProvider);
  return BookSearchNotifier(apiClient: apiClient);
});
