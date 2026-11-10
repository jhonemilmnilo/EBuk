import 'package:ebuk/domain/models/book.dart';

enum SearchStatus { initial, loading, success, empty, error }

class SearchState {
  final String query;
  final String? topic;
  final List<Book> books;
  final SearchStatus status;
  final String? errorMessage;
  final String? nextUrl;
  final bool isLoadingMore;

  const SearchState({
    this.query = '',
    this.topic,
    this.books = const [],
    this.status = SearchStatus.initial,
    this.errorMessage,
    this.nextUrl,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextUrl != null && nextUrl!.isNotEmpty;

  SearchState copyWith({
    String? query,
    String? topic,
    List<Book>? books,
    SearchStatus? status,
    String? errorMessage,
    String? nextUrl,
    bool? isLoadingMore,
    bool clearNextUrl = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      topic: topic ?? this.topic,
      books: books ?? this.books,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      nextUrl: clearNextUrl ? null : (nextUrl ?? this.nextUrl),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
