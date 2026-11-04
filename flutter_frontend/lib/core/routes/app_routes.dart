import 'package:flutter/material.dart';
import 'package:flutter_frontend/splash_screen.dart';
import 'package:flutter_frontend/role_selection_screen.dart';
import 'package:flutter_frontend/features/auth/screens/student_auth_screen.dart';
import 'package:flutter_frontend/features/auth/screens/msme_auth_screen.dart';
import 'package:flutter_frontend/features/auth/screens/mentor_auth_screen.dart';
import 'package:flutter_frontend/features/auth/screens/student_register_screen.dart';
import 'package:flutter_frontend/features/auth/screens/msme_register_screen.dart';
import 'package:flutter_frontend/features/auth/screens/mentor_register_screen.dart';
import 'package:flutter_frontend/features/auth/screens/student_onboarding_screen.dart';
import 'package:flutter_frontend/features/auth/screens/msme_onboarding_screen.dart';
import 'package:flutter_frontend/features/auth/screens/student_setup_profile_screen.dart';
import 'package:flutter_frontend/features/auth/screens/student_setup_profile_step2_screen.dart';
import 'package:flutter_frontend/features/dashboard/screens/student_main_layout.dart';
import 'package:flutter_frontend/features/project/screens/explore_projects_screen.dart';
import 'package:flutter_frontend/features/project/screens/project_detail_screen.dart';
import 'package:flutter_frontend/features/project/screens/apply_project_screen.dart';
import 'package:flutter_frontend/features/project/screens/my_projects_screen.dart';
import 'package:flutter_frontend/features/project/screens/project_completed_screen.dart';
import 'package:flutter_frontend/features/notifications/screens/notifications_screen.dart';
import 'package:flutter_frontend/features/workspace/screens/workspace_kanban_screen.dart';
import 'package:flutter_frontend/features/workspace/screens/workspace_chat_screen.dart';
import 'package:flutter_frontend/features/chat/screens/video_call_screen.dart';
import 'package:flutter_frontend/features/workspace/screens/inbox_screen.dart';
import 'package:flutter_frontend/features/workspace/screens/submission_screen.dart';
import 'package:flutter_frontend/features/portfolio/screens/portfolio_dashboard_screen.dart';
import 'package:flutter_frontend/features/portfolio/screens/certificates_screen.dart';
import 'package:flutter_frontend/features/portfolio/screens/case_study_screen.dart';
import 'package:flutter_frontend/features/wallet/screens/wallet_dashboard_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/find_mentors_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/mentor_profile_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/mentor_chat_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/booking_session_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/mentoring_session_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/selesai_bimbingan_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/mentoring_result_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/my_mentors_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/log_bimbingan_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/ruang_belajar_screen.dart';
import 'package:flutter_frontend/features/wallet/screens/reward_hub_screen.dart';
import 'package:flutter_frontend/features/profile/screens/student_settings_screen.dart';
import 'package:flutter_frontend/features/profile/screens/edit_profile_screen.dart';
import 'package:flutter_frontend/features/profile/screens/privacy_security_screen.dart';
import 'package:flutter_frontend/features/profile/screens/help_support_screen.dart';
import 'package:flutter_frontend/features/profile/screens/switch_to_mentor_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_main_layout.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_onboarding_screen.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_recommendation_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_booking_detail_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_live_mentoring_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_student_chat_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_student_learning_room_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_cashout_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_featured_upgrade_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_main_layout.dart';
import 'package:flutter_frontend/features/msme/screens/msme_create_task_wizard_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_review_applicants_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_applicant_profile_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_review_submission_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';

