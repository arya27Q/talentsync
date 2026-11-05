import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _twoFactorEnabled = true;
  bool _publicPortfolio = true;
  bool _showOnlineStatus = true;
  bool _showEndorseBadge = true;

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 22),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.secondarySlate,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = AppColors.primaryNavy,
    Color titleColor = AppColors.darkSlate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondarySlate,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (trailing != null)
                  trailing
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.pin_rounded, color: AppColors.primaryNavy),
            SizedBox(width: 10),
            Text(
              'Ubah PIN Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan 6 digit angka untuk mengamankan otorisasi pencairan TimeCoin ke rekening bank.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.secondarySlate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'PIN Baru (6 angka)',
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSlate),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondarySlate),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN transaksi berhasil diperbarui.'),
                  backgroundColor: AppColors.primaryNavy,
                ),
              );
            },
            child: const Text(
              'Simpan PIN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDevicesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perangkat & Sesi Aktif',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Daftar perangkat yang saat ini masuk ke akun TalentSync Anda.',
              style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.smartphone_rounded,
                    color: AppColors.primaryNavy,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Samsung Galaxy A54 (Perangkat Ini)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Surabaya, Indonesia \u00B7 Aktif sekarang',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Utama',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Semua sesi di perangkat lain telah diakhiri.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Keluarkan dari Semua Perangkat Lain',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Kebijakan Privasi & Smart Escrow TalentSync',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Perlindungan Data Mahasiswa & KTM\nData Nomor Induk Mahasiswa (NIM) dan foto Kartu Tanda Mahasiswa (KTM) yang diunggah hanya dipergunakan untuk proses validasi status akademik perguruan tinggi dan tidak pernah dibagikan kepada pihak ketiga di luar verifikasi akun.\n\n'
              '2. Keamanan Dana Smart Escrow\nSeluruh transaksi TimeCoin dan imbalan proyek disimpan dalam sistem smart escrow terenkripsi. Dana mahasiswa aman hingga mitra UMKM memvalidasi deliverable kerja yang disepakati.\n\n'
              '3. Hak Kepemilikan Portofolio\nHak cipta karya desain, kode sumber aplikasi, dan aset yang dihasilkan mahasiswa tetap dihormati sesuai kesepakatan surat penugasan proyek UMKM.\n\n'
              '4. Transparansi Rekomendasi Mentor\nStempel rekomendasi kerja (endorsement) dari mentor terhubung dengan ID unik kredensial yang dapat diverifikasi publik tanpa memperlihatkan catatan pribadi bimbingan 1-on-1.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: AppColors.darkSlate,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privasi & Keamanan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        'Kontrol keamanan akun, PIN dompet, dan privasi',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  // Info Security Badge
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primaryNavy,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Akun Anda terproteksi enkripsi TLS 1.3 dan Smart Escrow resmi TalentSync.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section 1: Keamanan Akun
                  _buildSectionHeader('KEAMANAN AKUN & DOMPET'),
                  _buildSettingsTile(
                    icon: Icons.pin_rounded,
                    title: 'PIN Transaksi TimeCoin',
                    subtitle: 'PIN 6-digit untuk otorisasi transfer dan pencairan dana',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Terpasang',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    onTap: _showChangePinDialog,
                  ),
                  _buildSettingsTile(
                    icon: Icons.lock_rounded,
                    title: 'Kata Sandi Akun',
                    subtitle: 'Terakhir diperbarui 14 hari yang lalu',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tautan pengaturan ulang sandi dikirim ke email terdaftar.',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.security_rounded,
                    title: 'Autentikasi Dua Langkah (2FA)',
                    subtitle: 'Minta kode verifikasi OTP saat masuk dari perangkat baru',
                    trailing: Switch(
                      value: _twoFactorEnabled,
                      activeThumbColor: AppColors.primaryNavy,
                      activeTrackColor: const Color(0xFFBFDBFE),
                      onChanged: (val) {
                        setState(() {
                          _twoFactorEnabled = val;
                        });
                      },
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.devices_rounded,
                    title: 'Perangkat & Sesi Login',
                    subtitle: '1 perangkat ponsel terhubung aktif',
                    onTap: _showDevicesModal,
                  ),

                  // Section 2: Privasi Profil & Portofolio
                  _buildSectionHeader('PRIVASI PROFIL & PORTOFOLIO'),
                  _buildSettingsTile(
                    icon: Icons.public_rounded,
                    title: 'Visibilitas Portofolio Publik',
                    subtitle: 'Izinkan mitra UMKM dan pengunjung menemukan profil karya Anda',
                    trailing: Switch(
                      value: _publicPortfolio,
                      activeThumbColor: AppColors.primaryNavy,
                      activeTrackColor: const Color(0xFFBFDBFE),
                      onChanged: (val) {
                        setState(() {
                          _publicPortfolio = val;
                        });
                      },
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.circle_rounded,
                    title: 'Tampilkan Status Online',
                    subtitle: 'Tampilkan titik hijau aktif di ruang chat proyek dan bimbingan',
                    trailing: Switch(
                      value: _showOnlineStatus,
                      activeThumbColor: AppColors.primaryNavy,
                      activeTrackColor: const Color(0xFFBFDBFE),
                      onChanged: (val) {
                        setState(() {
                          _showOnlineStatus = val;
                        });
                      },
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Tampilkan Rekomendasi Mentor',
                    subtitle: 'Sertakan stempel badge endorsement mentor di profil pelamar',
                    trailing: Switch(
                      value: _showEndorseBadge,
                      activeThumbColor: AppColors.primaryNavy,
                      activeTrackColor: const Color(0xFFBFDBFE),
                      onChanged: (val) {
                        setState(() {
                          _showEndorseBadge = val;
                        });
                      },
                    ),
                  ),

                  // Section 3: Data & Ketentuan Layanan
                  _buildSectionHeader('MANAJEMEN DATA & KETENTUAN'),
                  _buildSettingsTile(
                    icon: Icons.download_rounded,
                    title: 'Unduh Salinan Data Portofolio',
                    subtitle: 'Dapatkan arsip PDF ringkasan proyek & transaksi TimeCoin',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Permintaan data diproses. File akan dikirim ke email dalam 5 menit.',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.description_rounded,
                    title: 'Kebijakan Privasi & Smart Escrow',
                    subtitle:
                        'Baca komitmen perlindungan data dan aturan transaksi',
                    onTap: _showPrivacyPolicyModal,
                  ),
                  _buildSettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar dari Akun',
                    subtitle: 'Akhiri sesi masuk mahasiswa pada perangkat ini',
                    iconColor: const Color(0xFFEF4444),
                    titleColor: const Color(0xFFDC2626),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          title: const Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFDC2626),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Keluar dari Akun?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            ],
                          ),
                          content: const Text(
                            'Apakah Anda yakin ingin keluar dari akun mahasiswa? Anda harus masuk kembali dengan NIM dan kata sandi.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.roleSelection,
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'Keluar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Hapus atau Nonaktifkan Akun',
                    subtitle:
                        'Tutup akun secara permanen beserta saldo TimeCoin',
                    iconColor: const Color(0xFFEF4444),
                    titleColor: const Color(0xFFDC2626),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          title: const Text(
                            'Nonaktifkan Akun?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          content: const Text(
                            'Setelah dinonaktifkan, portofolio dan riwayat bimbingan Anda tidak dapat diakses kembali oleh mitra UMKM.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Permintaan penutupan akun sedang ditinjau tim admin.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Ya, Lanjutkan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
