import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebuk/core/theme/app_colors.dart';
import 'package:ebuk/features/reader/controllers/reader_settings_controller.dart';
import 'package:ebuk/features/reader/models/reader_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ReaderThemeMode & ReaderSettings', () {
    test('theme colors match EBuk vintage palette', () {
      expect(ReaderThemeMode.light.backgroundColor, AppColors.readerLightBg);
      expect(ReaderThemeMode.light.textColor, AppColors.readerLightText);

      expect(ReaderThemeMode.sepia.backgroundColor, AppColors.readerSepiaBg);
      expect(ReaderThemeMode.sepia.textColor, AppColors.readerSepiaText);

      expect(ReaderThemeMode.dark.backgroundColor, AppColors.readerDarkBg);
      expect(ReaderThemeMode.dark.textColor, AppColors.readerDarkText);
    });

    test('effectiveTheme adapts to system app brightness when override is null', () {
      const settings = ReaderSettings();

      // In dark mode, adapts to dark
      expect(settings.effectiveTheme(Brightness.dark), ReaderThemeMode.dark);

      // In light mode, adapts to light
      expect(settings.effectiveTheme(Brightness.light), ReaderThemeMode.light);
    });

    test('effectiveTheme honors user theme override regardless of app brightness', () {
      const settings = ReaderSettings(themeOverride: ReaderThemeMode.sepia);

      expect(settings.effectiveTheme(Brightness.dark), ReaderThemeMode.sepia);
      expect(settings.effectiveTheme(Brightness.light), ReaderThemeMode.sepia);
    });

    test('ReaderSettingsController updates theme and font size within bounds', () async {
      final controller = ReaderSettingsController();

      await controller.setTheme(ReaderThemeMode.dark);
      expect(controller.state.themeOverride, ReaderThemeMode.dark);

      await controller.setFontSize(35.0); // should clamp to 28
      expect(controller.state.fontSize, 28.0);

      await controller.setFontSize(10.0); // should clamp to 12
      expect(controller.state.fontSize, 12.0);

      await controller.toggleSerif();
      expect(controller.state.isSerif, isFalse);
    });
  });
}

