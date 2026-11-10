import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/book.dart';
import '../state/library_state.dart';

class LibraryController extends StateNotifier<LibraryState> {
  LibraryController() : super(const LibraryState()) {
    loadLibrary();
  }

  void switchTab(LibraryTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  /// Loads downloaded files and saved favorites strictly from offline device storage.
  Future<void> loadLibrary() async {
    state = state.copyWith(isLoading: true);

    final prefs = await SharedPreferences.getInstance();

    // 1. Load favorites metadata
    final favListJson = prefs.getStringList('saved_favorite_books') ?? [];
    final favorites = <Book>[];
    for (final item in favListJson) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        favorites.add(Book.fromJson(map));
      } catch (_) {}
    }

    // 2. Load downloaded books metadata and verify local EPUB existence
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${dir.path}/books');
    final downloadedListJson = prefs.getStringList('saved_downloaded_books') ?? [];
    final downloaded = <Book>[];

    for (final item in downloadedListJson) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        final book = Book.fromJson(map);
        final file = File('${booksDir.path}/${book.id}.epub');
        if (await file.exists()) {
          downloaded.add(book);
        }
      } catch (_) {}
    }

    // 3. Load reading progress map
    final progressMap = <int, double>{};
    for (final book in downloaded) {
      final p = prefs.getDouble('progress_${book.id}') ?? 0.0;
      progressMap[book.id] = p;
    }

    state = state.copyWith(
      isLoading: false,
      downloadedBooks: downloaded,
      favoriteBooks: favorites,
      readingProgressMap: progressMap,
    );
  }

  /// Record a book as downloaded into local persistent library
  Future<void> recordDownloadedBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = prefs.getStringList('saved_downloaded_books') ?? [];

    final bookJson = jsonEncode({
      'id': book.id,
      'title': book.title,
      'authors': book.authors.map((a) => {'name': a}).toList(),
      'formats': {
        'image/jpeg': book.coverUrl,
        'application/epub+zip': book.epubUrl,
      },
      'subjects': book.subjects,
      'summaries': book.description != null ? [book.description] : [],
    });

    final updated = List<String>.from(currentList);
    // Avoid duplicates
    updated.removeWhere((item) {
      try {
        final map = jsonDecode(item);
        return map['id'] == book.id;
      } catch (_) {
        return false;
      }
    });
    updated.insert(0, bookJson);

    await prefs.setStringList('saved_downloaded_books', updated);
    await loadLibrary();
  }

  /// Remove downloaded EPUB file from device storage
  Future<void> removeBookFromDevice(int bookId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/books/$bookId.epub');
    if (await file.exists()) {
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    final currentList = prefs.getStringList('saved_downloaded_books') ?? [];
    currentList.removeWhere((item) {
      try {
        final map = jsonDecode(item);
        return map['id'] == bookId;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList('saved_downloaded_books', currentList);

    await loadLibrary();
  }

  /// Remove book from favorites
  Future<void> removeBookFromFavorites(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favorite_book_ids') ?? [];
    favIds.remove(bookId.toString());
    await prefs.setStringList('favorite_book_ids', favIds);

    final favListJson = prefs.getStringList('saved_favorite_books') ?? [];
    favListJson.removeWhere((item) {
      try {
        final map = jsonDecode(item);
        return map['id'] == bookId;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList('saved_favorite_books', favListJson);

    await loadLibrary();
  }
}

final libraryControllerProvider =
    StateNotifierProvider<LibraryController, LibraryState>((ref) {
  return LibraryController();
});

