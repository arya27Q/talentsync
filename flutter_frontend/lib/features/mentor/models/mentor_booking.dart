import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';

class MentorBooking {
  const MentorBooking({
    required this.student,
    required this.topic,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.price,
    this.message = '',
    this.sessionGoals = const [],
    this.repositoryUrl,
    this.rating,
    this.completedProjects,
    this.meetingUrl,
  });

  final MentorStudent student;
  final String topic;
  final String date;
  final String time;
  final int durationMinutes;
  final int price;
  final String message;
  final List<String> sessionGoals;
  final String? repositoryUrl;
  final double? rating;
  final int? completedProjects;
  final String? meetingUrl;
}

const mentorBookingRequests = [
  MentorBooking(
    student: mentorStudentDewi,
    topic: 'Review arsitektur aplikasi antrean',
    date: 'Kam, 26 Jun',
    time: '19.00',
    durationMinutes: 60,
    price: 30,
    message: 'Mas Dimas, aplikasi antrean saya mulai lambat saat datanya banyak. Saya ingin dicek strukturnya sebelum melamar proyek UMKM.',
    sessionGoals: [
      'Tahu bottleneck performa',
      'Struktur folder yang benar',
      'Siap melamar proyek aplikasi pre-order',
    ],
    repositoryUrl: 'github.com/dewilestari/antrean',
    rating: 4.7,
    completedProjects: 2,
  ),
  MentorBooking(
    student: mentorStudentRafi,
    topic: 'Migrasi React Native ke Flutter',
    date: 'Jum, 27 Jun',
    time: '16.00',
    durationMinutes: 60,
    price: 30,
  ),
];
