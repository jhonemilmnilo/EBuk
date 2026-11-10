import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reader_settings.dart';

final readerSettingsControllerProvider =
    StateNotifierProvider<ReaderSettingsController, ReaderSettings>((ref) {
  return ReaderSettingsController();
});

class ReaderSettingsController extends StateNotifier<ReaderSettings> {
  static const _keyTheme = 'reader_theme_override';
  static const _keyFontSize = 'reader_font_size';
  static const _keyIsSerif = 'reader_is_serif';

  ReaderSettingsController() : super(const ReaderSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_keyTheme);
    final fontSize = prefs.getDouble(_keyFontSize) ?? 16.0;
    final isSerif = prefs.getBool(_keyIsSerif) ?? true;

    ReaderThemeMode? themeOverride;
    if (themeStr != null) {
      if (themeStr == 'light') themeOverride = ReaderThemeMode.light;
      if (themeStr == 'sepia') themeOverride = ReaderThemeMode.sepia;
      if (themeStr == 'dark') themeOverride = ReaderThemeMode.dark;
    }

    state = ReaderSettings(
      themeOverride: themeOverride,
      fontSize: fontSize,
      isSerif: isSerif,
    );
  }

  Future<void> setTheme(ReaderThemeMode? mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == null) {
      await prefs.remove(_keyTheme);
    } else {
      await prefs.setString(_keyTheme, mode.name);
    }
    state = state.copyWith(themeOverride: () => mode);
  }

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(12.0, 28.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, clamped);
    state = state.copyWith(fontSize: clamped);
  }

  Future<void> toggleSerif() async {
    final newSerif = !state.isSerif;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsSerif, newSerif);
    state = state.copyWith(isSerif: newSerif);
  }
}

