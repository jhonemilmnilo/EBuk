import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/book.dart';
import '../../controllers/book_details_controller.dart';
import '../widgets/book_action_buttons.dart';
import '../widgets/book_hero_section.dart';
import '../widgets/book_subjects_chips.dart';
import '../widgets/book_synopsis_section.dart';

class BookDetailsScreen extends ConsumerWidget {
  final Book book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookDetailsControllerProvider(book));
    final controller = ref.read(bookDetailsControllerProvider(book).notifier);
    final activeBook = controller.book;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? AppColors.darkText : AppColors.primary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    AppStrings.bookDetails,
                    style: AppTypography.display.copyWith(
                      fontSize: 18,
                      color: isDark ? AppColors.darkText : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section: Cover + Title + Author + Language
                    BookHeroSection(book: activeBook),
                    const SizedBox(height: 20),

                    // Subject Chips
                    if (activeBook.subjects.isNotEmpty) ...[
                      BookSubjectsChips(subjects: activeBook.subjects),
                      const SizedBox(height: 18),
                    ],

                    // Short Summary (Clean plain text without card container)
                    BookSynopsisSection(
                      description: activeBook.description,
                      isExpanded: state.isDescriptionExpanded,
                      onToggle: () => controller.toggleDescriptionExpanded(),
                    ),
                    const SizedBox(height: 28),

                    // Action Buttons (Download, Favorite)
                    BookActionButtons(
                      state: state,
                      onDownload: () => controller.downloadBook(),
                      onCancelDownload: () => controller.cancelDownload(),
                      onReadNow: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening book in Reader...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      onToggleFavorite: () => controller.toggleFavorite(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
