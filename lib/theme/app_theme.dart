// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class AppTheme {
//   static const Color primaryColor = Color(0xFF006C5B); // Emerald Green
//   static const Color secondaryColor = Color(0xFF4D616C); // Slate
//   static const Color accentColor = Color(0xFFFFD700); // Gold for highlights
//
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: primaryColor,
//         primary: primaryColor,
//         secondary: secondaryColor,
//         primaryContainer: const Color(0xFFC8E6C9), // Light Mint
//         onPrimaryContainer: const Color(0xFF003D33), // Dark Text
//         surface: const Color(0xFFF8F9FA), // Very light grey surface
//       ),
//       scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Clean White background
//       textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
//       appBarTheme: AppBarTheme(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: false, // Left aligned for modern feel
//         titleTextStyle: GoogleFonts.outfit(
//           color: const Color(0xFF1A1C18),
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//         iconTheme: const IconThemeData(color: Color(0xFF1A1C18)),
//       ),
//       cardTheme: CardThemeData(
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         color: Colors.white,
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Full width or controlled margin
//       ),
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: const Color(0xFFA5F2E1), // Bright Mint
//         foregroundColor: const Color(0xFF004D40), // Dark Teal text
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), // Pill shape enforced
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: const Color(0xFFF5F5F5),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: primaryColor, width: 1.5),
//         ),
//         contentPadding: const EdgeInsets.all(20),
//         hintStyle: TextStyle(color: Colors.grey[400]),
//       ),
//     );
//   }
//
//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: primaryColor,
//         brightness: Brightness.dark,
//         surface: const Color(0xFF1A1C18),
//       ),
//       scaffoldBackgroundColor: const Color(0xFF111411),
//       textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: false,
//       ),
//       cardTheme: CardThemeData(
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         color: const Color(0xFF1E2320),
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: const Color(0xFF1E2320),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🌱 Brand Colors
  static const Color primaryColor = Color(0xFF006C5B); // Emerald
  static const Color secondaryColor = Color(0xFF4D616C); // Slate

  // ✅ Semantic colors
  static const Color successColor = Color(0xFF2E7D32);
  static const Color errorColor = Color(0xFFC62828);

  // =========================
  // 🌞 LIGHT THEME
  // =========================
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      background: const Color(0xFFFFFFFF),
      onBackground: const Color(0xFF1A1C18),
      surface: const Color(0xFFF8F9FA),
      onSurface: const Color(0xFF1A1C18),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,

      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: colorScheme.onBackground,
          displayColor: colorScheme.onBackground,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primary,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // =========================
  // 🌙 DARK THEME (FIXED)
  // =========================
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF4DB6AC), // Lighter emerald
      onPrimary: const Color(0xFF003D33),
      secondary: const Color(0xFF90A4AE),
      onSecondary: const Color(0xFF0F1F24),
      error: const Color(0xFFEF5350),
      onError: Colors.black,
      background: const Color(0xFF0F1210),
      onBackground: const Color(0xFFE6EDE9),
      surface: const Color(0xFF1A1F1C),
      onSurface: const Color(0xFFE6EDE9),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,

      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: colorScheme.onBackground,
          displayColor: colorScheme.onBackground,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2320),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primary,
        contentTextStyle: GoogleFonts.outfit(
          color: colorScheme.onPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
