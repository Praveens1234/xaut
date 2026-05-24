import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Gold palette
  static const Color goldPrimary = Color(0xFFFFD700);
  static const Color goldSecondary = Color(0xFFFFC107);
  static const Color goldAccent = Color(0xFFFFE57F);
  static const Color goldDark = Color(0xFFB8860B);

  // Dark backgrounds
  static const Color darkBg = Color(0xFF08080E);
  static const Color darkSurface = Color(0xFF0D0D18);
  static const Color darkCard = Color(0xFF12121F);
  static const Color darkCardElevated = Color(0xFF191928);
  static const Color darkBorder = Color(0xFF252535);
  static const Color darkDivider = Color(0xFF1E1E2E);

  // Price colours
  static const Color priceUp = Color(0xFF00E676);
  static const Color priceDown = Color(0xFFFF5252);
  static const Color priceNeutral = Color(0xFF9E9EBF);

  // Light backgrounds
  static const Color lightBg = Color(0xFFF5F5F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F0F5);

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.dmSans(
        fontSize: 57, fontWeight: FontWeight.w400, color: textColor,
      ),
      displayMedium: GoogleFonts.dmSans(
        fontSize: 45, fontWeight: FontWeight.w400, color: textColor,
      ),
      displaySmall: GoogleFonts.dmSans(
        fontSize: 36, fontWeight: FontWeight.w500, color: textColor,
      ),
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 32, fontWeight: FontWeight.w700, color: textColor,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 28, fontWeight: FontWeight.w700, color: textColor,
      ),
      headlineSmall: GoogleFonts.dmSans(
        fontSize: 24, fontWeight: FontWeight.w600, color: textColor,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 22, fontWeight: FontWeight.w600, color: textColor,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: textColor,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: textColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w400, color: textColor,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: textColor,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: textColor,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: textColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w600, color: textColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w500, color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData get darkTheme {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: goldPrimary,
      onPrimary: Color(0xFF1A1000),
      primaryContainer: Color(0xFF3D2A00),
      onPrimaryContainer: goldAccent,
      secondary: goldSecondary,
      onSecondary: Color(0xFF1A1000),
      secondaryContainer: Color(0xFF2D2000),
      onSecondaryContainer: Color(0xFFFFDF99),
      tertiary: priceUp,
      onTertiary: Color(0xFF00200D),
      tertiaryContainer: Color(0xFF003519),
      onTertiaryContainer: Color(0xFF6EFFA9),
      error: priceDown,
      onError: Color(0xFF3A0000),
      errorContainer: Color(0xFF5E0000),
      onErrorContainer: Color(0xFFFFB3B3),
      surface: darkSurface,
      onSurface: Color(0xFFE8E8F0),
      surfaceContainerHighest: darkCardElevated,
      onSurfaceVariant: Color(0xFF9898B8),
      outline: darkBorder,
      outlineVariant: darkDivider,
      shadow: Colors.black,
      scrim: Color(0xCC000000),
      inverseSurface: Color(0xFFE8E8F0),
      onInverseSurface: darkBg,
      inversePrimary: goldDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      textTheme: _buildTextTheme(const Color(0xFFE8E8F0)),

      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: const CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: darkBorder),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkCardElevated,
        selectedColor: Color.fromRGBO(255, 215, 0, 0.2),
        side: const BorderSide(color: darkBorder),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldPrimary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9898B8)),
        hintStyle: const TextStyle(color: Color(0xFF5A5A7A)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: const Color(0xFF1A1000),
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldPrimary,
          side: const BorderSide(color: goldPrimary),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) return goldPrimary;
            return const Color(0xFF5A5A7A);
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Color.fromRGBO(255, 215, 0, 0.3);
            }
            return darkCardElevated;
          },
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: Color.fromRGBO(255, 215, 0, 0.2),
        iconTheme: const WidgetStatePropertyAll<IconThemeData>(
          IconThemeData(size: 22),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: goldPrimary,
              );
            }
            return GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9898B8),
            );
          },
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        modalBarrierColor: Color(0xCC000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCardElevated,
        contentTextStyle: GoogleFonts.dmSans(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: goldDark,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFF3CD),
      onPrimaryContainer: Color(0xFF3D2A00),
      secondary: goldSecondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFF8E1),
      onSecondaryContainer: Color(0xFF3D2A00),
      tertiary: Color(0xFF00A651),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD0F5E3),
      onTertiaryContainer: Color(0xFF003519),
      error: Color(0xFFD32F2F),
      onError: Colors.white,
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFF3A0000),
      surface: lightSurface,
      onSurface: Color(0xFF1A1A2E),
      surfaceContainerHighest: lightCard,
      onSurfaceVariant: Color(0xFF5A5A7A),
      outline: Color(0xFFDDDDF0),
      outlineVariant: Color(0xFFEEEEF5),
      shadow: Color(0x40000000),
      scrim: Color(0x8A000000),
      inverseSurface: darkSurface,
      onInverseSurface: Colors.white,
      inversePrimary: goldPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBg,
      textTheme: _buildTextTheme(const Color(0xFF1A1A2E)),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      cardTheme: const CardTheme(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFEEEEF5)),
        ),
      ),
    );
  }
}
