import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 13, 135, 236),
    ),
    fontFamily: 'OpenSansRegular',
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 90, 145, 170),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: const Color.fromARGB(255, 29, 28, 28),
        fontWeight: FontWeight.bold,
        fontFamily: 'OpenSansBold',
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 224, 133, 15),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'RobotoItalic', fontSize: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
