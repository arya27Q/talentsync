import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class MentorAuthScreen extends StatefulWidget {
  const MentorAuthScreen({super.key});

  @override
  State<MentorAuthScreen> createState() => _MentorAuthScreenState();
}

class _MentorAuthScreenState extends State<MentorAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mentorDashboard,
      (route) => false,
    );
  }

  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset kata sandi'),
        content: const Text(
          'Masukkan alamat email terdaftar melalui layanan bantuan TalentSync untuk menerima tautan reset.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    appBar: AppBar(
      backgroundColor: AppColors.canvasWhite,
      title: const Text(
        'Mentor Portal',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkSlate,
        ),
      ),
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.darkSlate,
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 60),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.work_outline_rounded,
                      color: AppColors.primaryNavy,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Masuk sebagai Mentor',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Atur jadwal sesi dan pantau perkembangan murid.',
                    style: TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const _FieldLabel('Email'),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: _inputDecoration(
                      Icons.mail_outline_rounded,
                      'nama@email.com',
                    ).copyWith(labelText: 'Email'),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Masukkan email yang valid.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel('Kata sandi'),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _signIn(),
                    decoration:
                        _inputDecoration(
                          Icons.lock_outline_rounded,
                          'Minimal 8 karakter',
                        ).copyWith(
                          labelText: 'Kata sandi',
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ),
                    validator: (value) => value == null || value.length < 8
                        ? 'Kata sandi minimal 8 karakter.'
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Lupa kata sandi?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _signIn,
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.borderSlate)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'atau',
                          style: TextStyle(color: AppColors.secondarySlate),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.borderSlate)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.mentorRegister,
                      ),
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text(
                        'Daftar jadi Mentor (Unggah Portofolio)',
                        textAlign: TextAlign.center,
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderSlate),
                        foregroundColor: AppColors.darkSlate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  InputDecoration _inputDecoration(IconData icon, String hint) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.secondarySlate),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.borderSlate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primaryNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB42318)),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.darkSlate,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
