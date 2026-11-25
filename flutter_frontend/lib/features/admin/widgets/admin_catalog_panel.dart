import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/admin/data/admin_api.dart';

const Color _catalogSoftBorder = Color(0xFFE3EAF4);
const Color _catalogSoftMuted = Color(0xFFF7F9FC);
const Color _catalogCaptionSlate = Color(0xFF475569);

InputDecoration _catalogInputDecoration(String hint) => InputDecoration(
  isDense: true,
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
  filled: true,
  fillColor: const Color(0xFFF8FAFC),
  contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _catalogSoftBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _catalogSoftBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.4),
  ),
);

Widget _catalogTableHeader(
  List<({String label, int? flex, double? width, bool alignEnd})> columns,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _catalogSoftMuted,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _catalogSoftBorder),
    ),
    child: Row(
      children: columns.map((col) {
        final text = Text(
          col.label,
          textAlign: col.alignEnd ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        );
        if (col.width != null) return SizedBox(width: col.width, child: text);
        return Expanded(flex: col.flex ?? 1, child: text);
      }).toList(),
    ),
  );
}

Widget _catalogStatusPill(String label, Color bg, Color fg, Color dot) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _catalogTonalButton({
  required String label,
  required Color bg,
  required Color fg,
  required VoidCallback onPressed,
}) {
  return Material(
    color: bg,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    ),
  );
}

class AdminMentoringModerationPanel extends StatefulWidget {
  const AdminMentoringModerationPanel({
    super.key,
    required this.api,
    required this.onNotify,
  });

  final AdminApi api;
  final void Function(String message, {bool isError}) onNotify;

  @override
  State<AdminMentoringModerationPanel> createState() =>
      _AdminMentoringModerationPanelState();
}

