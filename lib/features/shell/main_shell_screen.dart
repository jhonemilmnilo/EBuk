import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../home/presentation/screens/home_screen.dart';
import '../library/presentation/screens/library_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  // Index order: 0 = Library (Left), 1 = Home (Middle), 2 = Settings (Right)
  int _selectedIndex = 1;

  static const List<Widget> _screens = [
    LibraryScreen(),
    HomeScreen(),
    _PlaceholderScreen(title: AppStrings.navSettings),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Custom Curved Bar Background
              Positioned.fill(
                top: 15,
                child: CustomPaint(
                  painter: _CurvedBarPainter(
                    selectedIndex: _selectedIndex,
                    itemCount: 3,
                    barColor: isDark ? AppColors.darkSurface : AppColors.background,
                    borderColor: isDark
                        ? AppColors.darkNeutral.withValues(alpha: 0.8)
                        : AppColors.neutral.withValues(alpha: 0.45),
                    shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  ),
                ),
              ),

              // Nav Items Row
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCurvedNavItem(
                      index: 0,
                      icon: Icons.local_library_outlined,
                      activeIcon: Icons.local_library,
                      label: AppStrings.navLibrary,
                      isDark: isDark,
                    ),
                    _buildCurvedNavItem(
                      index: 1,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: AppStrings.navHome,
                      isDark: isDark,
                    ),
                    _buildCurvedNavItem(
                      index: 2,
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      label: AppStrings.navSettings,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurvedNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, isSelected ? -10 : 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Raised / Floating Circular Button when active
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                      : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (isDark ? AppColors.primaryLight : AppColors.primary)
                                .withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? (isDark ? AppColors.darkBackground : AppColors.textOnPrimary)
                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.darkText : AppColors.primary)
                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedBarPainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;
  final Color barColor;
  final Color borderColor;
  final Color shadowColor;

  _CurvedBarPainter({
    required this.selectedIndex,
    required this.itemCount,
    required this.barColor,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw ambient shadow
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final itemWidth = size.width / itemCount;
    final activeCenterX = itemWidth * selectedIndex + (itemWidth / 2);

    const notchRadius = 32.0;

    final path = Path();
    path.moveTo(0, 0);

    // Left straight line to the notch entrance
    final notchStart = (activeCenterX - notchRadius - 16).clamp(0.0, size.width);
    final notchEnd = (activeCenterX + notchRadius + 16).clamp(0.0, size.width);

    path.lineTo(notchStart, 0);

    // Smooth bezier curve dipping down (lulubog) around the floating circle
    path.cubicTo(
      activeCenterX - notchRadius, 0,
      activeCenterX - notchRadius + 4, notchRadius * 0.75,
      activeCenterX, notchRadius * 0.75,
    );
    path.cubicTo(
      activeCenterX + notchRadius - 4, notchRadius * 0.75,
      activeCenterX + notchRadius, 0,
      notchEnd, 0,
    );

    // Continue to right edge
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow first
    canvas.drawPath(path, shadowPaint);

    // Draw solid bar body
    canvas.drawPath(path, paint);

    // Draw top border line following the curve
    final topBorderPath = Path();
    topBorderPath.moveTo(0, 0);
    topBorderPath.lineTo(notchStart, 0);
    topBorderPath.cubicTo(
      activeCenterX - notchRadius, 0,
      activeCenterX - notchRadius + 4, notchRadius * 0.75,
      activeCenterX, notchRadius * 0.75,
    );
    topBorderPath.cubicTo(
      activeCenterX + notchRadius - 4, notchRadius * 0.75,
      activeCenterX + notchRadius, 0,
      notchEnd, 0,
    );
    topBorderPath.lineTo(size.width, 0);

    canvas.drawPath(topBorderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedBarPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.barColor != barColor ||
        oldDelegate.borderColor != borderColor;
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
