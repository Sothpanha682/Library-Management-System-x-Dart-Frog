import 'package:flutter/material.dart';

class CategoryStyle {
  const CategoryStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
}

class AppTheme {
  // Brand colors
  static const Color primaryBlue = Color(0xFF1E3A8A); // Royal Navy
  static const Color primaryBlueLight = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color secondaryTeal = Color(0xFF0D9488); // Scholarly Teal
  static const Color accentAmber = Color(0xFFD97706); // Amber Gold
  static const Color accentPurple = Color(0xFF7C3AED); // Modern Purple

  // Neutral Colors Light
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF1F5F9); // Slate 100
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color outlineLight = Color(0xFFE2E8F0); // Slate 200

  // Neutral Colors Dark
  static const Color backgroundDark = Color(0xFF0B1120); // Deep Slate Navy
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceContainerDark = Color(0xFF162032);
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color outlineDark = Color(0xFF334155); // Slate 700

  // Semantic Status Colors
  static const Color errorRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color infoBlue = Color(0xFF0284C7);
  static const Color warningOrange = Color(0xFFEA580C);

  // Backward-compatible getters
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDBEAFE),
      onPrimaryContainer: const Color(0xFF1E3A8A),
      secondary: secondaryTeal,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFCCFBF1),
      onSecondaryContainer: const Color(0xFF115E59),
      tertiary: accentAmber,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFEF3C7),
      onTertiaryContainer: const Color(0xFF78350F),
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF8FAFC),
      surfaceContainer: surfaceContainerLight,
      surfaceContainerHigh: const Color(0xFFE2E8F0),
      outline: const Color(0xFFCBD5E1),
      outlineVariant: outlineLight,
      error: errorRed,
      onError: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 1.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: textPrimaryLight,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineLight),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: errorRed, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        indicatorColor: primaryBlue.withValues(alpha: 0.12),
        elevation: 3,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryLight,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.transparent),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: outlineLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlueLight,
      primary: const Color(0xFF60A5FA), // Light Blue
      onPrimary: const Color(0xFF0F172A),
      primaryContainer: const Color(0xFF1E3A8A),
      onPrimaryContainer: const Color(0xFFDBEAFE),
      secondary: const Color(0xFF2DD4BF), // Light Teal
      onSecondary: const Color(0xFF042F2E),
      secondaryContainer: const Color(0xFF134E4A),
      onSecondaryContainer: const Color(0xFFCCFBF1),
      tertiary: const Color(0xFFFBBF24), // Light Amber
      onTertiary: const Color(0xFF451A03),
      tertiaryContainer: const Color(0xFF78350F),
      onTertiaryContainer: const Color(0xFFFEF3C7),
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      surfaceContainerLowest: const Color(0xFF080D1A),
      surfaceContainerLow: backgroundDark,
      surfaceContainer: surfaceContainerDark,
      surfaceContainerHigh: const Color(0xFF334155),
      outline: const Color(0xFF475569),
      outlineVariant: outlineDark,
      error: const Color(0xFFF87171),
      onError: Colors.black,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineDark),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF60A5FA),
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF60A5FA), width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFF3B82F6).withValues(alpha: 0.22),
        elevation: 3,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF60A5FA),
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryDark,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.transparent),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: outlineDark,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Category Colors Palette Helper
  static CategoryStyle getCategoryStyle(String category, {required bool isDark}) {
    switch (category.toLowerCase()) {
      case 'computer science':
        return CategoryStyle(
          backgroundColor: isDark
              ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
              : const Color(0xFFDBEAFE),
          textColor: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
          icon: Icons.computer_rounded,
        );
      case 'data science':
        return CategoryStyle(
          backgroundColor: isDark
              ? const Color(0xFF0F766E).withValues(alpha: 0.35)
              : const Color(0xFFCCFBF1),
          textColor: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
          icon: Icons.analytics_rounded,
        );
      case 'networking':
        return CategoryStyle(
          backgroundColor: isDark
              ? const Color(0xFF6B21A8).withValues(alpha: 0.35)
              : const Color(0xFFF3E8FF),
          textColor: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7E22CE),
          icon: Icons.hub_rounded,
        );
      case 'mathematics':
        return CategoryStyle(
          backgroundColor: isDark
              ? const Color(0xFF9A3412).withValues(alpha: 0.35)
              : const Color(0xFFFFEDD5),
          textColor: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
          icon: Icons.calculate_rounded,
        );
      case 'physics':
        return CategoryStyle(
          backgroundColor: isDark
              ? const Color(0xFF0369A1).withValues(alpha: 0.35)
              : const Color(0xFFE0F2FE),
          textColor: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7),
          icon: Icons.science_rounded,
        );
      case 'history':
        return CategoryStyle(
          backgroundColor: isDark
              ? const Color(0xFF854D0E).withValues(alpha: 0.35)
              : const Color(0xFFFEF3C7),
          textColor: isDark ? const Color(0xFFFDE047) : const Color(0xFFB45309),
          icon: Icons.history_edu_rounded,
        );
      case 'literature':
        return CategoryStyle(
          backgroundColor: isDark
              ? const Color(0xFF9F1239).withValues(alpha: 0.35)
              : const Color(0xFFFFE4E6),
          textColor: isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C),
          icon: Icons.menu_book_rounded,
        );
      default:
        return CategoryStyle(
          backgroundColor: isDark
              ? const Color(0xFF334155).withValues(alpha: 0.5)
              : const Color(0xFFF1F5F9),
          textColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          icon: Icons.bookmark_outline_rounded,
        );
    }
  }
}