class _AdminMentoringModerationPanelState
    extends State<AdminMentoringModerationPanel> {
  bool _loading = true;
  List<Map<String, dynamic>> _classes = const [];
  int _page = 1;
  int _lastPage = 1;
  int _total = 0;
  String _statusFilter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.mentoringClassesPage(
        status: _statusFilter,
        search: _searchCtrl.text,
        page: page ?? _page,
      );
      if (!mounted) return;
      setState(() {
        _classes = res.items;
        _page = res.currentPage;
        _lastPage = res.lastPage;
        _total = res.total;
      });
    } on ApiException catch (e) {
      widget.onNotify(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> item, String status) async {
    final id = (item['id'] as num).toInt();
    try {
      await widget.api.updateMentoringClassStatus(
        id,
        status: status,
        reason: status == 'cancelled'
            ? 'Dinonaktifkan melalui moderasi Admin TalentSync.'
            : 'Diaktifkan kembali oleh Admin TalentSync.',
      );
      if (!mounted) return;
      widget.onNotify(
        status == 'cancelled'
            ? 'Kelas mentoring berhasil dinonaktifkan.'
            : 'Kelas mentoring diaktifkan kembali.',
      );
      await _load();
    } on ApiException catch (e) {
      widget.onNotify(e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTable = constraints.maxWidth >= 760;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _catalogSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkSlate.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moderasi Kelas Mentoring ($_total)',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Tinjau kelas yang dibuka Peer Mentor dan nonaktifkan bila melanggar pedoman.',
                style: TextStyle(fontSize: 12, color: _catalogCaptionSlate),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 270,
                    child: TextField(
                      controller: _searchCtrl,
                      onSubmitted: (_) => _load(page: 1),
                      decoration: _catalogInputDecoration('Cari topik kelas...')
                          .copyWith(
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                            ),
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 175,
                    child: DropdownButtonFormField<String>(
                      initialValue: _statusFilter,
                      isExpanded: true,
                      decoration: _catalogInputDecoration('Status'),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Semua Status'),
                        ),
                        DropdownMenuItem(value: 'open', child: Text('Terbuka')),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('Dibatalkan'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _statusFilter = v);
                        _load(page: 1);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _load(page: 1),
                      child: const Text(
                        'Cari',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                )
              else if (_classes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: _catalogSoftMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _catalogSoftBorder),
                  ),
                  child: const Text(
                    'Belum ada kelas mentoring pada filter ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: _catalogCaptionSlate),
                  ),
                )
              else ...[
                if (isTable)
                  _catalogTableHeader([
                    (
                      label: 'KELAS & MENTOR',
                      flex: 4,
                      width: null,
                      alignEnd: false,
                    ),
                    (label: 'DURASI', flex: 2, width: null, alignEnd: false),
                    (
                      label: 'TARIF & PESERTA',
                      flex: 2,
                      width: null,
                      alignEnd: false,
                    ),
                    (label: 'STATUS', flex: 2, width: null, alignEnd: false),
                    (label: 'AKSI', flex: null, width: 120, alignEnd: true),
                  ]),
                ..._classes.map((c) {
                  final status = (c['status'] as String?) ?? 'open';
                  final isCancelled = status == 'cancelled';
                  final statusPill = isCancelled
                      ? _catalogStatusPill(
                          'Dibatalkan',
                          const Color(0xFFFEF2F2),
                          const Color(0xFFB91C1C),
                          const Color(0xFFEF4444),
                        )
                      : _catalogStatusPill(
                          'Terbuka',
                          const Color(0xFFEEF2FF),
                          AppColors.primaryNavy,
                          AppColors.primaryNavy,
                        );
                  final actionBtn = _catalogTonalButton(
                    label: isCancelled ? 'Aktifkan' : 'Nonaktifkan',
                    bg: isCancelled
                        ? const Color(0xFFEEF2FF)
                        : const Color(0xFFFEF2F2),
                    fg: isCancelled
                        ? AppColors.primaryNavy
                        : const Color(0xFFB91C1C),
                    onPressed: () =>
                        _toggleStatus(c, isCancelled ? 'open' : 'cancelled'),
                  );

                  if (isTable) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    size: 18,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${c['topic'] ?? 'Kelas'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkSlate,
                                        ),
                                      ),
                                      Text(
                                        'Mentor: ${c['mentor_name'] ?? '-'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: _catalogCaptionSlate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${c['duration_label'] ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _catalogCaptionSlate,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${c['price_tc'] ?? 0} TC',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                Text(
                                  '${c['enrollments_count'] ?? 0} peserta',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _catalogCaptionSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: statusPill,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: actionBtn,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${c['topic'] ?? 'Kelas'}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            Text(
                              '${c['mentor_name'] ?? '-'} · ${c['duration_label'] ?? '-'} · ${c['price_tc'] ?? 0} TC',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _catalogCaptionSlate,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [statusPill, actionBtn],
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _catalogSoftMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _catalogSoftBorder),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Halaman $_page dari $_lastPage · Total $_total kelas',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _catalogCaptionSlate,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: _catalogSoftBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _page > 1
                              ? () => _load(page: _page - 1)
                              : null,
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            size: 16,
                          ),
                          label: const Text('Sebelumnya'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: _catalogSoftBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _page < _lastPage
                              ? () => _load(page: _page + 1)
                              : null,
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                          ),
                          label: const Text('Berikutnya'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminRewardsCatalogPanel extends StatefulWidget {
  const AdminRewardsCatalogPanel({
    super.key,
    required this.api,
    required this.onNotify,
  });

  final AdminApi api;
  final void Function(String message, {bool isError}) onNotify;

  @override
  State<AdminRewardsCatalogPanel> createState() =>
      _AdminRewardsCatalogPanelState();
}

class _AdminRewardsCatalogPanelState extends State<AdminRewardsCatalogPanel> {
  bool _loading = true;
  List<Map<String, dynamic>> _rewards = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await widget.api.rewards();
      if (mounted) setState(() => _rewards = list);
    } on ApiException catch (e) {
      widget.onNotify(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreateDialog() async {
    final titleCtrl = TextEditingController();
    final providerCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '25');
    final stockCtrl = TextEditingController(text: '20');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Tambah Item Reward Baru',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: _catalogInputDecoration('Nama Reward'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: providerCtrl,
                  decoration: _catalogInputDecoration('Penyedia / Mitra'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: _catalogInputDecoration('Deskripsi Singkat'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _catalogInputDecoration('Harga (TC)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _catalogInputDecoration('Stok'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan Reward'),
          ),
        ],
      ),
    );

    final title = titleCtrl.text.trim();
    final provider = providerCtrl.text.trim();
    final desc = descCtrl.text.trim();
    final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
    final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
    titleCtrl.dispose();
    providerCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();

    if (ok != true || !mounted) return;
    if (title.length < 3 ||
        provider.length < 2 ||
        desc.length < 5 ||
        price < 1) {
      widget.onNotify(
        'Lengkapi seluruh kolom reward dengan benar.',
        isError: true,
      );
      return;
    }

    try {
      await widget.api.createReward(
        title: title,
        provider: provider,
        description: desc,
        tcPrice: price,
        stock: stock,
      );
      if (!mounted) return;
      widget.onNotify('Reward "$title" berhasil ditambahkan.');
      await _load();
    } on ApiException catch (e) {
      widget.onNotify(e.message, isError: true);
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> r) async {
    final id = (r['id'] as num).toInt();
    final nextActive = !(r['is_active'] == true);
    try {
      await widget.api.updateReward(id, isActive: nextActive);
      if (!mounted) return;
      widget.onNotify(
        nextActive ? 'Reward diaktifkan di katalog.' : 'Reward disembunyikan.',
      );
      await _load();
    } on ApiException catch (e) {
      widget.onNotify(e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTable = constraints.maxWidth >= 760;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _catalogSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkSlate.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Katalog Reward Penukaran TimeCoin (${_rewards.length})',
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Kelola voucher, stok, dan status ketersediaan hadiah untuk mahasiswa.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _catalogCaptionSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 38,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _openCreateDialog,
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: const Text(
                        'Tambah Reward',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                )
              else if (_rewards.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: _catalogSoftMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _catalogSoftBorder),
                  ),
                  child: const Text(
                    'Belum ada item reward terdaftar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: _catalogCaptionSlate),
                  ),
                )
              else ...[
                if (isTable)
                  _catalogTableHeader([
                    (
                      label: 'REWARD & MITRA',
                      flex: 4,
                      width: null,
                      alignEnd: false,
                    ),
                    (label: 'HARGA', flex: 2, width: null, alignEnd: false),
                    (
                      label: 'STOK & DITUKAR',
                      flex: 2,
                      width: null,
                      alignEnd: false,
                    ),
                    (label: 'STATUS', flex: 2, width: null, alignEnd: false),
                    (label: 'AKSI', flex: null, width: 120, alignEnd: true),
                  ]),
                ..._rewards.map((r) {
                  final active = r['is_active'] == true;
                  final statusPill = active
                      ? _catalogStatusPill(
                          'Aktif',
                          const Color(0xFFECFDF5),
                          const Color(0xFF047857),
                          const Color(0xFF10B981),
                        )
                      : _catalogStatusPill(
                          'Nonaktif',
                          const Color(0xFFF1F5F9),
                          const Color(0xFF475569),
                          const Color(0xFF94A3B8),
                        );
                  final actionBtn = _catalogTonalButton(
                    label: active ? 'Nonaktifkan' : 'Aktifkan',
                    bg: active
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFEEF2FF),
                    fg: active
                        ? const Color(0xFFB91C1C)
                        : AppColors.primaryNavy,
                    onPressed: () => _toggleActive(r),
                  );

                  if (isTable) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.card_giftcard_rounded,
                                    size: 18,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${r['title']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkSlate,
                                        ),
                                      ),
                                      Text(
                                        '${r['provider']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: _catalogCaptionSlate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${r['tc_price']} TC',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stok ${r['stock']}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                Text(
                                  'Ditukar ${r['redemptions_count'] ?? 0}x',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _catalogCaptionSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: statusPill,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: actionBtn,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r['title']} · ${r['provider']}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            Text(
                              '${r['tc_price']} TC · Stok: ${r['stock']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _catalogCaptionSlate,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [statusPill, actionBtn],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}
