import 'package:flutter/material.dart';

class AppTheme {
  // Warna Utama (Berdasarkan diskusi kita)
  static const Color primaryColor = Color(0xFFFFC107); // Amber
  static const Color secondaryColor = Color(0xFFFFA000); // Darker Amber

  // Warna Background (Mode Gelap Elegan)
  static const Color darkBackground = Color(0xFF1E1E1E); // Very Dark Gray
  static const Color cardColor = Color(0xFF2C2C2C); // Deep Gray

  // Warna Teks
  static const Color textPrimary = Color(0xFFF5F5F5); // White Soft
  static const Color textSecondary = Color(0xFFBDBDBD); // Grey Text

  // Tema Aplikasi Global
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      cardColor: cardColor,

      // Mengatur warna AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Mengatur warna Tombol
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black, // Teks tombol jadi hitam biar kontras
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
