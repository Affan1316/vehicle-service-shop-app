import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static const List<BoxShadow> glowOrange = [
    BoxShadow(
      color: AppColors.orange,
      offset: Offset(0, 0),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> glowTeal = [
    BoxShadow(
      color: AppColors.teal,
      offset: Offset(0, 0),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> glowRed = [
    BoxShadow(
      color: AppColors.red,
      offset: Offset(0, 0),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];
}
