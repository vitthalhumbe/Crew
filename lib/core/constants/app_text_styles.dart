import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle titleMain = TextStyle(
    fontSize: 30,
    fontFamily: "Inter",
    fontWeight: FontWeight.bold,
    color: AppColors.textLight
  );

  static const TextStyle titleSecond = TextStyle(
    fontSize: 24,
    fontFamily: "Inter",
    fontWeight: FontWeight.w600,
    color: AppColors.textLight
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20,
    fontFamily: "Inter",
    fontWeight: FontWeight.w200,
    color: AppColors.textLight
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 16,
    fontFamily: "Inter",
    fontWeight: FontWeight.normal,
    color: AppColors.textLight
  );
}