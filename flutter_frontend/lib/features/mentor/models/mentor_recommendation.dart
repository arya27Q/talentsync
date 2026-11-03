import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';

class MentorUmkmProject {
  const MentorUmkmProject({
    required this.businessName,
    required this.title,
    required this.skills,
    required this.rewardTc,
  });

  final String businessName;
  final String title;
  final List<String> skills;
  final int rewardTc;
}

class MentorRecommendationCandidate {
  const MentorRecommendationCandidate({
    required this.student,
    required this.skills,
    required this.certificates,
    required this.matchPercent,
  });

  final MentorStudent student;
  final List<String> skills;
  final int certificates;
  final int matchPercent;
}

class MentorRecommendationDraft {
  const MentorRecommendationDraft({
    required this.project,
    required this.candidate,
    required this.reason,
  });

  final MentorUmkmProject project;
  final MentorRecommendationCandidate candidate;
  final String reason;
}

const mentorUmkmProjects = [
  MentorUmkmProject(
    businessName: 'Kopi Tepi Kali',
    title: 'Aplikasi Menu & Pre-order Kopi',
    skills: ['Flutter', 'Firebase'],
    rewardTc: 380,
  ),
  MentorUmkmProject(
    businessName: 'Batik Warisan Nusantara',
    title: 'Landing Page Pemesanan Batik Tulis',
    skills: ['React', 'UI Design'],
    rewardTc: 450,
  ),
];

const mentorRecommendationCandidates = [
  MentorRecommendationCandidate(
    student: mentorStudentDewi,
    skills: ['Flutter', 'Firebase', 'UI Design'],
    certificates: 0,
    matchPercent: 98,
  ),
  MentorRecommendationCandidate(
    student: mentorStudentArya,
    skills: ['Flutter', 'Laravel', 'MySQL'],
    certificates: 2,
    matchPercent: 92,
  ),
  MentorRecommendationCandidate(
    student: mentorStudentRafi,
    skills: ['React Native', 'Node.js'],
    certificates: 0,
    matchPercent: 79,
  ),
];
