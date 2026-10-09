import 'package:flutter/material.dart';
import '../constants/colors.dart';

ThemeData darkGlassTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violetAccent,
      brightness: Brightness.dark,
      background: AppColors.deepNavy,
      surface: AppColors.darkSurface,
    ),
    scaffoldBackgroundColor: AppColors.deepNavy,
    cardTheme: CardTheme(
      color: AppColors.darkSurface.withOpacity(0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.glassBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textPrimaryDark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface.withOpacity(0.8),
      selectedItemColor: AppColors.violetAccent,
      unselectedItemColor: AppColors.textSecondaryDark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
      bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
      titleLarge: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold, fontSize: 24),
    ),
  );
}

ThemeData lightGlassTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violetAccent,
      brightness: Brightness.light,
      background: AppColors.pearl,
      surface: AppColors.lightSurface,
    ),
    scaffoldBackgroundColor: AppColors.pearl,
    cardTheme: CardTheme(
      color: AppColors.lightSurface.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.glassBorder.withOpacity(0.5), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textPrimaryLight,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.violetAccent,
      unselectedItemColor: AppColors.textSecondaryLight,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
      bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
      titleLarge: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold, fontSize: 24),
    ),
  );
}
