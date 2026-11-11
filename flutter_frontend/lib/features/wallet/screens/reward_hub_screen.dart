import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';

class RewardHubScreen extends StatefulWidget {
  const RewardHubScreen({super.key, this.walletApi});

  final WalletApi? walletApi;

  @override
  State<RewardHubScreen> createState() => _RewardHubScreenState();
}

class _RewardHubScreenState extends State<RewardHubScreen> {
  late final WalletApi _api = widget.walletApi ?? WalletApi.instance;

  bool _isLoading = true;
  bool _isRedeeming = false;
  String? _error;
  int _balanceTc = 0;
  List<Map<String, dynamic>> _rewards = const [];
  List<Map<String, dynamic>> _vouchers = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.rewards();
      if (!mounted) return;
      setState(() {
        _balanceTc = (data['balance_tc'] as num?)?.toInt() ?? 0;
        _rewards = (data['rewards'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        _vouchers = (data['vouchers'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
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
          _error = 'Gagal memuat katalog Reward Hub.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmAndRedeem(Map<String, dynamic> reward) async {
    final id = (reward['id'] as num?)?.toInt();
    final price = (reward['tc_price'] as num?)?.toInt() ?? 0;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tukar TimeCoin?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkSlate,
          ),
        ),
        content: Text(
          'Tukar $price TC untuk ${reward['title']} (${reward['provider']})?',
          style: const TextStyle(color: AppColors.secondarySlate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tukar Sekarang'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isRedeeming = true);
    try {
      final res = await _api.redeemReward(id);
      if (!mounted) return;
      final voucher = res['voucher'] as Map<String, dynamic>?;
      await _load();
      if (voucher != null && mounted) {
        _showVoucherQrDialog(voucher);
      }
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal menukar reward.', isError: true);
    } finally {
      if (mounted) setState(() => _isRedeeming = false);
    }
  }

  void _showVoucherQrDialog(Map<String, dynamic> voucher) {
    final code = (voucher['voucher_code'] as String?) ?? 'TS-REWARD';
    final title = (voucher['reward_title'] as String?) ?? 'Voucher Reward';
    final provider = (voucher['provider'] as String?) ?? 'Mitra TalentSync';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Voucher Digital Aktif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$title ($provider)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 16),
            _QrCodeGrid(seed: code),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.canvasWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      code,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Kode voucher disalin.'),
                          ),
                        );
                      }
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
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
                  : _error != null
                  ? _buildError()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                        children: [
                          _buildBalanceBanner(),
                          if (_vouchers.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            const Text(
                              'Voucher Saya',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._vouchers.map(_buildVoucherRow),
                          ],
                          const SizedBox(height: 18),
                          const Text(
                            'Katalog Tukar TimeCoin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_rewards.isEmpty)
                            const Text(
                              'Belum ada item reward tersedia saat ini.',
                              style: TextStyle(color: AppColors.secondarySlate),
                            )
                          else
                            ..._rewards.map(_buildRewardCard),
                        ],
                      ),
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
              'Reward Hub TimeCoin',
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

  Widget _buildBalanceBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            color: AppColors.accentAmberGold,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo TimeCoin Aktif',
                  style: TextStyle(fontSize: 12, color: Color(0xFFDBEAFE)),
                ),
                Text(
                  '$_balanceTc TC',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherRow(Map<String, dynamic> voucher) {
    return InkWell(
      onTap: () => _showVoucherQrDialog(voucher),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightGreenSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.successGreen.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.qr_code_2_rounded, color: Color(0xFF15803D)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (voucher['reward_title'] as String?) ?? 'Voucher',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  Text(
                    'Kode: ${voucher['voucher_code'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Lihat QR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> item) {
    final price = (item['tc_price'] as num?)?.toInt() ?? 0;
    final available = item['is_available'] != false;
    final canAfford = _balanceTc >= price && available;
    final icon = _mapIcon(item['icon_key'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['title'] as String?) ?? 'Reward',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  '${item['provider'] ?? 'Mitra'} | Stok ${item['stock'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford
                    ? AppColors.primaryNavy
                    : const Color(0xFFE2E8F0),
                foregroundColor: canAfford
                    ? Colors.white
                    : AppColors.secondarySlate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (!canAfford || _isRedeeming)
                  ? null
                  : () => _confirmAndRedeem(item),
              child: Text(
                '$price TC',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                ),
                onPressed: _load,
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _mapIcon(String? key) {
    switch (key) {
      case 'coffee':
        return Icons.local_cafe_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'print':
        return Icons.print_rounded;
      case 'food':
        return Icons.lunch_dining_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }
}

class _QrCodeGrid extends StatelessWidget {
  const _QrCodeGrid({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    const size = 7;
    final hash = seed.codeUnits.fold<int>(0, (acc, c) => acc * 31 + c);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSlate, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(size, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(size, (col) {
              final corner =
                  (row < 2 && col < 2) ||
                  (row < 2 && col >= size - 2) ||
                  (row >= size - 2 && col < 2);
              final filled =
                  corner || (((hash >> ((row * size + col) % 24)) ^ row ^ col) & 1) == 1;
              return Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: filled ? AppColors.darkSlate : Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
