import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/api_providers.dart';
import '../../../domain/models/book.dart';
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

  /// Automatically fetches full description/summary if not already loaded
  Future<void> _fetchExtendedSummary() async {
    if (book.description == null || book.description!.trim().isEmpty) {
      if (book.workKey != null && book.workKey!.isNotEmpty) {
        final apiClient = ref.read(gutendexApiClientProvider);
        final desc = await apiClient.fetchWorkDescription(book.workKey!);
        if (desc != null && desc.trim().isNotEmpty) {
          book = book.copyWith(description: desc);
          // Trigger UI rebuild with updated description
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

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_book_ids') ?? [];
    final bookIdStr = book.id.toString();

    final updated = List<String>.from(favorites);
    if (updated.contains(bookIdStr)) {
      updated.remove(bookIdStr);
    } else {
      updated.add(bookIdStr);
    }

    await prefs.setStringList('favorite_book_ids', updated);
    state = state.copyWith(isFavorite: !state.isFavorite);
  }

  Future<void> downloadBook() async {
    if (book.epubUrl == null || book.epubUrl!.isEmpty) {
      state = state.copyWith(
        downloadState: DownloadState.error,
        errorMessage: 'No EPUB download format available for this title.',
      );
      return;
    }

    state = state.copyWith(
      downloadState: DownloadState.downloading,
      downloadProgress: 0.0,
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
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = state.copyWith(downloadProgress: received / total);
          }
        },
      );

      state = state.copyWith(
        downloadState: DownloadState.downloaded,
        downloadProgress: 1.0,
      );
    } catch (e) {
      if (CancelToken.isCancel(e as dynamic)) {
        state = state.copyWith(
          downloadState: DownloadState.notDownloaded,
          downloadProgress: 0.0,
        );
      } else {
        state = state.copyWith(
          downloadState: DownloadState.error,
          errorMessage: 'Download failed. Please check your connection.',
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
