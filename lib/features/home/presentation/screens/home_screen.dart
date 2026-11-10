import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ebuk/core/strings.dart';
import 'package:ebuk/core/theme/app_colors.dart';
import 'package:ebuk/core/theme/app_typography.dart';
import 'package:ebuk/features/home/controllers/home_controller.dart';
import 'package:ebuk/features/home/presentation/widgets/category_grid_section.dart';
import 'package:ebuk/features/home/presentation/widgets/continue_reading_card.dart';
import 'package:ebuk/features/home/presentation/widgets/home_search_bar.dart';
import 'package:ebuk/features/home/presentation/widgets/recent_searches_section.dart';
import 'package:ebuk/features/search/presentation/screens/search_screen.dart';

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

              // Search Bar (Navigates to Search Screen on Tap)
              HomeSearchBar(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Recent Searches
              if (homeState.recentSearches.isNotEmpty) ...[
                RecentSearchesSection(
                  searches: homeState.recentSearches,
                  onSelect: (query) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(initialQuery: query),
                      ),
                    );
                  },
                  onRemove: (query) => controller.removeRecentSearch(query),
                  onClearAll: () => controller.clearRecentSearches(),
                ),
                const SizedBox(height: 24),
              ],

              // Browse by Category (Navigates to Search Screen with preselected topic)
              CategoryGridSection(
                onCategorySelected: (category) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(initialTopic: category),
                    ),
                  );
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
