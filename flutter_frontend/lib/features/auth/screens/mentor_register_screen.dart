import 'package:flutter/material.dart';
import 'shared_auth_layout.dart';

class MentorRegisterScreen extends StatelessWidget {
  const MentorRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedAuthLayout(
      title: 'Daftar Mentor Profesional',
      children: [
        buildFloatingTextField('Nama Lengkap', Icons.person_outline),
        buildFloatingTextField('Bidang Keahlian (Top Skill)', Icons.star_outline),
        buildFloatingTextField('Email Profesional', Icons.email_outlined),
        buildFloatingTextField('Password', Icons.lock_outline, isPassword: true),
        buildFloatingTextField('URL Profil LinkedIn', Icons.link_outlined),
        const SizedBox(height: 10),
        buildUploadButton('Unggah CV / Portofolio (PDF)', Icons.description_outlined, () {
          // TODO: Implement file_picker
        }),
        const SizedBox(height: 20),
        buildElevatedButton('Daftar Sekarang', () {}),
        buildAuthFooter('Sudah punya akun?', 'Masuk', () {
          Navigator.pop(context);
        }),
      ],
    );
  }
}
