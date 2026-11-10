import 'package:flutter/material.dart';

/// Design tokens for EBuk's vintage aesthetic palette.
/// Sourced strictly from the approved UI spec.
abstract class AppColors {
  // Primary / Accent (Buttons, active states, progress, key highlights)
  static const Color primary = Color(0xFF590907); // Vintage Maroon

  // Background / Canvas (Warm paper tone)
  static const Color background = Color(0xFFE8D2B5); // Beige
  static const Color surface = Color(0xFFE8D2B5);

  // Secondary / Neutral (Chips, search bar background, borders)
  static const Color neutral = Color(0xFFA5A79B); // Muted Olive Gray
  static const Color neutralLight = Color(0xFFD3D5CA); // Soft tint for containers

  // Typography Colors
  static const Color textDark = Color(0xFF2C0403); // Deep contrast maroon/black on beige
  static const Color textMuted = Color(0xFF6B4E4D); // Secondary text
  static const Color textOnPrimary = Color(0xFFE8D2B5); // Beige text on maroon buttons

  // Reader Themes
  static const Color readerLightBg = Color(0xFFE8D2B5);
  static const Color readerLightText = Color(0xFF2C0403);

  static const Color readerSepiaBg = Color(0xFFDFCAAC);
  static const Color readerSepiaText = Color(0xFF2E1C0C);

  static const Color readerDarkBg = Color(0xFF1E0E0E);
  static const Color readerDarkText = Color(0xFFE8D2B5);
}

