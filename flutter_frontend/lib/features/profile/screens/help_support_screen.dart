import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key, this.workspaceApi});

  final WorkspaceApi? workspaceApi;

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  late final WorkspaceApi _workspaceApi =
      widget.workspaceApi ?? WorkspaceApi.instance;

  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIdx = 0;

  static const List<String> _categories = [
    'Semua',
    'Dompet & TC',
    'Proyek UMKM',
    'Mentoring',
    'Akun',
  ];

  static const List<Map<String, String>> _faqs = [
    {
      'category': 'Proyek UMKM',
      'q': 'Mengapa saya belum bisa melamar proyek UMKM tertentu?',
      'a':
          'Proyek UMKM mewajibkan mahasiswa memiliki minimal 1 Portofolio Terverifikasi ATAU Badge Rekomendasi dari Mentor. Jika belum punya, pesan sesi bimbingan bersama Peer Mentor terlebih dahulu.',
    },
    {
      'category': 'Dompet & TC',
      'q': 'Berapa biaya admin pencairan TimeCoin (Cash-Out)?',
      'a':
          'Pencairan TimeCoin ke Rupiah untuk mahasiswa dikenakan 0% biaya admin dengan kurs tetap 1 TC = Rp1.000.',
    },
    {
      'category': 'Mentoring',
      'q': 'Kapan escrow bimbingan diteruskan ke mentor?',
      'a':
          'TimeCoin ditahan di smart escrow saat booking dan baru cair ke mentor setelah kamu menekan Konfirmasi Selesai & Lepas Escrow pada lembar evaluasi.',
    },
    {
      'category': 'Akun',
      'q': 'Apa syarat mengaktifkan mode Peer Mentor?',
      'a':
          'Mahasiswa wajib memiliki KTM terverifikasi, menyelesaikan minimal 5 proyek UMKM nyata dengan rating >= 4.0, dan bebas dari sengketa escrow aktif.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredFaqs {
    final query = _searchController.text.trim().toLowerCase();
    final cat = _categories[_selectedCategoryIdx];
    return _faqs.where((item) {
      final catMatch = cat == 'Semua' || item['category'] == cat;
      final qMatch =
          query.isEmpty ||
          item['q']!.toLowerCase().contains(query) ||
          item['a']!.toLowerCase().contains(query);
      return catMatch && qMatch;
    }).toList();
  }

  void _openTicketModal() {
    final descCtrl = TextEditingController();
    String category = 'wallet_issue';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ajukan Tiket Bantuan & Mediasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Kategori Masalah',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'wallet_issue',
                      child: Text('Dompet / Pencairan TimeCoin'),
                    ),
                    DropdownMenuItem(
                      value: 'project_dispute',
                      child: Text('Kendala Proyek UMKM'),
                    ),
                    DropdownMenuItem(
                      value: 'account_issue',
                      child: Text('Verifikasi KTM / Akun'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => category = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan kendala Anda (minimal 10 karakter)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final desc = descCtrl.text.trim();
                      if (desc.length < 10) {
                        _showSnack(
                          'Deskripsi kendala minimal 10 karakter.',
                          isError: true,
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      try {
                        await _workspaceApi.fileDispute(
                          referenceType: 'wallet',
                          referenceId: 1,
                          category: category,
                          description: desc,
                        );
                        _showSnack(
                          'Tiket bantuan berhasil dikirim. Tim kami segera merespons.',
                        );
                      } on ApiException catch (e) {
                        _showSnack(e.message, isError: true);
                      } catch (_) {
                        _showSnack(
                          'Gagal mengirim tiket bantuan.',
                          isError: true,
                        );
                      }
                    },
                    child: const Text(
                      'Kirim Tiket Kendala',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(descCtrl.dispose);
  }

  Future<void> _launchExternal(String uriString) async {
    final uri = Uri.tryParse(uriString);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack('Tidak dapat membuka aplikasi tujuan.', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB91C1C)
            : AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _filteredFaqs;
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan atau panduan...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderSlate),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderSlate),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  final active = _selectedCategoryIdx == idx;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategoryIdx = idx),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryNavy
                            : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active
                              ? AppColors.primaryNavy
                              : AppColors.borderSlate,
                        ),
                      ),
                      child: Text(
                        _categories[idx],
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: active
                              ? Colors.white
                              : AppColors.secondarySlate,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  if (faqs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Tidak ada topik FAQ yang cocok.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondarySlate),
                      ),
                    )
                  else
                    ...faqs.map(
                      (faq) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: AppColors.cardSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: AppColors.borderSlate,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ExpansionTile(
                          title: Text(
                            faq['q']!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            14,
                          ),
                          children: [
                            Text(
                              faq['a']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondarySlate,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _openTicketModal,
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text(
                        'Ajukan Tiket Kendala / Mediasi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _launchExternal('mailto:support@talentsync.id'),
                            icon: const Icon(Icons.email_outlined, size: 18),
                            label: const Text('Email Support'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _launchExternal('https://wa.me/6281234567890'),
                            icon: const Icon(Icons.chat_rounded, size: 18),
                            label: const Text('WhatsApp'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.darkSlate,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pusat Bantuan & Mediasi',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
