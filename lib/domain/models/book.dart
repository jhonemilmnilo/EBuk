/// Domain model representing a book retrieved from Project Gutenberg (Gutendex).
class Book {
  final int id;
  final String title;
  final List<String> authors;
  final List<String> subjects;
  final List<String> languages;
  final String? coverUrl;
  final String? epubUrl;
  final String? description;

  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.subjects = const [],
    this.languages = const [],
    this.coverUrl,
    this.epubUrl,
    this.description,
  });

  String get authorsDisplay {
    if (authors.isEmpty) return 'Unknown Author';
    return authors.join(', ');
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    // Parse authors
    final authorsList = <String>[];
    if (json['authors'] is List) {
      for (final a in json['authors']) {
        if (a is Map && a['name'] != null) {
          // Normalize format "LastName, FirstName" to "FirstName LastName"
          final rawName = a['name'].toString();
          if (rawName.contains(',')) {
            final parts = rawName.split(',');
            authorsList.add('${parts.last.trim()} ${parts.first.trim()}');
          } else {
            authorsList.add(rawName);
          }
        }
      }
    }

    // Parse subjects
    final subjectsList = <String>[];
    if (json['subjects'] is List) {
      for (final s in json['subjects']) {
        if (s != null) subjectsList.add(s.toString());
      }
    }

    // Parse languages
    final languagesList = <String>[];
    if (json['languages'] is List) {
      for (final l in json['languages']) {
        if (l != null) languagesList.add(l.toString());
      }
    }

    // Parse formats for EPUB and JPEG cover
    String? cover;
    String? epub;
    if (json['formats'] is Map) {
      final formats = json['formats'] as Map<String, dynamic>;

      // Cover image
      cover = formats['image/jpeg'] as String?;

      // EPUB download link (application/epub+zip is preferred)
      epub = formats['application/epub+zip'] as String? ??
          formats['application/x-mobipocket-ebook'] as String?;
    }

    // Parse description/summary if provided by API
    String? summary;
    if (json['summaries'] is List && (json['summaries'] as List).isNotEmpty) {
      summary = (json['summaries'] as List).first.toString();
    }

    return Book(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      authors: authorsList,
      subjects: subjectsList,
      languages: languagesList,
      coverUrl: cover,
      epubUrl: epub,
      description: summary,
    );
  }
}

class BookSearchResult {
  final int count;
  final String? nextUrl;
  final List<Book> books;

  const BookSearchResult({
    required this.count,
    this.nextUrl,
    required this.books,
  });

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    final results = <Book>[];
    if (json['results'] is List) {
      for (final item in json['results']) {
        if (item is Map<String, dynamic>) {
          results.add(Book.fromJson(item));
        }
      }
    }

    return BookSearchResult(
      count: json['count'] as int? ?? 0,
      nextUrl: json['next'] as String?,
      books: results,
    );
  }
}

