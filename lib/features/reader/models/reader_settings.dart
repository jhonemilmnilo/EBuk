import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ReaderThemeMode {
  light,
  sepia,
  dark,
}

extension ReaderThemeModeExtension on ReaderThemeMode {
  Color get backgroundColor {
    switch (this) {
      case ReaderThemeMode.light:
        return AppColors.readerLightBg;
      case ReaderThemeMode.sepia:
        return AppColors.readerSepiaBg;
      case ReaderThemeMode.dark:
        return AppColors.readerDarkBg;
    }
  }

  Color get textColor {
    switch (this) {
      case ReaderThemeMode.light:
        return AppColors.readerLightText;
      case ReaderThemeMode.sepia:
        return AppColors.readerSepiaText;
      case ReaderThemeMode.dark:
        return AppColors.readerDarkText;
    }
  }

  String get label {
    switch (this) {
      case ReaderThemeMode.light:
        return 'Light';
      case ReaderThemeMode.sepia:
        return 'Sepia';
      case ReaderThemeMode.dark:
        return 'Dark';
    }
  }
}

class ReaderSettings {
  final ReaderThemeMode? themeOverride; // null means auto adapt to app theme
  final double fontSize;
  final bool isSerif;

  const ReaderSettings({
    this.themeOverride,
    this.fontSize = 16.0,
    this.isSerif = true,
  });

  ReaderThemeMode effectiveTheme(Brightness appBrightness) {
    if (themeOverride != null) {
      return themeOverride!;
    }
    return appBrightness == Brightness.dark
        ? ReaderThemeMode.dark
        : ReaderThemeMode.light;
  }

  ReaderSettings copyWith({
    ReaderThemeMode? Function()? themeOverride,
    double? fontSize,
    bool? isSerif,
  }) {
    return ReaderSettings(
      themeOverride:
          themeOverride != null ? themeOverride() : this.themeOverride,
      fontSize: fontSize ?? this.fontSize,
      isSerif: isSerif ?? this.isSerif,
    );
  }
}

