import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController1;
  late AnimationController _pulseController2;
  late AnimationController _pulseController3;
  late AnimationController _floatController;
  late AnimationController _tapController;
  late AnimationController _fadeController;
  late AnimationController _logoController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _logoSlide;

  bool _showContinue = false;

  @override
  void initState() {
    super.initState();
    // 1. Initial Fade In
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    
    // 2. Logo Entrance Animation (Scale & Slide up)
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoSlide = Tween<double>(begin: 50.0, end: 0.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic));

    // Start entrance sequence
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoController.forward();
    });

    // 3. Start Rings after Logo lands
    _pulseController1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseController2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseController3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _pulseController1.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _pulseController2.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _pulseController3.repeat(reverse: true);
    });

    // Particle float
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _floatController.repeat();
    });

    // 4. Show "Continue" Elements
    _tapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showContinue = true;
        });
        _tapController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController1.dispose();
    _pulseController2.dispose();
    _pulseController3.dispose();
    _floatController.dispose();
    _tapController.dispose();
    _fadeController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_showContinue) {
              Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle Radial Ambient Background
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryTan.withValues(alpha: 0.09),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                    center: const FractionalOffset(0.5, 0.44),
                  ),
                ),
              ),

              // Center Composition
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 4),

                  // Animated Logo & Rings
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _logoSlide.value),
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Particles layer
                                _buildParticles(),

                                // Ring 3 (Outermost)
                                _buildRing(_pulseController3, 220, 0.95, 1.45, 0.25, 0.04, 1.5),
                                // Ring 2
                                _buildRing(_pulseController2, 172, 0.9, 1.3, 0.4, 0.08, 1.5),
                                // Ring 1 (Inner)
                                _buildRing(_pulseController1, 130, 0.85, 1.15, 0.6, 0.15, 2.0),

                                // Logo Card squircle dengan gradient
                                AnimatedBuilder(
                                  animation: _pulseController1,
                                  builder: (context, child) {
                                    final glow = _pulseController1.value * 14.0;
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Color(0xFFFFFDF8), Color(0xFFFFF3E0)],
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryTan.withValues(alpha: 0.30),
                                            blurRadius: 48,
                                            offset: const Offset(0, 20),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF4D332D).withValues(alpha: 0.12),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: AppColors.primaryTan.withValues(alpha: 0.08),
                                            blurRadius: 0,
                                            spreadRadius: glow,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.schedule_rounded,
                                          size: 40,
                                          color: AppColors.primaryTan,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Title (Also animates in)
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoController.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _logoController.value)),
                          child: const Column(
                            children: [
                              Text(
                                'TalentSync',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryTan,
                                  letterSpacing: -1.5,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Belajar • Berkarya • Berkembang',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tertiaryCaramel,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),

                  const SizedBox(height: 20),

                  // Animasi Loading Dots & Tap anywhere
                  AnimatedOpacity(
                    opacity: _showContinue ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _tapController,
                          builder: (context, child) {
                            final sweepingValue = _tapController.value * 4;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final distance = (sweepingValue - index).abs();
                                final opacity = (1.0 - (distance * 0.5)).clamp(0.2, 1.0);
                                final scale = (1.0 - (distance * 0.2)).clamp(0.8, 1.2);

                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTan.withValues(alpha: opacity),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  AnimatedOpacity(
                    opacity: _showContinue ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: AnimatedBuilder(
                      animation: _tapController,
                      builder: (context, child) {
                        final opacity = 0.5 + (_tapController.value * 0.5);
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            'Tap anywhere to continue',
                            style: TextStyle(
                              color: AppColors.darkCharcoal.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 56),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRing(AnimationController controller, double size, double minScale, double maxScale, double maxOp, double minOp, double borderWidth) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = minScale + (controller.value * (maxScale - minScale));
        final opacity = maxOp - (controller.value * (maxOp - minOp));

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryTan.withValues(alpha: opacity.clamp(0.0, 1.0)),
                width: borderWidth,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    final particles = [
      {'x': 20.0, 'y': 40.0, 'size': 6.0, 'color': AppColors.primaryTan, 'delay': 0.0},
      {'x': 200.0, 'y': 30.0, 'size': 4.0, 'color': AppColors.tertiaryCaramel, 'delay': 0.15},
      {'x': 40.0, 'y': 200.0, 'size': 5.0, 'color': AppColors.primaryTan, 'delay': 0.35},
      {'x': 210.0, 'y': 190.0, 'size': 3.0, 'color': AppColors.primaryTan.withValues(alpha: 0.5), 'delay': 0.60},
      {'x': 10.0, 'y': 120.0, 'size': 4.0, 'color': AppColors.tertiaryCaramel, 'delay': 0.25},
      {'x': 230.0, 'y': 130.0, 'size': 5.0, 'color': AppColors.primaryTan, 'delay': 0.70},
      {'x': 120.0, 'y': 10.0, 'size': 3.0, 'color': AppColors.primaryTan.withValues(alpha: 0.5), 'delay': 0.45},
      {'x': 130.0, 'y': 230.0, 'size': 4.0, 'color': AppColors.tertiaryCaramel, 'delay': 0.85},
    ];

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: particles.map((p) {
            double progress = (_floatController.value + (p['delay'] as double)) % 1.0;
            double opacity;
            if (progress < 0.5) {
              opacity = progress * 2.0;
            } else {
              opacity = 1.0 - ((progress - 0.5) * 2.0);
            }
            double yOffset = -25.0 * progress;

            return Positioned(
              left: p['x'] as double,
              top: (p['y'] as double) + 10,
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: Container(
                  width: p['size'] as double,
                  height: p['size'] as double,
                  decoration: BoxDecoration(
                    color: (p['color'] as Color).withValues(alpha: opacity.clamp(0.0, 1.0)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
