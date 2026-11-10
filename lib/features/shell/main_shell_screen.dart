import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../home/presentation/screens/home_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    _PlaceholderScreen(title: AppStrings.navLibrary),
    _PlaceholderScreen(title: AppStrings.navSettings),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.background,
          // Curved edges strictly on the TOP side
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.darkNeutral.withValues(alpha: 0.8)
                  : AppColors.neutral.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildModernNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: AppStrings.navHome,
              isDark: isDark,
            ),
            _buildModernNavItem(
              index: 1,
              icon: Icons.local_library_outlined,
              activeIcon: Icons.local_library,
              label: AppStrings.navLibrary,
              isDark: isDark,
            ),
            _buildModernNavItem(
              index: 2,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: AppStrings.navSettings,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.25)
                  : AppColors.primary.withValues(alpha: 0.12))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? (isDark ? AppColors.darkText : AppColors.primary)
                  : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              size: 24,
            ),
            // Text is strictly positioned BELOW the icon
            if (isSelected) ...[
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.primary,
                  fontSize: 11.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.display.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textDark,
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
