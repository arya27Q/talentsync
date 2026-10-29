import 'package:flutter/material.dart';
import 'shared_auth_layout.dart';

class MsmeRegisterScreen extends StatelessWidget {
  const MsmeRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedAuthLayout(
      title: 'Daftar UMKM',
      children: [
        buildFloatingTextField('Nama Pemilik', Icons.person_outline),
        buildFloatingTextField('Nama Toko / Usaha', Icons.storefront_outlined),
        buildFloatingTextField('Email', Icons.email_outlined),
        buildFloatingTextField('Password', Icons.lock_outline, isPassword: true),
        const SizedBox(height: 10),
        buildUploadButton('Unggah Foto Fisik Toko / NIB', Icons.add_a_photo_outlined, () {
          // TODO: Implement image_picker
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
