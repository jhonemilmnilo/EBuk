import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/continue_reading_book.dart';
import '../state/home_state.dart';

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(const HomeState()) {
    loadHomeData();
  }

  /// Initial load making zero network requests (local only).
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true);

    // Initial local state with sample historic data matching spec
    state = state.copyWith(
      isLoading: false,
      recentSearches: const [
        'Pride and Prejudice',
        '1984',
        'The Great Gatsby',
      ],
      continueReadingBook: const ContinueReadingBook(
        id: 64317,
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        progress: 0.68,
      ),
    );
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

