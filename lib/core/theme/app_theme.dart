import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.display,
      ),
      textTheme: const TextTheme(
        headlineMedium: AppTypography.display,
        titleMedium: AppTypography.title,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: AppTypography.display.copyWith(color: AppColors.darkText),
        titleMedium: AppTypography.title.copyWith(color: AppColors.darkText),
        bodyMedium: AppTypography.body.copyWith(color: AppColors.darkText),
        bodySmall: AppTypography.caption.copyWith(color: AppColors.darkTextMuted),
      ),
    );
  }
}
