import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
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
}