class AppRoutes {
  // Define Route Names
  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String studentAuth = '/auth/student';
  static const String msmeAuth = '/auth/msme';
  static const String mentorAuth = '/auth/mentor';
  static const String studentRegister = '/auth/student/register';
  static const String msmeRegister = '/auth/msme/register';
  static const String mentorRegister = '/auth/mentor/register';
  static const String studentOnboarding = '/auth/student/onboarding';
  static const String studentDashboard = '/dashboard/student';
  static const String mentorDashboard = '/dashboard/mentor';
  static const String msmeDashboard = '/dashboard/msme';
  static const String msmeCreateTask = '/msme/create-task';
  static const String msmeReviewApplicants = '/msme/review-applicants';
  static const String msmeApplicantProfile = '/msme/applicant-profile';
  static const String msmeReviewSubmission = '/msme/review-submission';
  static const String msmeChat = '/msme/chat';
  static const String msmeOnboarding = '/msme/onboarding';
  static const String mentorOnboarding = '/mentor/onboarding';
  static const String mentorBookingDetail = '/mentor/booking-detail';
  static const String mentorLiveMentoring = '/mentor/live';
  static const String mentorStudentLearningRoom =
      '/mentor/student/learning-room';
  static const String mentorStudentChat = '/mentor/student/chat';
  static const String mentorRecommendation = '/mentor/recommendation';
  static const String mentorCashOut = '/mentor/cash-out';
  static const String mentorFeaturedUpgrade = '/mentor/featured';
  static const String studentSetupProfile = '/auth/student/setup-profile';
  static const String studentSetupProfileStep2 =
      '/auth/student/setup-profile-step2';
  static const String exploreProjects = '/projects/explore';
  static const String projectDetail = '/project-detail';
  static const String applyProject = '/project/apply';
  static const String myProjects = '/my-projects';
  static const String projectCompleted = '/project/completed';
  static const String notifications = '/notifications';
  static const String workspaceKanban = '/workspace/kanban';
  static const String workspaceChat = '/workspace/chat';
  static const String videoCall = '/chat/video_call';
  static const String inbox = '/inbox';
  static const String submission = '/workspace/submission';
  static const String portfolio = '/portfolio';
  static const String certificates = '/portfolio/certificates';
  static const String caseStudy = '/portfolio/case-study';
  static const String wallet = '/wallet';
  static const String findMentors = '/mentors';
  static const String myMentors = '/mentors/my-mentors';
  static const String mentorProfile = '/mentors/profile';
  static const String mentorChat = '/mentors/chat';
  static const String bookingSession = '/mentors/booking';
  static const String mentoringSession = '/mentoring/session';
  static const String selesaiBimbingan = '/mentoring/selesai';
  static const String mentoringResult = '/mentoring/result';
  static const String logBimbingan = '/mentoring/log';
  static const String ruangBelajar = '/mentoring/ruang-belajar';
  static const String rewardHub = '/wallet/rewards';
  static const String settings = '/settings';
  static const String editProfile = '/settings/edit-profile';
  static const String privacySecurity = '/settings/privacy-security';
  static const String helpSupport = '/settings/help-support';
  static const String switchToMentor = '/profile/switch-to-mentor';

