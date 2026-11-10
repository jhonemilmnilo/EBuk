import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
}

