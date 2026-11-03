class MentorStudent {
  const MentorStudent({
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
  });

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
