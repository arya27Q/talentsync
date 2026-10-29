import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  void _showSuccessModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        final opacity = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        
        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.green, size: 32),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Application Sent!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(color: Color(0xFF424242), fontSize: 13, height: 1.5),
                        children: [
                          TextSpan(text: 'Your application for '),
                          TextSpan(
                            text: 'Redesign E-commerce Landing Page ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                          ),
                          TextSpan(text: 'has been submitted.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The MSME will review and contact you within 48 hours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF616161), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warmOffWhite,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Reward', style: TextStyle(color: Color(0xFF616161), fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB88656),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('3 TC', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Status', style: TextStyle(color: Color(0xFF616161), fontSize: 12, fontWeight: FontWeight.w500)),
                              SizedBox(height: 4),
                              Text('Under Review', style: TextStyle(color: Color(0xFFE64A19), fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB88656),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Close',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warmOffWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.darkBrown,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isPremium = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        isPremium
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB88656),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              )
            : Text(value, style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, color: Color(0xFFB88656), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  // Floating Header
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.warmOffWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.keyboard_arrow_left_rounded, color: AppColors.darkBrown),
                          ),
                        ),
                        const Text(
                          'Project Detail',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                        ),
                        const Icon(Icons.local_activity_rounded, color: Color(0xFFEF5350)),
                      ],
                    ),
                  ),

                  // Main Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Info
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8C5E3C),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text('BN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Batik Nusantara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkBrown)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 14),
                                          SizedBox(width: 4),
                                          Text('4.9', style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('12 projects posted', style: TextStyle(color: Color(0xFF616161), fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Redesign E-commerce Landing Page',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkBrown,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildTag('Web Dev'),
                            _buildTag('UI/UX'),
                            _buildTag('Figma'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('Reward', '3 TC', isPremium: true),
                            _buildInfoColumn('Deadline', '3 days'),
                            _buildInfoColumn('Type', 'Remote'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Project Description',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "We need a talented student to redesign our e-commerce landing page. The current design is outdated and we want a modern, conversion-focused UI using Figma and React. You'll collaborate directly with our marketing team.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Requirements Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Requirements',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                        ),
                        const SizedBox(height: 16),
                        _buildRequirement('Proficiency in Figma or similar tools'),
                        _buildRequirement('Understanding of e-commerce UX patterns'),
                        _buildRequirement('Basic React knowledge'),
                        _buildRequirement('Ability to meet deadlines'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Applicants
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('7 students applied', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
                        SizedBox(
                          width: 80,
                          height: 32,
                          child: Stack(
                            children: [
                              Positioned(
                                right: 0,
                                child: _buildAvatar('DP', const Color(0xFFBCAAA4)),
                              ),
                              Positioned(
                                right: 20,
                                child: _buildAvatar('BS', const Color(0xFF8D6E63)),
                              ),
                              Positioned(
                                right: 40,
                                child: _buildAvatar('AR', const Color(0xFFA1887F)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Apply Button Fixed at Bottom
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: GestureDetector(
              onTap: () => _showSuccessModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB88656), Color(0xFF8C5E3C)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8C5E3C).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🚀', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Apply for 3 TC',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String initials, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
