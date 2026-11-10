import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorRecommendationArgs {
  const MentorRecommendationArgs({this.initialStudent, this.onSelectTab});
  final MentorStudent? initialStudent;
  final ValueChanged<int>? onSelectTab;
}

class MentorRecommendationScreen extends StatelessWidget {
  const MentorRecommendationScreen({
    super.key,
    this.initialStudent,
    this.onSelectTab,
  });
  final MentorStudent? initialStudent;
  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    appBar: AppBar(title: const Text('Rekomendasi ke UMKM')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 42,
              color: AppColors.primaryNavy,
            ),
            const SizedBox(height: 14),
            const Text(
              'Fitur rekomendasi proyek belum tersedia di backend.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Endorsement kemampuan murid bisa diberikan dari ruang belajar setelah sesi selesai dan nilainya memenuhi syarat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: MentorBottomNav(
      selectedIndex: 2,
      onSelected: (index) {
        if (onSelectTab == null) {
          Navigator.pop(context, index);
          return;
        }
        onSelectTab!(index);
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    ),
  );
}
