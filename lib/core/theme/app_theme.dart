import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(bool isDarkMode) {
    if (isDarkMode) return darkTheme();
    
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.green.shade700,
      colorScheme: ColorScheme.light(
        primary: Colors.green.shade700,
        secondary: Colors.green.shade300,
        tertiary: Colors.lime.shade400,
        surface: Colors.white,
        background: Colors.grey.shade50,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.green.shade400,
      colorScheme: ColorScheme.dark(
        primary: Colors.green.shade400,
        secondary: Colors.green.shade600,
        tertiary: Colors.lime.shade300,
        surface: Colors.grey.shade800,
        background: Colors.grey.shade900,
      ),
      scaffoldBackgroundColor: Colors.grey.shade900,
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );
  }
  
  static Color getStatusColor(String? disease, bool isCoffeeLeaf) {
    if (!isCoffeeLeaf) return Colors.orange;
    if (disease != null && disease.toLowerCase().contains("healthy")) return Colors.green;
    if (disease != null && disease.toLowerCase().contains("rust")) return Colors.red;
    return Colors.orange;
  }
}