import 'dart:typed_data';

class StudentSetupArgs {
  const StudentSetupArgs({
    required this.university,
    required this.major,
    required this.studentIdNumber,
    this.ktmFileName,
    this.ktmBytes,
    this.isAuthenticated = false,
  });

  final String university;
  final String major;
  final String studentIdNumber;
  final String? ktmFileName;
  final Uint8List? ktmBytes;
  final bool isAuthenticated;
}

class ProjectRouteArgs {
  const ProjectRouteArgs({this.projectId});

  final int? projectId;
}

class MentorDetailArgs {
  const MentorDetailArgs({this.mentorId, this.classId});

  final int? mentorId;
  final int? classId;
}

class BookingSessionArgs {
  const BookingSessionArgs({
    this.classId,
    this.mentorId,
    this.mentorName,
    this.headline,
    this.topic,
    this.dateLabel,
    this.timeLabel,
    this.priceTc,
  });

  final int? classId;
  final int? mentorId;
  final String? mentorName;
  final String? headline;
  final String? topic;
  final String? dateLabel;
  final String? timeLabel;
  final int? priceTc;
}

class MentoringEnrollmentArgs {
  const MentoringEnrollmentArgs({
    this.enrollmentId,
    this.classId,
    this.initialTab = 0,
  });

  final int? enrollmentId;
  final int? classId;
  final int initialTab;
}

class CaseStudyArgs {
  const CaseStudyArgs({this.portfolioId});

  final int? portfolioId;
}

class VideoCallArgs {
  const VideoCallArgs({
    this.enrollmentId,
    this.participantName,
    this.avatarUrl,
    this.meetingLink,
    this.durationMinutes,
  });

  final int? enrollmentId;
  final String? participantName;
  final String? avatarUrl;
  final String? meetingLink;
  final int? durationMinutes;
}

