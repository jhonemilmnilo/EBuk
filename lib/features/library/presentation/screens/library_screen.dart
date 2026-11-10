import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ebuk/core/strings.dart';
import 'package:ebuk/core/theme/app_colors.dart';
import 'package:ebuk/core/theme/app_typography.dart';
import 'package:ebuk/domain/models/book.dart';
import 'package:ebuk/features/book_details/presentation/screens/book_details_screen.dart';
import 'package:ebuk/features/library/controllers/library_controller.dart';
import 'package:ebuk/features/library/presentation/widgets/library_book_card.dart';
import 'package:ebuk/features/library/presentation/widgets/library_empty_state.dart';
import 'package:ebuk/features/library/presentation/widgets/library_tab_bar.dart';
import 'package:ebuk/features/search/presentation/screens/search_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryControllerProvider.notifier).loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryControllerProvider);
    final controller = ref.read(libraryControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final books = libraryState.currentList;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Search action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.yourLibrary,
                    style: AppTypography.display.copyWith(
                      color: isDark ? AppColors.darkText : AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.search,
                      color: isDark ? AppColors.darkText : AppColors.primary,
                      size: 24,
                    ),
                    tooltip: 'Search books',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Segmented Tab Bar: Downloaded vs Favorites
              LibraryTabBar(
                activeTab: libraryState.activeTab,
                onTabChanged: (tab) => controller.switchTab(tab),
              ),
              const SizedBox(height: 16),

              // Content Body
              Expanded(
                child: books.isEmpty
                    ? LibraryEmptyState(
                        activeTab: libraryState.activeTab,
                        onSearchPrompt: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          final progress =
                              libraryState.readingProgressMap[book.id] ?? 0.0;

                          return LibraryBookCard(
                            book: book,
                            progress: progress,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookDetailsScreen(book: book),
                                ),
                              );
                            },
                            onRemove: () =>
                                _showOptionsSheet(context, book, controller),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(
    BuildContext context,
    Book book,
    LibraryController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Remove from Device',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.removeBookFromDevice(book.id);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.favorite_border,
                    color: isDark ? AppColors.darkText : AppColors.textDark,
                  ),
                  title: Text(
                    'Remove from Favorites',
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.textDark,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.removeBookFromFavorites(book.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
