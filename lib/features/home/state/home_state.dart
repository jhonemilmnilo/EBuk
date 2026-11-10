import '../models/continue_reading_book.dart';

class HomeState {
  final List<String> recentSearches;
  final ContinueReadingBook? continueReadingBook;
  final bool isLoading;

  const HomeState({
    this.recentSearches = const [],
    this.continueReadingBook,
    this.isLoading = false,
  });

  HomeState copyWith({
    List<String>? recentSearches,
    ContinueReadingBook? continueReadingBook,
    bool? isLoading,
    bool clearContinueReading = false,
  }) {
    return HomeState(
      recentSearches: recentSearches ?? this.recentSearches,
      continueReadingBook: clearContinueReading
          ? null
          : (continueReadingBook ?? this.continueReadingBook),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

