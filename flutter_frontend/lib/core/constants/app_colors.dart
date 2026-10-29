import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryTan = Color(0xFFB88656);
  static const Color darkBrown = Color(0xFF4D332D);
  static const Color tertiaryCaramel = Color(0xFF8C5E3C);
  static const Color darkCharcoal = Color(0xFF2D2926);
  static const Color warmOffWhite = Color(0xFFF9F6F0);
  
  static BoxDecoration floatingDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: darkCharcoal.withValues(alpha: 0.06),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
