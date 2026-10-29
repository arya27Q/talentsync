import 'package:flutter/material.dart';

import 'shared_auth_layout.dart';

import 'package:skillswap_frontend/core/routes/app_routes.dart';

class StudentAuthScreen extends StatelessWidget {
  const StudentAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedAuthLayout(
      title: 'Student Portal',
      children: [
        buildFloatingTextField('Email', Icons.email_outlined),
        buildFloatingTextField(
          'Password',
          Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        buildElevatedButton('Sign In', () { Navigator.pushReplacementNamed(context, AppRoutes.studentOnboarding); }),
        const SizedBox(height: 16),

        buildAuthFooter('Belum punya akun?', 'Daftar di sini', () {
          Navigator.pushNamed(context, AppRoutes.studentRegister);
        }),
      ],
    );
  }
}
