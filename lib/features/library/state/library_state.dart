import '../../../domain/models/book.dart';

enum LibraryTab { downloaded, favorites }

class LibraryState {
  final LibraryTab activeTab;
  final List<Book> downloadedBooks;
  final List<Book> favoriteBooks;
  final Map<int, double> readingProgressMap; // bookId -> progress 0.0 to 1.0
  final bool isLoading;

  const LibraryState({
    this.activeTab = LibraryTab.downloaded,
    this.downloadedBooks = const [],
    this.favoriteBooks = const [],
    this.readingProgressMap = const {},
    this.isLoading = false,
  });

  List<Book> get currentList =>
      activeTab == LibraryTab.downloaded ? downloadedBooks : favoriteBooks;

  LibraryState copyWith({
    LibraryTab? activeTab,
    List<Book>? downloadedBooks,
    List<Book>? favoriteBooks,
    Map<int, double>? readingProgressMap,
    bool? isLoading,
  }) {
    return LibraryState(
      activeTab: activeTab ?? this.activeTab,
      downloadedBooks: downloadedBooks ?? this.downloadedBooks,
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      readingProgressMap: readingProgressMap ?? this.readingProgressMap,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

