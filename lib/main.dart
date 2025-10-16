import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'pages/homepage_clean.dart';
import 'alerts_page.dart';
import 'campus_commune_page.dart';
import 'buzz_page.dart';
import 'help_support_page.dart';
import 'pages/login_page_clean.dart';
import 'employee_login_page.dart';
import 'pages/hr_login_page_clean.dart';
import 'pages/change_password_page_clean.dart';
import 'jobs_listing_page.dart';
import 'internships_listing_page.dart';
import 'employee_registration_page.dart';
import 'pages/otp_method_login_page.dart';
import 'pages/job_details_page.dart';
import 'pages/job_application_form_page.dart';
import 'pages/job_application_success_page.dart';
import 'pages/internship_details_page.dart';
import 'pages/hr_dashboard_page.dart';
import 'pages/hr_post_job_page.dart';
import 'pages/hr_post_internship_page.dart';
import 'pages/employee_dashboard_page.dart';
import 'services/auth_service.dart';
import 'state/employee_directory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/home',
      refreshListenable: AuthService.instance,
      redirect: (context, state) {
        // Protect HR routes
        final goingToHR = state.matchedLocation.startsWith('/hr');
        if (goingToHR && !AuthService.instance.isHRLoggedIn) {
          return '/login/hr';
        }

        // Protect Employee routes
        final goingToEmployee = state.matchedLocation.startsWith('/employee');
        if (goingToEmployee && !AuthService.instance.isEmployeeLoggedIn) {
          return '/login/employee';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/home'),
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/login/employee', builder: (_, __) => const EmployeeLoginPage()),
        GoRoute(path: '/login/hr', builder: (_, __) => const HRLoginPage()),
        GoRoute(path: '/login/otp-method', builder: (_, __) => const OTPMethodLoginPage()),
        GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordPage()),
        GoRoute(path: '/campus-commune', builder: (_, __) => const CampusCommunePage()),
        GoRoute(
          path: '/help-support',
          builder: (_, state) => HelpSupportPage(
            initialDescription: state.uri.queryParameters['desc'],
          ),
        ),
        GoRoute(path: '/jobs', builder: (_, __) => const JobsListingPage()),
        GoRoute(
          path: '/jobs/:jobId',
          builder: (_, state) => JobDetailsPage(jobId: state.pathParameters['jobId']!),
        ),
        GoRoute(
          path: '/jobs/apply/:jobId',
          builder: (_, state) => JobApplicationFormPage(jobId: state.pathParameters['jobId']!),
        ),
        GoRoute(
          path: '/jobs/apply/:jobId/success',
          builder: (_, state) => JobApplicationSuccessPage(jobId: state.pathParameters['jobId']!),
        ),
        GoRoute(path: '/internships', builder: (_, __) => const InternshipsListingPage()),
        GoRoute(
          path: '/internships/:internshipId',
          builder: (_, state) => InternshipDetailsPage(internshipId: state.pathParameters['internshipId']!),
        ),
        GoRoute(path: '/register/employee', builder: (_, __) => const EmployeeRegistrationPage()),
        // Employee routes (protected by redirect)
        GoRoute(path: '/employee/dashboard', builder: (_, __) => const EmployeeDashboardPage()),
        // HR routes (protected by redirect)
        GoRoute(path: '/hr/dashboard', builder: (_, __) => HRDashboardPage()),
        GoRoute(path: '/hr/post/job', builder: (_, __) => HRPostJobPage()),
        GoRoute(path: '/hr/post/internship', builder: (_, __) => HRPostInternshipPage()),
        // Optional legacy/placeholder routes
        GoRoute(path: '/alerts', builder: (_, __) => const AlertsPage()),
        GoRoute(path: '/buzz', builder: (_, __) => const BuzzPage()),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EmployeeDirectory>(
          create: (_) => EmployeeDirectory(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Company Portal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF782B)),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
