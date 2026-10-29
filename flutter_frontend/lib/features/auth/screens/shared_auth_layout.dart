import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';

class SharedAuthLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SharedAuthLayout({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Floating Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: AppColors.floatingDecoration.copyWith(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warmOffWhite,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: AppColors.darkBrown, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildFloatingTextField(String hint, IconData icon, {bool isPassword = false}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: AppColors.floatingDecoration,
    child: TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        prefixIcon: Icon(icon, color: AppColors.tertiaryCaramel),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    ),
  );
}

Widget buildElevatedButton(String text, VoidCallback onPressed) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryTan.withValues(alpha: 0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryTan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );
}

Widget buildOutlinedButton(String text, VoidCallback onPressed) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryTan,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: AppColors.primaryTan, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );
}

Widget buildUploadButton(String text, IconData icon, VoidCallback onPressed) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.warmOffWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryTan, width: 2, style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTan.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryTan, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.primaryTan,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildAuthFooter(String text, String actionText, VoidCallback onActionTap) {
  return Padding(
    padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primaryTan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
