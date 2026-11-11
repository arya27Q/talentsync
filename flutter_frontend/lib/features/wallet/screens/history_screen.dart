import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.walletApi});

  final WalletApi? walletApi;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final WalletApi _api = widget.walletApi ?? WalletApi.instance;

  static const List<({String label, String? type, String? direction})>
  _filters = [
    (label: 'Semua', type: null, direction: null),
    (label: 'Masuk', type: null, direction: 'credit'),
    (label: 'Keluar', type: null, direction: 'debit'),
    (label: 'Proyek', type: 'project_reward', direction: null),
    (label: 'Mentoring', type: 'mentoring_payment', direction: null),
    (label: 'Cash-Out', type: 'cash_out', direction: null),
  ];

  int _filterIdx = 0;
  int _page = 1;
  int _lastPage = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _page = 1;
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final filter = _filters[_filterIdx];
      final res = await _api.transactions(
        page: _page,
        type: filter.type,
        direction: filter.direction,
      );
      final rows = (res['data'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final meta = (res['meta'] as Map<String, dynamic>?) ?? const {};
      final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;

      if (!mounted) return;
      setState(() {
        _items = reset ? rows : [..._items, ...rows];
        _lastPage = lastPage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat riwayat transaksi.';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : _items.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: () => _load(reset: true),
                      color: AppColors.primaryNavy,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                        itemCount:
                            _items.length + (_page < _lastPage ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, idx) {
                          if (idx == _items.length) {
                            return SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                onPressed: _isLoadingMore
                                    ? null
                                    : () {
                                        _page++;
                                        _load();
                                      },
                                child: Text(
                                  _isLoadingMore
                                      ? 'Memuat...'
                                      : 'Muat Lebih Banyak',
                                ),
                              ),
                            );
                          }
                          return _buildRow(_items[idx]);
                        },
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
              'Riwayat Transaksi TimeCoin',
              style: TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, idx) {
          final active = _filterIdx == idx;
          return InkWell(
            onTap: () {
              setState(() => _filterIdx = idx);
              _load(reset: true);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryNavy : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? AppColors.primaryNavy : AppColors.borderSlate,
                ),
              ),
              child: Text(
                _filters[idx].label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : AppColors.secondarySlate,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> tx) {
    final isCredit = tx['direction'] == 'credit';
    final amount = (tx['amount'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.lightGreenSurface
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit
                  ? AppColors.successGreen
                  : const Color(0xFFDC2626),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (tx['title'] as String?) ?? 'Transaksi',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(tx['created_at'] as String?),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isCredit ? '+' : '-'}$amount TC',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isCredit
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Belum ada mutasi pada filter ini.',
          style: TextStyle(fontSize: 13.5, color: AppColors.secondarySlate),
        ),
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
                onPressed: () => _load(reset: true),
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m';
  }
}
