import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryYellowTop = Color(0xFFF9D96A);
  static const Color primaryYellowBottom = Color(0xFFF6EAB8);
  
  // Gold Colors
  static const Color goldPrimary = Color(0xFFC9A45C);
  static const Color goldDark = Color(0xFF8C6B32);
  static const Color goldLight = Color(0xFFE9C882);
  
  // Text Colors
  static const Color textDarkBrown = Color(0xFF4E3B1F);
  static const Color darkGrayText = Color(0xFF2A2A2A);
  static const Color white = Color(0xFFFFFFFF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryYellowTop, primaryYellowBottom],
  );
}