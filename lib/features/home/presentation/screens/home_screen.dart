import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../domain/models/book.dart';
import '../../../reader/presentation/screens/reader_screen.dart';
import '../../controllers/home_controller.dart';
import 'package:ebuk/features/search/presentation/screens/search_screen.dart';
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
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Nav Bar Header with Title and Night/Light Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.appName,
                    style: AppTypography.display.copyWith(
                      color: isDark ? AppColors.darkText : AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                    icon: Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      color: isDark ? AppColors.darkText : AppColors.primary,
                      size: 24,
                    ),
                    tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Night Mode',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Bar
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

              // Browse by Category (Text-only pills)
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
                    final cBook = homeState.continueReadingBook!;
                    final book = Book(
                      id: cBook.id,
                      title: cBook.title,
                      authors: [cBook.author],
                      coverUrl: cBook.coverUrl,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReaderScreen(book: book),
                      ),
                    ).then((_) => controller.loadHomeData());
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