  // Define Route Map
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    roleSelection: (context) => const RoleSelectionScreen(),
    studentAuth: (context) => const StudentAuthScreen(),
    msmeAuth: (context) => const MsmeAuthScreen(),
    mentorAuth: (context) => const MentorAuthScreen(),
    studentRegister: (context) => const StudentRegisterScreen(),
    msmeRegister: (context) => const MsmeRegisterScreen(),
    mentorRegister: (context) => const MentorRegisterScreen(),
    studentOnboarding: (context) => const StudentOnboardingScreen(),
    studentDashboard: (context) => const StudentMainLayout(),
    mentorDashboard: (context) => const MentorMainLayout(),
    msmeDashboard: (context) => const MsmeMainLayout(),
    msmeCreateTask: (context) => const MsmeCreateTaskWizardScreen(),
    msmeReviewApplicants: (context) => const MsmeReviewApplicantsScreen(),
    msmeApplicantProfile: (context) => const MsmeApplicantProfileScreen(),
    msmeReviewSubmission: (context) => const MsmeReviewSubmissionScreen(),
    msmeChat: (context) => const MsmeChatScreen(),
    msmeOnboarding: (context) => const MsmeOnboardingScreen(),
    mentorOnboarding: (context) => const MentorOnboardingScreen(),
    mentorBookingDetail: (context) => MentorBookingDetailScreen(
      args:
          ModalRoute.of(context)!.settings.arguments as MentorBookingDetailArgs,
    ),
    mentorLiveMentoring: (context) {
      final argument = ModalRoute.of(context)?.settings.arguments;
      if (argument is MentorLiveMentoringArgs) {
        return MentorLiveMentoringScreen(
          student: argument.student,
          meetingUrl: argument.meetingUrl,
          onSelectTab: argument.onSelectTab,
        );
      }
      final student = argument is MentorStudent ? argument : mentorStudentArya;
      return MentorLiveMentoringScreen(student: student);
    },
    mentorStudentLearningRoom: (context) {
      final argument = ModalRoute.of(context)?.settings.arguments;
      if (argument is MentorStudentLearningRoomArgs) {
        return MentorStudentLearningRoomScreen(
          student: argument.student,
          onSelectTab: argument.onSelectTab,
        );
      }
      final student = argument is MentorStudent ? argument : mentorStudentArya;
      return MentorStudentLearningRoomScreen(student: student);
    },
    mentorStudentChat: (context) {
      final student = ModalRoute.of(context)?.settings.arguments;
      return MentorStudentChatScreen(
        student: student is MentorStudent ? student : mentorStudentArya,
      );
    },
    mentorRecommendation: (context) {
      final argument = ModalRoute.of(context)?.settings.arguments;
      if (argument is MentorRecommendationArgs) {
        return MentorRecommendationScreen(
          initialStudent: argument.initialStudent,
          onSelectTab: argument.onSelectTab,
        );
      }
      final student = argument is MentorStudent ? argument : null;
      return MentorRecommendationScreen(initialStudent: student);
    },
    mentorCashOut: (context) {
      final argument = ModalRoute.of(context)?.settings.arguments;
      if (argument is MentorCashOutArgs) {
        return MentorCashOutScreen(
          availableTc: argument.availableTc,
          onSelectTab: argument.onSelectTab,
        );
      }
      return const MentorCashOutScreen();
    },
    mentorFeaturedUpgrade: (context) {
      final argument = ModalRoute.of(context)?.settings.arguments;
      if (argument is MentorFeaturedUpgradeArgs) {
        return MentorFeaturedUpgradeScreen(
          balanceTc: argument.balanceTc,
          onSelectTab: argument.onSelectTab,
        );
      }
      final balanceTc = argument is int ? argument : 420;
      return MentorFeaturedUpgradeScreen(balanceTc: balanceTc);
    },
    studentSetupProfile: (context) => const StudentSetupProfileScreen(),
    studentSetupProfileStep2: (context) =>
        const StudentSetupProfileStep2Screen(),
    exploreProjects: (context) => const ExploreProjectsScreen(),
    projectDetail: (context) => const ProjectDetailScreen(),
    applyProject: (context) => const ApplyProjectScreen(),
    myProjects: (context) => const MyProjectsScreen(),
    projectCompleted: (context) => const ProjectCompletedScreen(),
    notifications: (context) => const NotificationsScreen(),
    workspaceKanban: (context) => const WorkspaceKanbanScreen(),
    workspaceChat: (context) => const WorkspaceChatScreen(),
    videoCall: (context) => const VideoCallScreen(),
    inbox: (context) => const InboxScreen(),
    submission: (context) => const SubmissionScreen(),
    portfolio: (context) => const PortfolioDashboardScreen(),
    certificates: (context) => const CertificatesScreen(),
    caseStudy: (context) => const CaseStudyScreen(),
    wallet: (context) => const WalletDashboardScreen(),
    findMentors: (context) => const FindMentorsScreen(),
    myMentors: (context) => const MyMentorsScreen(),
    mentorProfile: (context) => const MentorProfileScreen(),
    mentorChat: (context) => const MentorChatScreen(),
    bookingSession: (context) => const BookingSessionScreen(),
    mentoringSession: (context) => const MentoringSessionScreen(),
    selesaiBimbingan: (context) => const SelesaiBimbinganScreen(),
    mentoringResult: (context) => const MentoringResultScreen(),
    logBimbingan: (context) => const LogBimbinganScreen(),
    ruangBelajar: (context) => const RuangBelajarScreen(),
    rewardHub: (context) => const RewardHubScreen(),
    settings: (context) => const StudentSettingsScreen(),
    editProfile: (context) => const EditProfileScreen(),
    privacySecurity: (context) => const PrivacySecurityScreen(),
    helpSupport: (context) => const HelpSupportScreen(),
    switchToMentor: (context) => const SwitchToMentorScreen(),
  };
}
