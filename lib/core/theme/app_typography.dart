import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge = GoogleFonts.orbitron(
    fontSize: 72,
    fontWeight: FontWeight.w700,
    color: AppColors.text1,
  );

  static TextStyle displayMedium = GoogleFonts.orbitron(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.text1,
  );

  static TextStyle headingLarge = GoogleFonts.rajdhani(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.text1,
  );

  static TextStyle headingMedium = GoogleFonts.rajdhani(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.text1,
  );

  static TextStyle headingSmall = GoogleFonts.rajdhani(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text1,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.text1,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text2,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.text3,
  );

  static TextStyle monospace = GoogleFonts.jetbrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.text1,
  );
}
