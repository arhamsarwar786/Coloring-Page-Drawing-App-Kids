import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

abstract final class AppTheme {
  // ── Gradient helpers (logo-branded) ────────────────────────────────────────

  /// Primary CTA gradient — blue → purple (logo "Craft" → splat)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.blue, AppColors.purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary / fun gradient — pink → orange (logo "Kids" → splat)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [AppColors.pink, AppColors.orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient — yellow → orange (logo "Play" wordmark)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [AppColors.yellow, AppColors.orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient — clean white surface with a warm-blue tint
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FF), Color(0xFFFFFBF5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Main theme ─────────────────────────────────────────────────────────────

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Regular',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        // Primary = Royal Blue (logo "Craft")
        primary: AppColors.blue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFD6E4FF),
        onPrimaryContainer: AppColors.ink,
        // Secondary = Hot Pink (logo "Kids")
        secondary: AppColors.pink,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFFFD6E8),
        onSecondaryContainer: AppColors.ink,
        // Tertiary = Sunshine Yellow (logo "Play")
        tertiary: AppColors.yellow,
        onTertiary: AppColors.ink,
        tertiaryContainer: const Color(0xFFFFF3B0),
        onTertiaryContainer: AppColors.ink,
        // Error
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
        errorContainer: const Color(0xFFFFDAD6),
        onErrorContainer: AppColors.ink,
        // Surfaces
        surface: AppColors.shell,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.card,
        onSurfaceVariant: AppColors.warmGrey,
        // Outline
        outline: AppColors.blue.withValues(alpha: 0.25),
        outlineVariant: AppColors.blue.withValues(alpha: 0.12),
        // Inverse
        inverseSurface: AppColors.ink,
        onInverseSurface: Colors.white,
        inversePrimary: AppColors.yellow,
        // Shadow & scrim
        shadow: AppColors.ink.withValues(alpha: 0.18),
        scrim: AppColors.ink.withValues(alpha: 0.55),
      ),
    );

    const fontFamily = 'Poppins';

    final textTheme = base.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
        letterSpacing: 0,
      ),
      displayMedium: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
      headlineLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: 0,
      ),
      headlineMedium: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      headlineSmall: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleSmall: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGrey,
        height: 1.5,
      ),
      bodySmall: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGrey,
      ),
      labelLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.4,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.shell,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),

      // ── Buttons ─────────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pink,
          foregroundColor: Colors.white,
          shadowColor: AppColors.pink.withValues(alpha: 0.4),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.blue,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.blue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.blue),
        ),
      ),

      // ── Cards ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: AppColors.blue.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.blue.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
      ),

      // ── Chips ───────────────────────────────────────────────────────────────
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.blue.withValues(alpha: 0.15),
        labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: AppColors.blue.withValues(alpha: 0.18)),
      ),

      // ── Input decoration ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.blue.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.blue.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium,
      ),

      // ── Bottom navigation ───────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.warmGrey,
        selectedLabelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.blue,
        ),
        unselectedLabelStyle: textTheme.bodySmall,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Dialog ──────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.shell,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Progress indicator ───────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.blue,
        linearTrackColor: AppColors.card,
        circularTrackColor: AppColors.card,
      ),

      // ── Icons ────────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.ink, size: 24),
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),

      // ── Divider ──────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.blue.withValues(alpha: 0.10),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
