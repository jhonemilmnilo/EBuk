import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/continue_reading_book.dart';
import '../state/home_state.dart';

class HomeController extends StateNotifier<HomeState> {
  static const _keyRecentSearches = 'recent_search_queries';
  static const _keyLastRead = 'last_read_book';

  HomeController() : super(const HomeState()) {
    loadHomeData();
  }

  /// Initial load making zero network requests (local storage only).
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();

    final searches = prefs.getStringList(_keyRecentSearches) ?? [];

    ContinueReadingBook? continueBook;
    final lastReadRaw = prefs.getString(_keyLastRead);
    if (lastReadRaw != null) {
      try {
        final map = jsonDecode(lastReadRaw);
        continueBook = ContinueReadingBook(
          id: map['id'] as int,
          title: map['title'] as String,
          author: map['author'] as String,
          progress: (map['progress'] as num).toDouble(),
          coverUrl: map['coverUrl'] as String?,
        );
      } catch (_) {}
    }

    state = state.copyWith(
      isLoading: false,
      recentSearches: searches,
      continueReadingBook: continueBook,
      clearContinueReading: continueBook == null,
    );
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...state.recentSearches
          .where((item) => item.toLowerCase() != trimmed.toLowerCase()),
    ].take(10).toList();

    state = state.copyWith(recentSearches: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRecentSearches, updated);
  }

  Future<void> removeRecentSearch(String query) async {
    final updatedList =
        state.recentSearches.where((item) => item != query).toList();
    state = state.copyWith(recentSearches: updatedList);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRecentSearches, updatedList);
  }

  Future<void> clearRecentSearches() async {
    state = state.copyWith(recentSearches: const []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRecentSearches);
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});
