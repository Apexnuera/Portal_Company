import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/home'),
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/login/employee', builder: (_, __) => const EmployeeLoginPage()),
        GoRoute(path: '/login/hr', builder: (_, __) => const HRLoginPage()),
        GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordPage()),
        GoRoute(path: '/campus-commune', builder: (_, __) => const CampusCommunePage()),
        GoRoute(path: '/help-support', builder: (_, __) => const HelpSupportPage()),
        GoRoute(path: '/jobs', builder: (_, __) => const JobsListingPage()),
        GoRoute(path: '/internships', builder: (_, __) => const InternshipsListingPage()),
        GoRoute(path: '/register/employee', builder: (_, __) => const EmployeeRegistrationPage()),
        // Optional legacy/placeholder routes
        GoRoute(path: '/alerts', builder: (_, __) => const AlertsPage()),
        GoRoute(path: '/buzz', builder: (_, __) => const BuzzPage()),
      ],
    );

    return MaterialApp.router(
      title: 'Company Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF782B)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
