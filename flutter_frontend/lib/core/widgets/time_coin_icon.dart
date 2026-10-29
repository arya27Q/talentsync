import 'package:flutter/material.dart';

/// Modern, custom-crafted TimeCoin (TC) token icon.
/// Blends metallic gold gradients, inner bevel, and a stylized Time/Coin glyph
/// to create a rare, premium, and futuristic currency symbol for TalentSync.
class TimeCoinIcon extends StatelessWidget {
  final double size;
  final bool showGlow;
  final Color? glowColor;

  const TimeCoinIcon({
    super.key,
    this.size = 24.0,
    this.showGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? const Color(0xFFFFB300);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.95,
          colors: [
            Color(0xFFFFF6D6), // highlight
            Color(0xFFFFD54F), // amber gold
            Color(0xFFFFA000), // rich gold
            Color(0xFFD47A00), // deep bronze rim
          ],
          stops: [0.0, 0.35, 0.75, 1.0],
        ),
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: effectiveGlowColor.withValues(alpha: 0.45),
              blurRadius: size * 0.45,
              spreadRadius: size * 0.05,
              offset: Offset(0, size * 0.1),
            ),
          BoxShadow(
            color: const Color(0xFF4D332D).withValues(alpha: 0.18),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.08),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: (size * 0.05).clamp(1.0, 2.5),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner concentric rim
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFF8E1).withValues(alpha: 0.55),
                width: (size * 0.035).clamp(0.6, 1.5),
              ),
            ),
          ),
          // Stylized Time + Coin central motif (Hourglass / Token spark)
          if (size >= 20)
            Icon(
              Icons.hourglass_top_rounded,
              size: size * 0.52,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: const Color(0xFF9E5C00).withValues(alpha: 0.5),
                  blurRadius: 2.0,
                  offset: const Offset(0, 1),
                ),
              ],
            )
          else
            // For tiny sizes (<20px, like in chips/pills), a clean spark/token
            Icon(
              Icons.token_rounded,
              size: size * 0.60,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}

