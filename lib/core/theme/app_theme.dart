import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {

  // white / light theme
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary, 
      secondary: AppColors.accent
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textLight),
      titleTextStyle: TextStyle(
        color:AppColors.textLight,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardColor: AppColors.cardLight,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
    ),
  );




  // dark theme
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary, 
      secondary: AppColors.accent
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textDark),
      titleTextStyle: TextStyle(
        color:AppColors.textDark,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardColor: AppColors.cardLight,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
    ),
  );

}
