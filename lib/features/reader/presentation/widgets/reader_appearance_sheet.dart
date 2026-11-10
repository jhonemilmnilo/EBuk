import 'package:flutter/material.dart';
import '../../../../core/strings.dart';
import '../../models/reader_settings.dart';

class ReaderAppearanceSheet extends StatelessWidget {
  final ReaderSettings settings;
  final ReaderThemeMode activeTheme;
  final ValueChanged<ReaderThemeMode> onThemeChanged;
  final ValueChanged<double> onFontSizeChanged;
  final VoidCallback onToggleSerif;

  const ReaderAppearanceSheet({
    super.key,
    required this.settings,
    required this.activeTheme,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onToggleSerif,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = activeTheme.backgroundColor;
    final textColor = activeTheme.textColor;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            AppStrings.appearance,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),

          // Theme selector
          Row(
            children: [
              _buildThemeOption(
                mode: ReaderThemeMode.light,
                label: AppStrings.themeLight,
                bg: ReaderThemeMode.light.backgroundColor,
                fg: ReaderThemeMode.light.textColor,
                isSelected: activeTheme == ReaderThemeMode.light,
              ),
              const SizedBox(width: 12),
              _buildThemeOption(
                mode: ReaderThemeMode.sepia,
                label: AppStrings.themeSepia,
                bg: ReaderThemeMode.sepia.backgroundColor,
                fg: ReaderThemeMode.sepia.textColor,
                isSelected: activeTheme == ReaderThemeMode.sepia,
              ),
              const SizedBox(width: 12),
              _buildThemeOption(
                mode: ReaderThemeMode.dark,
                label: AppStrings.themeDark,
                bg: ReaderThemeMode.dark.backgroundColor,
                fg: ReaderThemeMode.dark.textColor,
                isSelected: activeTheme == ReaderThemeMode.dark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Font Size Stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.fontSize,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: settings.fontSize > 12.0
                        ? () => onFontSizeChanged(settings.fontSize - 2)
                        : null,
                    icon: Icon(Icons.remove_circle_outline, color: textColor),
                  ),
                  Text(
                    '${settings.fontSize.toInt()} pt',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: settings.fontSize < 28.0
                        ? () => onFontSizeChanged(settings.fontSize + 2)
                        : null,
                    icon: Icon(Icons.add_circle_outline, color: textColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Font Family Toggle (Serif vs Sans-Serif)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Typography',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              ChoiceChip(
                label: Text(
                  settings.isSerif ? 'Serif (Classic)' : 'Sans-Serif (Modern)',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: settings.isSerif ? 'serif' : 'sans-serif',
                  ),
                ),
                selected: true,
                onSelected: (_) => onToggleSerif(),
                selectedColor: textColor.withValues(alpha: 0.15),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: textColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required ReaderThemeMode mode,
    required String label,
    required Color bg,
    required Color fg,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onThemeChanged(mode),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? fg : fg.withValues(alpha: 0.3),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

