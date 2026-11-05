import 'package:flutter/material.dart';

import 'shared_auth_layout.dart';

import 'package:flutter_frontend/core/routes/app_routes.dart';

class StudentRegisterScreen extends StatelessWidget {
  const StudentRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedAuthLayout(
      title: 'Daftar Mahasiswa',
      children: [
        buildFloatingTextField('Nama Lengkap', Icons.person_outline_rounded),
        buildFloatingTextField('Email Kampus / Pribadi', Icons.email_rounded),
        buildFloatingTextField(
          'NIM (Nomor Induk Mahasiswa)',
          Icons.badge_rounded,
        ),
        buildFloatingTextField(
          'Password',
          Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 10),
        buildUploadButton('Unggah Foto KTM', Icons.upload_file_rounded, () {
          // TODO: Implement image_picker
        }),
        const SizedBox(height: 20),
        buildElevatedButton('Daftar Sekarang', () {
          Navigator.pushReplacementNamed(context, AppRoutes.studentOnboarding);
        }),
        buildAuthFooter('Sudah punya akun?', 'Masuk', () {
          Navigator.pop(context);
        }),
      ],
    );
  }
}
