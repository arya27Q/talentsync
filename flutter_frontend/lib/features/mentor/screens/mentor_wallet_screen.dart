import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorWalletScreen extends StatefulWidget {
  const MentorWalletScreen({super.key});

  @override
  State<MentorWalletScreen> createState() => _MentorWalletScreenState();
}

class _MentorWalletScreenState extends State<MentorWalletScreen> {
  final List<_CashoutRequest> _requests = [];
  static const int _balance = 124;

  Future<void> _requestCashout() async {
    final amountController = TextEditingController();
    final bankController = TextEditingController();
    final accountController = TextEditingController();
    final sent = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Ajukan pencairan', style: TextStyle(color: AppColors.darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: amountController, keyboardType: TextInputType.number, decoration: _decoration('Jumlah TimeCoin', 'Maksimal $_balance TC')),
        const SizedBox(height: 12),
        TextField(controller: bankController, decoration: _decoration('Nama bank', 'Contoh: BCA')),
        const SizedBox(height: 12),
        TextField(controller: accountController, keyboardType: TextInputType.number, decoration: _decoration('Nomor rekening', 'Nomor rekening tujuan')),
        const SizedBox(height: 10),
        const Text('Estimasi 1 TC = Rp1.000. Biaya layanan mentor freemium 10%.', style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.tertiaryCaramel, foregroundColor: Colors.white), child: const Text('Ajukan'))],
    ));
    if (sent == true && mounted) {
      final amount = int.tryParse(amountController.text) ?? 0;
      if (amount < 1 || amount > _balance || bankController.text.trim().isEmpty || accountController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Periksa jumlah TC dan lengkapi detail rekening.')));
      } else {
        setState(() => _requests.insert(0, _CashoutRequest(amount: amount, bank: bankController.text.trim(), status: 'Menunggu')));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan pencairan dicatat untuk ditinjau.')));
      }
    }
    amountController.dispose();
    bankController.dispose();
    accountController.dispose();
  }

  InputDecoration _decoration(String label, String hint) => InputDecoration(labelText: label, hintText: hint, filled: true, fillColor: AppColors.warmOffWhite, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12));

  @override
  Widget build(BuildContext context) => SafeArea(bottom: false, child: Column(children: [
    const MentorPageHeader(title: 'Wallet & cash-out', subtitle: 'Pantau pendapatan sesi mentoring.'),
    Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 28), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9A6A45), Color(0xFF4D332D)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SALDO TIMECOIN', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        const Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('124', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 38, height: 1)), SizedBox(width: 8), Padding(padding: EdgeInsets.only(bottom: 4), child: Text('TC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))]),
        const SizedBox(height: 7),
        const Text('Estimasi nilai Rp124.000', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _requestCashout, icon: const Icon(Icons.south_west_rounded, size: 18), label: const Text('Ajukan cash-out'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.darkBrown, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
      ])),
      const SizedBox(height: 16),
      const MentorCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, color: AppColors.tertiaryCaramel), SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Biaya pencairan', style: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800)), SizedBox(height: 5), Text('Mentor freemium dikenakan potongan layanan 10%. Upgrade Featured Mentor untuk bebas biaya admin.', style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.45))]))])),
      const SizedBox(height: 22),
      MentorSectionTitle('Pengajuan pencairan'),
      if (_requests.isEmpty) const MentorCard(child: Row(children: [Icon(Icons.account_balance_outlined, color: Colors.grey), SizedBox(width: 11), Expanded(child: Text('Belum ada pengajuan pencairan.', style: TextStyle(color: Colors.grey, fontSize: 12)))])) else ..._requests.map((request) => Padding(padding: const EdgeInsets.only(bottom: 10), child: MentorCard(padding: const EdgeInsets.all(15), child: Row(children: [const Icon(Icons.hourglass_top_rounded, color: Color(0xFFD4943B)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${request.amount} TC · ${request.bank}', style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 4), Text(request.status, style: const TextStyle(color: Colors.grey, fontSize: 11))])), const Text('Pending', style: TextStyle(color: Color(0xFFB77727), fontWeight: FontWeight.w700, fontSize: 11))])))),
      const SizedBox(height: 10),
      const MentorSectionTitle('Riwayat transaksi'),
      const _TransactionRow(icon: Icons.school_rounded, title: 'Sesi mentoring · Nadia Putri', date: 'Hari ini, 11.42', amount: '+5 TC', positive: true),
      const _TransactionRow(icon: Icons.school_rounded, title: 'Sesi mentoring · Dimas Akbar', date: '28 Okt 2026', amount: '+4 TC', positive: true),
      const _TransactionRow(icon: Icons.south_west_rounded, title: 'Pencairan ke BCA', date: '20 Okt 2026', amount: '−20 TC', positive: false),
    ])),
  ]));
}

class _CashoutRequest {
  const _CashoutRequest({required this.amount, required this.bank, required this.status});
  final int amount;
  final String bank, status;
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.icon, required this.title, required this.date, required this.amount, required this.positive});
  final IconData icon;
  final String title, date, amount;
  final bool positive;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: MentorCard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFF5EFE8), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 19, color: AppColors.tertiaryCaramel)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.darkBrown, fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10))])), Text(amount, style: TextStyle(color: positive ? const Color(0xFF38845B) : AppColors.darkBrown, fontSize: 12, fontWeight: FontWeight.w800))])));
}
