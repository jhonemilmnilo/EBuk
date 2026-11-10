import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/api_providers.dart';
import '../../../domain/models/book.dart';
import '../../library/controllers/library_controller.dart';
import '../state/book_details_state.dart';

class BookDetailsController extends StateNotifier<BookDetailsState> {
  Book book;
  final Ref ref;
  CancelToken? _cancelToken;

  BookDetailsController({
    required this.book,
    required this.ref,
  }) : super(const BookDetailsState()) {
    _initLocalState();
    _fetchExtendedSummary();
  }

  Future<void> _initLocalState() async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = prefs.getStringList('favorite_book_ids') ?? [];
    final isFav = favorites.contains(book.id.toString());

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/books/${book.id}.epub';
    final fileExists = await File(filePath).exists();

    state = state.copyWith(
      isFavorite: isFav,
      downloadState: fileExists
          ? DownloadState.downloaded
          : DownloadState.notDownloaded,
    );
  }

  Future<void> _fetchExtendedSummary() async {
    if (book.description == null || book.description!.trim().isEmpty) {
      if (book.workKey != null && book.workKey!.isNotEmpty) {
        final apiClient = ref.read(gutendexApiClientProvider);
        final desc = await apiClient.fetchWorkDescription(book.workKey!);
        if (desc != null && desc.trim().isNotEmpty) {
          book = book.copyWith(description: desc);
          state = state.copyWith();
        }
      }
    }
  }

  void toggleDescriptionExpanded() {
    state = state.copyWith(
      isDescriptionExpanded: !state.isDescriptionExpanded,
    );
  }

  /// Persistent Favorite Toggle with Metadata saving
  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favorite_book_ids') ?? [];
    final favBooksJson = prefs.getStringList('saved_favorite_books') ?? [];

    final bookIdStr = book.id.toString();
    final isCurrentlyFav = favIds.contains(bookIdStr);

    final updatedIds = List<String>.from(favIds);
    final updatedBooks = List<String>.from(favBooksJson);

    if (isCurrentlyFav) {
      updatedIds.remove(bookIdStr);
      updatedBooks.removeWhere((item) {
        try {
          final map = jsonDecode(item);
          return map['id'] == book.id;
        } catch (_) {
          return false;
        }
      });
    } else {
      updatedIds.add(bookIdStr);
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
      updatedBooks.insert(0, bookJson);
    }

    await prefs.setStringList('favorite_book_ids', updatedIds);
    await prefs.setStringList('saved_favorite_books', updatedBooks);

    state = state.copyWith(isFavorite: !isCurrentlyFav);

    // Sync Library state
    ref.read(libraryControllerProvider.notifier).loadLibrary();
  }

  /// Real-time Download Execution
  Future<void> downloadBook() async {
    if (book.epubUrl == null || book.epubUrl!.isEmpty) {
      state = state.copyWith(
        downloadState: DownloadState.error,
        errorMessage: 'No EPUB download link available for this book.',
      );
      return;
    }

    state = state.copyWith(
      downloadState: DownloadState.downloading,
      downloadProgress: 0.05,
      errorMessage: null,
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${dir.path}/books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      final savePath = '${booksDir.path}/${book.id}.epub';
      _cancelToken = CancelToken();

      final dio = Dio();
      await dio.download(
        book.epubUrl!,
        savePath,
        cancelToken: _cancelToken,
        options: Options(
          followRedirects: true,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 EBuk/1.0',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = state.copyWith(
              downloadProgress: (received / total).clamp(0.05, 0.99),
            );
          }
        },
      );

      state = state.copyWith(
        downloadState: DownloadState.downloaded,
        downloadProgress: 1.0,
      );

      // Save to library
      await ref.read(libraryControllerProvider.notifier).recordDownloadedBook(book);
    } catch (e) {
      if (CancelToken.isCancel(e as dynamic)) {
        state = state.copyWith(
          downloadState: DownloadState.notDownloaded,
          downloadProgress: 0.0,
        );
      } else {
        state = state.copyWith(
          downloadState: DownloadState.error,
          errorMessage: 'Download was interrupted. Tap retry to download again.',
        );
      }
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    state = state.copyWith(
      downloadState: DownloadState.notDownloaded,
      downloadProgress: 0.0,
    );
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }
}

final bookDetailsControllerProvider = StateNotifierProvider.autoDispose
    .family<BookDetailsController, BookDetailsState, Book>((ref, book) {
  return BookDetailsController(book: book, ref: ref);
});
