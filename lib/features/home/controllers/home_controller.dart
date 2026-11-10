import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/home_state.dart';

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(const HomeState()) {
    loadHomeData();
  }

  /// Initial load making zero network requests (local storage only).
  /// Starts cleanly with no mock data until the user searches or reads a book.
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true);

    state = state.copyWith(
      isLoading: false,
      recentSearches: const [],
      clearContinueReading: true,
    );
  }

  void addRecentSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...state.recentSearches.where((item) => item.toLowerCase() != trimmed.toLowerCase()),
    ].take(10).toList();

    state = state.copyWith(recentSearches: updated);
  }

  void removeRecentSearch(String query) {
    final updatedList =
        state.recentSearches.where((item) => item != query).toList();
    state = state.copyWith(recentSearches: updatedList);
  }

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: const []);
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});
