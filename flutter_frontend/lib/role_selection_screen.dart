import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppColors.floatingDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmOffWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: AppColors.primaryTan),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.tertiaryCaramel,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryTan),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.splash);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to TalentSync',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.tertiaryCaramel,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose Your Path',
                style: TextStyle(
                  fontSize: 34,
                  color: AppColors.darkBrown,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 50),
              _buildRoleCard(
                context,
                'Mahasiswa (Student)',
                Icons.school_rounded,
                () => Navigator.pushNamed(context, AppRoutes.studentAuth),
              ),
              _buildRoleCard(
                context,
                'UMKM (Business)',
                Icons.storefront_rounded,
                () => Navigator.pushNamed(context, AppRoutes.msmeAuth),
              ),
              _buildRoleCard(
                context,
                'Mentor (Professional)',
                Icons.work_rounded,
                () => Navigator.pushNamed(context, AppRoutes.mentorAuth),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
