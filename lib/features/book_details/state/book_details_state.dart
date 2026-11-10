enum DownloadState { notDownloaded, downloading, downloaded, error }

class BookDetailsState {
  final bool isFavorite;
  final DownloadState downloadState;
  final double downloadProgress; // 0.0 to 1.0
  final String? errorMessage;
  final bool isDescriptionExpanded;

  const BookDetailsState({
    this.isFavorite = false,
    this.downloadState = DownloadState.notDownloaded,
    this.downloadProgress = 0.0,
    this.errorMessage,
    this.isDescriptionExpanded = false,
  });

  BookDetailsState copyWith({
    bool? isFavorite,
    DownloadState? downloadState,
    double? downloadProgress,
    String? errorMessage,
    bool? isDescriptionExpanded,
  }) {
    return BookDetailsState(
      isFavorite: isFavorite ?? this.isFavorite,
      downloadState: downloadState ?? this.downloadState,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      isDescriptionExpanded:
          isDescriptionExpanded ?? this.isDescriptionExpanded,
    );
  }
}

