import 'package:dio/dio.dart';
import '../../core/strings.dart';
import '../../domain/models/book.dart';

class GutendexApiClient {
  final Dio _dio;

  GutendexApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://gutendex.com/books',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  /// Search books by query or topic. Returns paginated BookSearchResult.
  Future<BookSearchResult> searchBooks({
    String? query,
    String? topic,
    String? customUrl,
  }) async {
    try {
      final Response response;
      if (customUrl != null && customUrl.isNotEmpty) {
        response = await _dio.get(customUrl);
      } else {
        final queryParams = <String, dynamic>{
          'languages': 'en',
        };
        if (query != null && query.trim().isNotEmpty) {
          queryParams['search'] = query.trim();
        }
        if (topic != null && topic.trim().isNotEmpty) {
          queryParams['topic'] = topic.trim().toLowerCase();
        }

        response = await _dio.get('', queryParameters: queryParams);
      }

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return BookSearchResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(AppStrings.genericError);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(AppStrings.timeoutError);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(AppStrings.networkError);
      } else {
        throw Exception(AppStrings.genericError);
      }
    } catch (_) {
      throw Exception(AppStrings.genericError);
    }
  }
}

