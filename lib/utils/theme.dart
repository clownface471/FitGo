import 'package:flutter/material.dart';

// Palet Warna 
const Color primaryColor = Color(0xFFD4FF40); // Hijau Neon
const Color darkBackgroundColor = Color(0xFF1C1C1E); // Hitam/Abu-abu gelap
const Color darkCardColor = Color(0xFF2C2C2E);
const Color lightTextColor = Colors.white;
const Color darkTextColor = Colors.black;

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackgroundColor,
    primaryColor: primaryColor,
    
    // Tema untuk Input/TextField
    inputDecorationTheme: InputDecorationTheme( 
      filled: true,
      fillColor: darkCardColor,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: lightTextColor, fontSize: 24, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: lightTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: darkTextColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: lightTextColor),
      headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: lightTextColor),
      bodyLarge: TextStyle(fontSize: 16.0, color: lightTextColor),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
    ),
  );
}