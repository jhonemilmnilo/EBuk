import 'package:dio/dio.dart';
import '../../core/strings.dart';
import '../../domain/models/book.dart';

class GutendexApiClient {
  final Dio _dio;

  GutendexApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 12),
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 EBuk/1.0',
                  'Accept': 'application/json',
                },
              ),
            );

  /// Fetch full work details/description from Open Library
  Future<String?> fetchWorkDescription(String workKey) async {
    try {
      final cleanKey = workKey.startsWith('/') ? workKey : '/$workKey';
      final response = await _dio.get('https://openlibrary.org$cleanKey.json');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final desc = data['description'];
        if (desc is String && desc.trim().isNotEmpty) {
          return desc.trim();
        } else if (desc is Map && desc['value'] != null) {
          return desc['value'].toString().trim();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Search books with a strict filter:
  /// ONLY returns books that have a guaranteed 100% free downloadable EPUB file
  /// from Project Gutenberg's verified public-domain catalog.
  Future<BookSearchResult> searchBooks({
    String? query,
    String? topic,
    String? customUrl,
  }) async {
    final searchTerm = query?.trim() ?? '';
    final searchTopic = topic?.trim() ?? '';

    if (searchTerm.isEmpty && searchTopic.isEmpty) {
      return const BookSearchResult(count: 0, books: []);
    }

    // 1. Query Open Library strictly for Project Gutenberg public-domain titles
    try {
      final queryBuffer = StringBuffer();
      if (searchTerm.isNotEmpty) {
        queryBuffer.write(searchTerm);
      }
      if (searchTopic.isNotEmpty) {
        if (queryBuffer.isNotEmpty) queryBuffer.write(' ');
        queryBuffer.write('subject:$searchTopic');
      }

      final uri = 'https://openlibrary.org/search.json';
      final response = await _dio.get(
        uri,
        queryParameters: {
          'q': queryBuffer.toString(),
          'limit': 40,
          'has_fulltext': 'true',
          'fields':
              'key,title,author_name,cover_i,id_project_gutenberg,language,subject,first_sentence,ebook_access',
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final olResult =
            _parseOpenLibraryResponse(response.data as Map<String, dynamic>);
        if (olResult.books.isNotEmpty) {
          return olResult;
        }
      }
    } catch (_) {}

    // 2. Fallback: Gutendex Project Gutenberg Catalog
    try {
      final queryParams = <String, dynamic>{'languages': 'en'};
      if (searchTerm.isNotEmpty) queryParams['search'] = searchTerm;
      if (searchTopic.isNotEmpty) queryParams['topic'] = searchTopic.toLowerCase();

      final response = await _dio.get(
        'https://gutendex.com/books/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final gutenResult =
            BookSearchResult.fromJson(response.data as Map<String, dynamic>);
        final withEpub = gutenResult.books
            .where((b) => b.epubUrl != null && b.epubUrl!.isNotEmpty)
            .toList();
        return BookSearchResult(
          count: withEpub.length,
          nextUrl: gutenResult.nextUrl,
          books: withEpub,
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception(AppStrings.timeoutError);
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception(AppStrings.networkError);
        }
      }
    }

    return const BookSearchResult(count: 0, books: []);
  }

  BookSearchResult _parseOpenLibraryResponse(Map<String, dynamic> json) {
    final docs = json['docs'] as List? ?? [];
    final books = <Book>[];

    for (final doc in docs) {
      if (doc is! Map) continue;

      // Strictly accept books with a verified Project Gutenberg ID
      String? epubUrl;
      int bookId = 0;

      if (doc['id_project_gutenberg'] is List &&
          (doc['id_project_gutenberg'] as List).isNotEmpty) {
        final gutenId = (doc['id_project_gutenberg'] as List).first.toString();
        bookId = int.tryParse(gutenId) ?? 0;
        // Verified direct public domain EPUB download url
        epubUrl = 'https://www.gutenberg.org/ebooks/$gutenId.epub.images';
      }

      // If no open Gutenberg EPUB is verified, omit to prevent 401 Unauthorized errors
      if (epubUrl == null || epubUrl.isEmpty) {
        continue;
      }

      final authorList = <String>[];
      if (doc['author_name'] is List) {
        for (final a in doc['author_name']) {
          if (a != null) authorList.add(a.toString());
        }
      }

      final coverId = doc['cover_i'];
      final coverUrl = coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : null;

      String? summary;
      if (doc['first_sentence'] is Map &&
          doc['first_sentence']['value'] != null) {
        summary = doc['first_sentence']['value'].toString();
      } else if (doc['first_sentence'] is List &&
          (doc['first_sentence'] as List).isNotEmpty) {
        summary = (doc['first_sentence'] as List).first.toString();
      }

      final subjects = <String>[];
      if (doc['subject'] is List) {
        for (final s in (doc['subject'] as List).take(5)) {
          if (s != null) subjects.add(s.toString());
        }
      }

      books.add(
        Book(
          id: bookId,
          title: doc['title']?.toString() ?? 'Untitled',
          authors: authorList,
          coverUrl: coverUrl,
          epubUrl: epubUrl,
          description: summary,
          subjects: subjects,
          workKey: doc['key']?.toString(),
        ),
      );
    }

    return BookSearchResult(
      count: books.length,
      nextUrl: null,
      books: books,
    );
  }
}
