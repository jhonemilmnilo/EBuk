class ContinueReadingBook {
  final int id;
  final String title;
  final String author;
  final String? coverUrl;
  final double progress; // 0.0 to 1.0

  const ContinueReadingBook({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.progress,
  });
}

