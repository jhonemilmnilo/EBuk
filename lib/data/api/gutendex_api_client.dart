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

  /// Primary search engine
  Future<BookSearchResult> searchBooks({
    String? query,
    String? topic,
    String? customUrl,
  }) async {
    if (customUrl != null && customUrl.isNotEmpty) {
      try {
        final response = await _dio.get(customUrl);
        if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          return _parseOpenLibraryResponse(response.data as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    final searchTerm = query?.trim() ?? '';
    final searchTopic = topic?.trim() ?? '';

    if (searchTerm.isEmpty && searchTopic.isEmpty) {
      return const BookSearchResult(count: 0, books: []);
    }

    // 1. Query Open Library API
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
          'limit': 20,
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

    // 2. Fallback: Gutendex
    try {
      final queryParams = <String, dynamic>{'languages': 'en'};
      if (searchTerm.isNotEmpty) queryParams['search'] = searchTerm;
      if (searchTopic.isNotEmpty) queryParams['topic'] = searchTopic.toLowerCase();

      final response = await _dio.get(
        'https://gutendex.com/books/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return BookSearchResult.fromJson(response.data as Map<String, dynamic>);
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

      String? epubUrl;
      int bookId = 0;
      if (doc['id_project_gutenberg'] is List &&
          (doc['id_project_gutenberg'] as List).isNotEmpty) {
        final gutenId = (doc['id_project_gutenberg'] as List).first.toString();
        bookId = int.tryParse(gutenId) ?? 0;
        epubUrl = 'https://www.gutenberg.org/ebooks/$gutenId.epub.images';
      } else {
        final keyStr = doc['key']?.toString() ?? doc['title'].toString();
        bookId = keyStr.hashCode.abs();
      }

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

    final total = json['numFound'] as int? ?? books.length;
    final start = json['start'] as int? ?? 0;
    final nextUrl = (start + books.length < total)
        ? 'https://openlibrary.org/search.json?q=${json['q']}&offset=${start + books.length}&limit=20'
        : null;

    return BookSearchResult(
      count: total,
      nextUrl: nextUrl,
      books: books,
    );
  }
}
