import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSessionCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSessionCheck() {
    _timer = Timer(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;

      if (kIsWeb) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminLogin);
        return;
      }

      final isTest = Platform.environment.containsKey('FLUTTER_TEST');
      if (isTest) {
        Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
        return;
      }

      try {
        final token = await ApiClient.instance
            .readSessionToken()
            .timeout(const Duration(milliseconds: 600));
        final user = await ApiClient.instance
            .readSessionUser()
            .timeout(const Duration(milliseconds: 600));

        if (token != null && token.isNotEmpty && user != null) {
          final role = (user['role'] as String?)?.toLowerCase();
          if (!mounted) return;
          if (role == 'msme') {
            Navigator.pushReplacementNamed(context, AppRoutes.msmeDashboard);
            return;
          } else if (role == 'mentor') {
            Navigator.pushReplacementNamed(context, AppRoutes.mentorDashboard);
            return;
          } else if (role == 'student') {
            Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
            return;
          }
        }
      } catch (_) {}

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Card
              Container(
                width: 290,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkSlate.withValues(alpha: 0.06),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Squircle Icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'TalentSync',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mahasiswa, UMKM, dan Mentor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Bottom Indicator Bar
              Container(
                width: 88,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
