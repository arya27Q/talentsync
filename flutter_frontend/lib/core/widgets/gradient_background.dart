import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Color(0xFFF9F6F0), // Very warm off-white center
            Color(0xFFEBE3D5), // Slightly darker edge simulating shadow/blur
          ],
        ),
      ),
      child: child,
    );
  }
}
