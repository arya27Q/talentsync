import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';

class MentorBooking {
  const MentorBooking({
    this.enrollmentId,
    this.classId,
    required this.student,
    required this.topic,
    required this.date,
    this.time = '',
    required this.durationMinutes,
    required this.price,
    this.message = '',
    this.sessionGoals = const [],
    this.repositoryUrl,
    this.rating,
    this.completedProjects,
    this.meetingUrl,
    this.score,
    this.status = 'pending',
  });

  final int? enrollmentId;
  final int? classId;
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
  final String? score;
  final String status;

  factory MentorBooking.fromEnrollment(Map<String, dynamic> data) {
    final classData = data['class'] is Map<String, dynamic>
        ? data['class'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final studentData = data['student'] is Map<String, dynamic>
        ? data['student'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final student = MentorStudent.fromEnrollment(data);
    final scheduled = DateTime.tryParse(
      classData['scheduled_time'] as String? ?? '',
    );

    return MentorBooking(
      enrollmentId: data['id'] as int?,
      classId: classData['id'] as int?,
      student: student,
      topic: classData['topic'] as String? ?? 'Sesi mentoring',
      date:
          scheduled?.toLocal().toString().split(' ').first ??
          'Jadwal belum tersedia',
      time: scheduled == null
          ? ''
          : '${scheduled.toLocal().hour.toString().padLeft(2, '0')}:${scheduled.toLocal().minute.toString().padLeft(2, '0')}',
      durationMinutes: classData['duration_minutes'] as int? ?? 60,
      price: data['paid_tc'] as int? ?? 0,
      message: data['mentor_feedback'] as String? ?? '',
      repositoryUrl: studentData['email'] as String?,
      meetingUrl: classData['meeting_link'] as String?,
      score: data['assessment_score'] == null
          ? null
          : 'Nilai ${data['assessment_score']}/100',
      status: data['status'] as String? ?? 'pending',
    );
  }
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
    status: 'pending',
  ),
  MentorBooking(
    student: mentorStudentRafi,
    topic: 'Migrasi React Native ke Flutter',
    date: 'Jum, 27 Jun',
    time: '16.00',
    durationMinutes: 60,
    price: 30,
    status: 'pending',
  ),
];

const mentorScheduledBookings = [
  MentorBooking(
    student: mentorStudentArya,
    topic: 'Persiapan wawancara Flutter',
    date: 'Hari ini',
    time: '19.00',
    durationMinutes: 60,
    price: 30,
    meetingUrl: 'meet.google.com/tsy-arya-019',
    status: 'accepted',
  ),
  MentorBooking(
    student: mentorStudentDewi,
    topic: 'Dasar BLoC & Cubit',
    date: 'Besok',
    time: '20.00',
    durationMinutes: 60,
    price: 30,
    meetingUrl: 'meet.google.com/tsy-dewi-114',
    status: 'accepted',
  ),
];

const mentorCompletedBookings = [
  MentorBooking(
    student: mentorStudentArya,
    topic: 'Struktur BLoC untuk aplikasi kasir',
    date: '8 Jul',
    time: '',
    durationMinutes: 60,
    price: 30,
    score: 'Nilai 88/100',
    status: 'completed',
  ),
  MentorBooking(
    student: mentorStudentArya,
    topic: 'Review arsitektur awal proyek',
    date: '24 Jun',
    time: '',
    durationMinutes: 60,
    price: 30,
    score: 'Nilai 82/100',
    status: 'completed',
  ),
];
