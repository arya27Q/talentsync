import 'package:flutter/material.dart';
import 'package:skillswap_frontend/splash_screen.dart';
import 'package:skillswap_frontend/role_selection_screen.dart';
import 'package:skillswap_frontend/features/auth/screens/student_auth_screen.dart';
import 'package:skillswap_frontend/features/auth/screens/msme_auth_screen.dart';
import 'package:skillswap_frontend/features/auth/screens/mentor_auth_screen.dart';
import 'package:skillswap_frontend/features/auth/screens/student_register_screen.dart';
import 'package:skillswap_frontend/features/auth/screens/msme_register_screen.dart';
import 'package:skillswap_frontend/features/auth/screens/mentor_register_screen.dart';
import 'package:skillswap_frontend/features/auth/screens/student_onboarding_screen.dart';
import 'package:skillswap_frontend/features/auth/screens/student_setup_profile_screen.dart';
import 'package:skillswap_frontend/features/dashboard/screens/student_main_layout.dart';
import 'package:skillswap_frontend/features/project/screens/my_projects_screen.dart';
import 'package:skillswap_frontend/features/notifications/screens/notifications_screen.dart';
import 'package:skillswap_frontend/features/workspace/screens/workspace_kanban_screen.dart';
import 'package:skillswap_frontend/features/workspace/screens/workspace_chat_screen.dart';
import 'package:skillswap_frontend/features/chat/screens/video_call_screen.dart';
import 'package:skillswap_frontend/features/workspace/screens/inbox_screen.dart';
import 'package:skillswap_frontend/features/workspace/screens/submission_screen.dart';
import 'package:skillswap_frontend/features/portfolio/screens/portfolio_dashboard_screen.dart';
import 'package:skillswap_frontend/features/portfolio/screens/case_study_screen.dart';
import 'package:skillswap_frontend/features/wallet/screens/wallet_dashboard_screen.dart';
import 'package:skillswap_frontend/features/mentoring/screens/find_mentors_screen.dart';
import 'package:skillswap_frontend/features/mentoring/screens/mentor_profile_screen.dart';
import 'package:skillswap_frontend/features/mentoring/screens/mentor_chat_screen.dart';
import 'package:skillswap_frontend/features/mentoring/screens/booking_session_screen.dart';
import 'package:skillswap_frontend/features/wallet/screens/reward_hub_screen.dart';
import 'package:skillswap_frontend/features/profile/screens/student_settings_screen.dart';
import 'package:skillswap_frontend/features/profile/screens/edit_profile_screen.dart';
import 'package:skillswap_frontend/features/profile/screens/privacy_security_screen.dart';
import 'package:skillswap_frontend/features/profile/screens/help_support_screen.dart';
import 'package:skillswap_frontend/features/project/screens/project_detail_screen.dart';

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
  static const String studentSetupProfile = '/auth/student/setup-profile';
  static const String projectDetail = '/project-detail';
  static const String myProjects = '/my-projects';
  static const String notifications = '/notifications';
  static const String workspaceKanban = '/workspace/kanban';
  static const String workspaceChat = '/workspace/chat';
  static const String videoCall = '/chat/video_call';
  static const String inbox = '/inbox';
  static const String submission = '/workspace/submission';
  static const String portfolio = '/portfolio';
  static const String caseStudy = '/portfolio/case-study';
  static const String wallet = '/wallet';
  static const String findMentors = '/mentors';
  static const String mentorProfile = '/mentors/profile';
  static const String mentorChat = '/mentors/chat';
  static const String bookingSession = '/mentors/booking';
  static const String rewardHub = '/wallet/rewards';
  static const String settings = '/settings';
  static const String editProfile = '/settings/edit-profile';
  static const String privacySecurity = '/settings/privacy-security';
  static const String helpSupport = '/settings/help-support';


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
    studentSetupProfile: (context) => const StudentSetupProfileScreen(),
    projectDetail: (context) => const ProjectDetailScreen(),

    myProjects: (context) => const MyProjectsScreen(),
    notifications: (context) => const NotificationsScreen(),
    workspaceKanban: (context) => const WorkspaceKanbanScreen(),
    workspaceChat: (context) => const WorkspaceChatScreen(),
    videoCall: (context) => const VideoCallScreen(),
    inbox: (context) => const InboxScreen(),
    submission: (context) => const SubmissionScreen(),
    portfolio: (context) => const PortfolioDashboardScreen(),
    caseStudy: (context) => const CaseStudyScreen(),
    wallet: (context) => const WalletDashboardScreen(),
    findMentors: (context) => const FindMentorsScreen(),
    mentorProfile: (context) => const MentorProfileScreen(),
    mentorChat: (context) => const MentorChatScreen(),
    bookingSession: (context) => const BookingSessionScreen(),
    rewardHub: (context) => const RewardHubScreen(),
    settings: (context) => const StudentSettingsScreen(),
    editProfile: (context) => const EditProfileScreen(),
    privacySecurity: (context) => const PrivacySecurityScreen(),
    helpSupport: (context) => const HelpSupportScreen(),




  };
}
