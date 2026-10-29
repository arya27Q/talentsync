import 'package:flutter/material.dart';
import 'shared_auth_layout.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class MsmeAuthScreen extends StatelessWidget {
  const MsmeAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedAuthLayout(
      title: 'Business Portal',
      children: [
        buildFloatingTextField('Business Email', Icons.storefront_outlined),
        buildFloatingTextField('Password', Icons.lock_outline, isPassword: true),
        const SizedBox(height: 24),
        buildElevatedButton('Sign In', () {}),

        buildAuthFooter('Belum punya akun?', 'Daftar di sini', () {
          Navigator.pushNamed(context, AppRoutes.msmeRegister);
        }),
      ],
    );
  }
}
