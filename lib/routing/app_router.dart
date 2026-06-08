import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/common/splash_screen.dart';
import '../screens/talent/talent_home_screen.dart';
import '../screens/talent/talent_profile_screen.dart';
import '../screens/talent/edit_talent_profile_screen.dart';
import '../screens/talent/audition_list_screen.dart';
import '../screens/talent/audition_detail_screen.dart';
import '../screens/talent/my_applications_screen.dart';
import '../screens/talent/media_upload_screen.dart';
import '../screens/recruiter/recruiter_home_screen.dart';
import '../screens/recruiter/recruiter_profile_screen.dart';
import '../screens/recruiter/edit_recruiter_profile_screen.dart';
import '../screens/recruiter/post_audition_screen.dart';
import '../screens/recruiter/audition_edit_screen.dart';
import '../screens/recruiter/applicants_list_screen.dart';
import '../screens/recruiter/applicant_detail_screen.dart';
import '../screens/recruiter/shortlist_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/recruiter_verification_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // ── Auth & common ──────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Talent routes ──────────────────────────────────────────────
      GoRoute(
        path: '/talent',
        name: RouteNames.talentHome,
        builder: (context, state) => const TalentHomeScreen(),
      ),
      GoRoute(
        path: '/talent/profile',
        name: RouteNames.talentProfile,
        builder: (context, state) => const TalentProfileScreen(),
      ),
      GoRoute(
        path: '/talent/profile/edit',
        name: RouteNames.editTalentProfile,
        builder: (context, state) => const EditTalentProfileScreen(),
      ),
      GoRoute(
        path: '/talent/onboarding',
        name: RouteNames.talentOnboarding,
        builder: (context, state) =>
            const EditTalentProfileScreen(isOnboarding: true),
      ),
      GoRoute(
        path: '/talent/media',
        name: RouteNames.mediaUpload,
        builder: (context, state) => const MediaUploadScreen(),
      ),
      GoRoute(
        path: '/talent/auditions',
        name: RouteNames.browseAuditions,
        builder: (context, state) => const AuditionListScreen(),
      ),
      GoRoute(
        path: '/talent/auditions/:id',
        name: RouteNames.auditionDetail,
        builder: (context, state) => AuditionDetailScreen(
          auditionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/talent/applications',
        name: RouteNames.myApplications,
        builder: (context, state) => const MyApplicationsScreen(),
      ),

      // ── Recruiter routes ───────────────────────────────────────────
      GoRoute(
        path: '/recruiter',
        name: RouteNames.recruiterHome,
        builder: (context, state) => const RecruiterHomeScreen(),
      ),
      GoRoute(
        path: '/recruiter/profile',
        name: RouteNames.recruiterProfile,
        builder: (context, state) => const RecruiterProfileScreen(),
      ),
      GoRoute(
        path: '/recruiter/profile/edit',
        name: RouteNames.editRecruiterProfile,
        builder: (context, state) => const EditRecruiterProfileScreen(),
      ),
      GoRoute(
        path: '/recruiter/onboarding',
        name: RouteNames.recruiterOnboarding,
        builder: (context, state) =>
            const EditRecruiterProfileScreen(isOnboarding: true),
      ),
      GoRoute(
        path: '/recruiter/auditions/new',
        name: RouteNames.postAudition,
        builder: (context, state) => const PostAuditionScreen(),
      ),
      GoRoute(
        path: '/recruiter/auditions/:id/edit',
        name: RouteNames.editAudition,
        builder: (context, state) => AuditionEditScreen(
          auditionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/recruiter/auditions',
        name: RouteNames.myAuditions,
        builder: (context, state) => const RecruiterHomeScreen(),
      ),
      GoRoute(
        path: '/recruiter/auditions/:id/applicants',
        name: RouteNames.applicantsList,
        builder: (context, state) => ApplicantsListScreen(
          auditionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/recruiter/applicant/:auditionId/:applicationId',
        name: RouteNames.applicantDetail,
        builder: (context, state) => ApplicantDetailScreen(
          auditionId: state.pathParameters['auditionId']!,
          applicationId: state.pathParameters['applicationId']!,
        ),
      ),
      GoRoute(
        path: '/recruiter/auditions/:id/shortlist',
        name: RouteNames.shortlist,
        builder: (context, state) => ShortlistScreen(
          auditionId: state.pathParameters['id']!,
        ),
      ),

      // ── Admin routes ───────────────────────────────────────────────
      GoRoute(
        path: '/admin',
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: RouteNames.userManagement,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/verification',
        name: RouteNames.recruiterVerification,
        builder: (context, state) => const RecruiterVerificationScreen(),
      ),
    ],
  );
});
