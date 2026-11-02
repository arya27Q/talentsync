import 'package:flutter/material.dart';

class AppColors {
  // Trust & Growth Palette (Official Opsi 1)
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color secondarySlate = Color(0xFF64748B);
  static const Color canvasWhite = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;
  static const Color accentAmberGold = Color(0xFFF59E0B);
  static const Color borderSlate = Color(0xFFE2E8F0);
  static const Color lightBlueSurface = Color(0xFFEFF6FF);

  // Warm Heritage Palette (Fallback / Legacy support)
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
        color: const Color(0xFF0F172A).withValues(alpha: 0.06),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
