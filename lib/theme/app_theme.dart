import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Colors from the PRD (design system)
// ---------------------------------------------------------------------------
const Color primaryColor = Color(0xFF6C4DFF);
const Color secondaryColor = Color(0xFF8B7CFF);
const Color darkBackground = Color(0xFF0D0B18);
const Color darkSurface = Color(0xFF17142A);
const Color cardColor = Color(0xFF211D35);
const Color primaryText = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFFB7B4C7);
const Color ratingColor = Color(0xFFFFC857);
const Color errorColor = Color(0xFFFF5C6C);
const Color successColor = Color(0xFF4CD97B);

// ---------------------------------------------------------------------------
// Light mode colors (read from the Figma "Cinema Lumina" light screens)
// ---------------------------------------------------------------------------
const Color lightBackground = Color(0xFFF5F3FF);
const Color lightSurface = Color(0xFFFFFFFF);
const Color lightPrimaryText = Color(0xFF1B1830);
const Color lightSecondaryText = Color(0xFF6B6880);

// Thin border colors used around cards and chips.
const Color darkBorder = Color(0xFF2E2950);
const Color lightBorder = Color(0xFFE4E0F5);

/// Both themes are built by the same function so they stay consistent.
/// Widgets never hard-code backgrounds: they read them from Theme.of(context):
///   - scaffoldBackgroundColor -> page background
///   - colorScheme.surface     -> app bar / bottom bar
///   - cardColor               -> cards, chips, text fields
///   - hintColor               -> secondary (gray) text
///   - dividerColor            -> thin borders
ThemeData _buildTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  final Color background = isDark ? darkBackground : lightBackground;
  final Color surface = isDark ? darkSurface : lightSurface;
  final Color card = isDark ? cardColor : lightSurface;
  final Color text = isDark ? primaryText : lightPrimaryText;
  final Color hint = isDark ? secondaryText : lightSecondaryText;
  final Color border = isDark ? darkBorder : lightBorder;

  final ThemeData base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    fontFamily: 'Poppins',
  );

  return base.copyWith(
    scaffoldBackgroundColor: background,
    primaryColor: primaryColor,
    cardColor: card,
    hintColor: hint,
    dividerColor: border,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    ),
    textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
    iconTheme: IconThemeData(color: text),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primaryColor,
      unselectedItemColor: hint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: primaryColor),
  );
}

final ThemeData darkTheme = _buildTheme(Brightness.dark);
final ThemeData lightTheme = _buildTheme(Brightness.light);
