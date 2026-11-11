import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.walletApi});

  final WalletApi? walletApi;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late final WalletApi _api = widget.walletApi ?? WalletApi.instance;

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _recipientCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  int _balanceTc = 0;
  List<Map<String, dynamic>> _recipients = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _recipientCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>([
        _api.summary(),
        _api.recipients(),
      ]);
      if (!mounted) return;
      final summary = results[0] as Map<String, dynamic>;
      setState(() {
        _balanceTc = (summary['balance_tc'] as num?)?.toInt() ?? 0;
        _recipients = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchRecipients(String query) async {
    try {
      final rows = await _api.recipients(query: query);
      if (!mounted) return;
      setState(() => _recipients = rows);
    } catch (_) {}
  }

  Future<void> _submitTransfer() async {
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    final identifier = _recipientCtrl.text.trim();
    if (amount <= 0) {
      _showSnack('Masukkan jumlah TimeCoin yang valid.', isError: true);
      return;
    }
    if (identifier.isEmpty) {
      _showSnack('Masukkan email, NIM, atau nama penerima.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final res = await _api.transfer(
        recipientIdentifier: identifier,
        amountTc: amount,
      );
      if (!mounted) return;
      _showSnack(
        '$amount TC berhasil dikirim ke ${res['recipient_name'] ?? identifier}.',
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal memproses transfer TimeCoin.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlueSurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.toll_rounded,
                                color: AppColors.primaryNavy,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Saldo Tersedia: $_balanceTc TC',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Jumlah TimeCoin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Contoh: 25',
                            prefixIcon: const Icon(
                              Icons.toll_rounded,
                              color: AppColors.primaryNavy,
                            ),
                            filled: true,
                            fillColor: AppColors.cardSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.borderSlate,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.borderSlate,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [10, 25, 50, 100].map((v) {
                            return ActionChip(
                              label: Text('$v TC'),
                              onPressed: () =>
                                  setState(() => _amountCtrl.text = '$v'),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Email / NIM / Nama Penerima',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _recipientCtrl,
                          onChanged: _searchRecipients,
                          decoration: InputDecoration(
                            hintText: 'Cari email atau NIM rekan mahasiswa',
                            prefixIcon: const Icon(
                              Icons.person_search_rounded,
                              color: AppColors.primaryNavy,
                            ),
                            filled: true,
                            fillColor: AppColors.cardSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.borderSlate,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.borderSlate,
                              ),
                            ),
                          ),
                        ),
                        if (_recipients.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Penerima Cepat',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._recipients.take(5).map((u) {
                            final email = (u['email'] as String?) ?? '';
                            final nim = u['student_id_number'] as String?;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: AppColors.cardSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                    color: AppColors.borderSlate,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.lightBlueSurface,
                                  child: Text(
                                    ((u['name'] as String?) ?? 'U')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  (u['name'] as String?) ?? 'Pengguna',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  nim != null && nim.isNotEmpty
                                      ? '$email | NIM $nim'
                                      : email,
                                  style: const TextStyle(fontSize: 11.5),
                                ),
                                onTap: () => setState(
                                  () => _recipientCtrl.text = email,
                                ),
                              ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _submitTransfer,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Text(
                                    'Kirim TimeCoin Sekarang',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
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
              'Transfer TimeCoin P2P',
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
