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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.neutral.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, AppStrings.navHome),
            _buildNavItem(1, AppStrings.navLibrary),
            _buildNavItem(2, AppStrings.navSettings),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.sectionHeader.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 24,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.display,
              ),
              const Spacer(),
              Center(
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(color: AppColors.textMuted),
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

