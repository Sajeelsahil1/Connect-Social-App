import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- App Colors ---
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1E1E1E);
const Color primaryColor = Color(0xFF9C27B0); // Deep Purple
const Color accentColor = Color(0xFFBB86FC); // Light Purple Accent
const Color textColor = Colors.white;
const Color subtitleColor = Colors.grey;

// ---
// --- NEW LIGHT THEME ---
// ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey[100],
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: accentColor,
    surface: Colors.white, // <-- Replaced 'background'
    onSurface: Colors.black, // <-- Replaced 'onBackground'
    background: Colors.grey[100]!,
    onBackground: Colors.black,
  ),

  textTheme: GoogleFonts.poppinsTextTheme(
    ThemeData.light().textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 1,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
    iconTheme: const IconThemeData(color: Colors.black),
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200],
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    floatingLabelStyle: const TextStyle(color: primaryColor),
    labelStyle: const TextStyle(color: Colors.grey),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),

  // --- 'chatTheme' REMOVED ---
);

// ---
// --- EXISTING DARK THEME ---
// ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBackground,
  primaryColor: primaryColor,
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,
    secondary: accentColor,
    surface: cardColor, // <-- Replaced 'background'
    onSurface: textColor, // <-- Replaced 'onBackground'
  ),

  textTheme: GoogleFonts.poppinsTextTheme(
    ThemeData.dark().textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: darkBackground,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  cardTheme: CardThemeData(
    color: cardColor,
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: cardColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    floatingLabelStyle: const TextStyle(color: primaryColor),
    labelStyle: const TextStyle(color: subtitleColor),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: darkBackground,
    selectedItemColor: primaryColor,
    unselectedItemColor: subtitleColor,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),

  // --- 'chatTheme' REMOVED ---
);
