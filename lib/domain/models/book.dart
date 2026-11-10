/// Domain model representing a book retrieved from Project Gutenberg (Gutendex) or Open Library.
class Book {
  final int id;
  final String title;
  final List<String> authors;
  final List<String> subjects;
  final List<String> languages;
  final String? coverUrl;
  final String? epubUrl;
  final String? description;
  final String? workKey; // e.g. "/works/OL17930368W"

  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.subjects = const [],
    this.languages = const [],
    this.coverUrl,
    this.epubUrl,
    this.description,
    this.workKey,
  });

  String get authorsDisplay {
    if (authors.isEmpty) return 'Unknown Author';
    return authors.join(', ');
  }

  Book copyWith({
    int? id,
    String? title,
    List<String>? authors,
    List<String>? subjects,
    List<String>? languages,
    String? coverUrl,
    String? epubUrl,
    String? description,
    String? workKey,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      subjects: subjects ?? this.subjects,
      languages: languages ?? this.languages,
      coverUrl: coverUrl ?? this.coverUrl,
      epubUrl: epubUrl ?? this.epubUrl,
      description: description ?? this.description,
      workKey: workKey ?? this.workKey,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    // Parse authors
    final authorsList = <String>[];
    if (json['authors'] is List) {
      for (final a in json['authors']) {
        if (a is Map && a['name'] != null) {
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
      cover = formats['image/jpeg'] as String?;
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
