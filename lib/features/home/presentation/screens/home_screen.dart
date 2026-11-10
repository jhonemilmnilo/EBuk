import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../controllers/home_controller.dart';
import '../widgets/category_grid_section.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/recent_searches_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header Title
              const SizedBox(height: 8),
              const Text(
                AppStrings.appName,
                style: AppTypography.display,
              ),
              const SizedBox(height: 16),

              // Search Bar
              HomeSearchBar(
                onTap: () {
                  // Navigation will be linked to /search route
                },
              ),
              const SizedBox(height: 24),

              // Recent Searches
              if (homeState.recentSearches.isNotEmpty) ...[
                RecentSearchesSection(
                  searches: homeState.recentSearches,
                  onSelect: (query) {
                    // Navigate to search with query
                  },
                  onRemove: (query) => controller.removeRecentSearch(query),
                  onClearAll: () => controller.clearRecentSearches(),
                ),
                const SizedBox(height: 24),
              ],

              // Browse by Category
              CategoryGridSection(
                onCategorySelected: (category) {
                  // Navigate to search with topic
                },
              ),
              const SizedBox(height: 24),

              // Continue Reading
              if (homeState.continueReadingBook != null) ...[
                ContinueReadingCard(
                  book: homeState.continueReadingBook!,
                  onResume: () {
                    // Navigate to reader
                  },
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

