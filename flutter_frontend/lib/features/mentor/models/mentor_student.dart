class MentorStudent {
  const MentorStudent({
    this.id,
    this.enrollmentId,
    this.classId,
    required this.name,
    required this.initials,
    required this.study,
    required this.focus,
    required this.sessions,
    required this.materials,
    required this.completedTasks,
    required this.totalTasks,
    required this.certificates,
    required this.completedProjects,
    this.recommended = false,
    this.needsReview = 0,
    this.assessmentScore,
    this.sessionDurationMinutes = 60,
    this.priceTc = 0,
  });

  final int? id;
  final int? enrollmentId;
  final int? classId;
  final String name;
  final String initials;
  final String study;
  final String focus;
  final int sessions;
  final int materials;
  final int completedTasks;
  final int totalTasks;
  final int certificates;
  final int completedProjects;
  final bool recommended;
  final int needsReview;
  final int? assessmentScore;
  final int sessionDurationMinutes;
  final int priceTc;

  factory MentorStudent.fromEnrollment(Map<String, dynamic> data) {
    final student = data['student'] is Map<String, dynamic>
        ? data['student'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final mentoringClass = data['class'] is Map<String, dynamic>
        ? data['class'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final name = student['name'] as String? ?? 'Mahasiswa';
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final status = data['status'] as String? ?? 'pending';

    return MentorStudent(
      id: student['id'] as int?,
      enrollmentId: data['id'] as int?,
      classId: mentoringClass['id'] as int?,
      name: name,
      initials: initials.isEmpty ? '?' : initials,
      study: student['email'] as String? ?? 'Mahasiswa TalentSync',
      focus: mentoringClass['topic'] as String? ?? 'Sesi mentoring',
      sessions: 1,
      materials: 0,
      completedTasks: 0,
      totalTasks: 0,
      certificates: 0,
      completedProjects: 0,
      recommended: data['has_endorsement'] == true,
      needsReview: status == 'attended' ? 1 : 0,
      assessmentScore: data['assessment_score'] as int?,
      sessionDurationMinutes: mentoringClass['duration_minutes'] as int? ?? 60,
      priceTc: data['paid_tc'] as int? ?? 0,
    );
  }
}

const mentorStudentArya = MentorStudent(
  name: 'Arya Pratama',
  initials: 'AP',
  study: 'Sistem Informasi · UNESA',
  focus: 'Arsitektur Flutter & BLoC',
  sessions: 3,
  materials: 3,
  completedTasks: 1,
  totalTasks: 3,
  certificates: 2,
  completedProjects: 2,
  recommended: true,
);

const mentorStudentDewi = MentorStudent(
  name: 'Dewi Lestari',
  initials: 'DL',
  study: 'Informatika · ITS',
  focus: 'Dasar BLoC & performa',
  sessions: 1,
  materials: 0,
  completedTasks: 0,
  totalTasks: 1,
  certificates: 0,
  completedProjects: 2,
  needsReview: 1,
);

const mentorStudentRafi = MentorStudent(
  name: 'Rafi Hakim',
  initials: 'RH',
  study: 'Sistem Informasi · UNAIR',
  focus: 'Roadmap Flutter',
  sessions: 1,
  materials: 0,
  completedTasks: 0,
  totalTasks: 0,
  certificates: 0,
  completedProjects: 0,
);

const mentorStudents = [
  mentorStudentArya,
  mentorStudentDewi,
  mentorStudentRafi,
];
