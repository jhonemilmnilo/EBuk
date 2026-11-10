/// Single source of truth for all user-facing strings across EBuk.
///
/// Rules:
/// - English only, clean and professional tone.
/// - No slang, emojis, or filler text.
/// - Never hardcode strings in widgets.
abstract class AppStrings {
  // App Identity
  static const String appName = 'EBuk';
  static const String appTagline = 'Distraction-free public-domain reading';

  // Navigation
  static const String navHome = 'Home';
  static const String navLibrary = 'Library';
  static const String navSettings = 'Settings';

  // Common Actions
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String open = 'Open';
  static const String close = 'Close';
  static const String search = 'Search';
  static const String download = 'Download';
  static const String downloading = 'Downloading';
  static const String downloaded = 'Downloaded';
  static const String remove = 'Remove';

  // Home Screen
  static const String searchPlaceholder = 'Search title, author, or subject...';
  static const String recentSearches = 'Recent Searches';
  static const String popularTopics = 'Explore Topics';
  static const String continueReading = 'Continue Reading';
  static const String clearHistory = 'Clear History';

  // Search Results Screen
  static const String searchResults = 'Search Results';
  static const String noResultsTitle = 'No Books Found';
  static const String noResultsSubtitle =
      'Try checking your spelling or searching for another title or author.';
  static const String searchInitialPrompt =
      'Type a query above to explore free public-domain classics.';

  // Book Details Screen
  static const String bookDetails = 'Book Details';
  static const String authors = 'Authors';
  static const String subjects = 'Subjects';
  static const String downloadBook = 'Download Book';
  static const String deleteFromDevice = 'Delete from Device';
  static const String readNow = 'Read Now';
  static const String description = 'Description';

  // Library Screen
  static const String yourLibrary = 'Your Library';
  static const String emptyLibraryTitle = 'Your Library is Empty';
  static const String emptyLibrarySubtitle =
      'Books you download will appear here for offline reading.';
  static const String confirmDeleteTitle = 'Remove Book';
  static const String confirmDeleteMessage =
      'Are you sure you want to remove this book and its downloaded file from your device?';

  // Reader Screen
  static const String tableOfContents = 'Table of Contents';
  static const String appearance = 'Appearance';
  static const String fontSize = 'Font Size';
  static const String themeLight = 'Light';
  static const String themeSepia = 'Sepia';
  static const String themeDark = 'Dark';
  static const String corruptedBookError =
      'This book could not be opened. Remove it from your device and download it again.';

  // Settings Screen
  static const String appTheme = 'App Theme';
  static const String themeSystem = 'System Default';
  static const String storageUsed = 'Storage Used';
  static const String clearCachedCovers = 'Clear Cached Covers';
  static const String about = 'About';
  static const String attributionTitle = 'Data Sources & Attribution';
  static const String attributionBody =
      'Book metadata and EPUB files are provided courtesy of Project Gutenberg via Gutendex. Project Gutenberg is a registered trademark of the Project Gutenberg Literary Archive Foundation.';
  static const String privacyTitle = 'Privacy';
  static const String privacyBody =
      'EBuk has no user accounts, requires no analytics, and does not collect or transmit personal data. All books and reading positions are stored strictly on your device.';

  // Error Messages
  static const String networkError =
      'Unable to connect to the server. Please check your internet connection and try again.';
  static const String timeoutError =
      'The connection timed out. Project Gutenberg servers may be busy. Please try again.';
  static const String genericError =
      'An unexpected error occurred. Please try again.';
  static const String diskFullError =
      'Not enough device storage available to complete the download.';
}
