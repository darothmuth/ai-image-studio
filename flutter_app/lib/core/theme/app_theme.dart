import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

/// The three color modes the app ships with, chosen from Settings.
enum AppColorMode { dark, light, pink }

/// A full set of semantic colors for one color mode. Every screen reads
/// colors from a [AppColorPalette] instance (via [ThemeProvider]) instead
/// of hardcoded constants, so switching mode re-colors the whole app.
class AppColorPalette {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Brightness brightness;

  const AppColorPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.brightness,
  });

  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get cardGradient => LinearGradient(
        colors: [surfaceVariant, surface],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppPalettes {
  AppPalettes._();

  static const dark = AppColorPalette(
    background: Color(0xFF0B0B14),
    surface: Color(0xFF15151F),
    surfaceVariant: Color(0xFF1E1E2C),
    primary: Color(0xFF8B5CF6),
    secondary: Color(0xFF22D3EE),
    accent: Color(0xFFEC4899),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFA1A1AA),
    error: Color(0xFFF87171),
    success: Color(0xFF34D399),
    brightness: Brightness.dark,
  );

  static const light = AppColorPalette(
    background: Color(0xFFF8F8FB),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEFEFF5),
    primary: Color(0xFF7C3AED),
    secondary: Color(0xFF0891B2),
    accent: Color(0xFFDB2777),
    textPrimary: Color(0xFF16161D),
    textSecondary: Color(0xFF6B7280),
    error: Color(0xFFDC2626),
    success: Color(0xFF059669),
    brightness: Brightness.light,
  );

  static const pink = AppColorPalette(
    background: Color(0xFFFFF0F6),
    surface: Color(0xFFFFE1EE),
    surfaceVariant: Color(0xFFFFC9DE),
    primary: Color(0xFFDB2777),
    secondary: Color(0xFFEC4899),
    accent: Color(0xFF9333EA),
    textPrimary: Color(0xFF3B0A24),
    textSecondary: Color(0xFF9D5C7C),
    error: Color(0xFFB91C1C),
    success: Color(0xFF0D9488),
    brightness: Brightness.light,
  );
}

/// Persists and broadcasts the user's chosen color mode across the app.
class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = "app_color_mode";
  AppColorMode _mode = AppColorMode.dark;

  AppColorMode get mode => _mode;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _mode = AppColorMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppColorMode.dark,
      );
      notifyListeners();
    }
  }

  Future<void> setMode(AppColorMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  AppColorPalette get palette {
    switch (_mode) {
      case AppColorMode.dark:
        return AppPalettes.dark;
      case AppColorMode.light:
        return AppPalettes.light;
      case AppColorMode.pink:
        return AppPalettes.pink;
    }
  }

  ThemeData get themeData {
    final p = palette;
    final base = ThemeData(brightness: p.brightness, useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      colorScheme: ColorScheme(
        brightness: p.brightness,
        primary: p.primary,
        onPrimary: Colors.white,
        secondary: p.secondary,
        onSecondary: Colors.white,
        error: p.error,
        onError: Colors.white,
        surface: p.surface,
        onSurface: p.textPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: p.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: p.surfaceVariant,
        selectedColor: p.primary,
        labelStyle: TextStyle(color: p.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

/// Convenience accessor used across all screens: `context.palette`.
/// Internally reads the current [ThemeProvider] via `package:provider`.
extension AppPaletteContext on BuildContext {
  AppColorPalette get palette => watch<ThemeProvider>().palette;
}
