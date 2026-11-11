import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';

class BookingSessionScreen extends StatefulWidget {
  const BookingSessionScreen({
    super.key,
    this.args,
    this.mentoringApi,
    this.walletApi,
  });

  final BookingSessionArgs? args;
  final StudentMentoringApi? mentoringApi;
  final WalletApi? walletApi;

  @override
  State<BookingSessionScreen> createState() => _BookingSessionScreenState();
}

class _BookingSessionScreenState extends State<BookingSessionScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;
  late final WalletApi _walletApi = widget.walletApi ?? WalletApi.instance;

  bool _isAgreed = true;
  final TextEditingController _materialsController = TextEditingController();

  bool _isLoading = true;
  bool _isBooking = false;
  String? _error;
  Map<String, dynamic>? _classDetail;
  int _balanceTc = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _materialsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetClassId = widget.args?.classId;
      if (targetClassId == null) {
        final mentors = await _api.mentors();
        final rows = (mentors['data'] as List?) ?? const [];
        for (final m in rows.whereType<Map<String, dynamic>>()) {
          final nearest = m['nearest_class'] as Map<String, dynamic>?;
          if (nearest != null) {
            targetClassId = (nearest['id'] as num?)?.toInt();
            break;
          }
        }
        if (targetClassId == null) {
          throw const ApiException('Belum ada jadwal kelas bimbingan terbuka.');
        }
      }

      final res = await Future.wait([
        _api.classDetail(targetClassId),
        _walletApi.summary(),
      ]);
      if (!mounted) return;
      setState(() {
        _classDetail = res[0];
        _balanceTc = (res[1]['balance_tc'] as num?)?.toInt() ?? 0;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat detail pemesanan sesi.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmBooking() async {
    if (_isBooking || _classDetail == null) return;
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setujui ketentuan penahanan saldo Smart Escrow dulu.'),
        ),
      );
      return;
    }

    final classId = (_classDetail!['id'] as num).toInt();
    final priceTc = (_classDetail!['price_tc'] as num?)?.toInt() ?? 0;
    if (_balanceTc < priceTc) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo TimeCoin tidak mencukupi. Silakan Top-Up dulu.'),
        ),
      );
      return;
    }

    setState(() => _isBooking = true);
    try {
      final notesText = _materialsController.text.trim();
      final isUrl = notesText.startsWith('http://') || notesText.startsWith('https://');
      await _api.bookClass(
        classId,
        topicFocus: widget.args?.topic ?? (_classDetail!['topic'] as String?),
        studentNotes: isUrl ? null : notesText,
        materialsUrl: isUrl ? notesText : null,
      );
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Booking Sesi Terkirim!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Sebesar $priceTc TC ditahan aman di Smart Escrow. Mentor akan mengonfirmasi jadwal sesi Anda.',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryNavy),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, AppRoutes.myMentors);
              },
              child: const Text('Buka Jadwal Mentoring'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: AppColors.canvasWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppColors.darkSlate,
            size: 28,
          ),
        ),
        title: const Text(
          'Konfirmasi Booking Sesi',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null || _classDetail == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error ?? 'Jadwal tidak ditemukan.'),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _load, child: const Text('Coba lagi')),
                    ],
                  ),
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final c = _classDetail!;
    final priceTc = (c['price_tc'] as num?)?.toInt() ?? 0;
    final remainingTc = _balanceTc - priceTc;
    final enough = remainingTc >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (c['mentor_name'] as String?) ??
                      widget.args?.mentorName ??
                      'Peer Mentor',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (c['title_headline'] as String?) ??
                      widget.args?.headline ??
                      'Mentor TalentSync',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const Divider(height: 22),
                Text(
                  'Topik: "${c['topic'] ?? widget.args?.topic ?? ''}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Durasi: ${c['duration_minutes'] ?? 60} menit · Google Meet',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Wallet Calculation Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Saldo Dompet TimeCoin'),
                    Text(
                      '$_balanceTc TC',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Biaya Sesi (Ditahan Escrow)'),
                    Text(
                      '- $priceTc TC',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sisa Saldo Setelah Booking',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      enough ? '$remainingTc TC' : 'Kurang ${-remainingTc} TC',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: enough
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Catatan / Tautan Materi Sebelum Sesi (Opsional)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _materialsController,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Tautan Figma/GitHub atau pertanyaan utama Anda...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 12),
          CheckboxListTile(
            value: _isAgreed,
            onChanged: (v) => setState(() => _isAgreed = v ?? false),
            activeColor: AppColors.primaryNavy,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Saya memahami dana TimeCoin ditahan aman oleh Smart Escrow sampai mentor menilai & saya mengonfirmasi sesi selesai.',
              style: TextStyle(fontSize: 12.5),
            ),
          ),

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    enough ? AppColors.primaryNavy : const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isBooking
                  ? null
                  : (enough
                        ? _confirmBooking
                        : () => Navigator.pushNamed(context, AppRoutes.wallet)),
              child: Text(
                _isBooking
                    ? 'Memproses Booking...'
                    : (enough
                          ? 'Konfirmasi & Tahan $priceTc TC'
                          : 'Top-Up TimeCoin Dulu'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
