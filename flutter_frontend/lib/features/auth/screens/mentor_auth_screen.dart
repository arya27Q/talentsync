import 'package:flutter/material.dart';

import 'shared_auth_layout.dart';

import 'package:skillswap_frontend/core/routes/app_routes.dart';

class MentorAuthScreen extends StatelessWidget {
  const MentorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedAuthLayout(
      title: 'Mentor Portal',
      children: [
        buildFloatingTextField('Email', Icons.email_outlined),
        buildFloatingTextField(
          'Password',
          Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        buildElevatedButton('Sign In', () {}),

        buildAuthFooter('Belum punya akun?', 'Daftar di sini', () {
          Navigator.pushNamed(context, AppRoutes.mentorRegister);
        }),
      ],
    );
  }
}
