import 'package:flutter/material.dart';

/// Slate / indigo / violet — tuned for a premium news reader.
abstract final class NewsTheme {
  static const Color _slateBg = Color(0xFF0f172a);
  static const Color _slateSurface = Color(0xFF1e293b);
  static const Color _indigo = Color(0xFF6366f1);
  static const Color _violet = Color(0xFF8b5cf6);

  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor: _indigo,
      brightness: Brightness.dark,
      primary: _indigo,
      secondary: _violet,
      surface: _slateSurface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: base,
      scaffoldBackgroundColor: _slateBg,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFe2e8f0),
      ),
      cardTheme: CardThemeData(
        color: _slateSurface.withValues(alpha: 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _slateSurface.withValues(alpha: 0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: _indigo,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: base,
      scaffoldBackgroundColor: const Color(0xFFf8fafc),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static LinearGradient heroGradient(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark) {
      return const LinearGradient(
        colors: [Color(0xFF312e81), Color(0xFF0f172a), Color(0xFF1e1b4b)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [
        const Color(0xFFe0e7ff),
        Theme.of(context).colorScheme.surface,
        const Color(0xFFede9fe),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
