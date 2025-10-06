import 'package:flutter/material.dart';
import 'homepage.dart';
import 'alerts_page.dart';
import 'campus_commune_page.dart';
import 'buzz_page.dart';
import 'help_support_page.dart';
import 'login_page.dart';
import 'employee_login_page.dart';
import 'hr_login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Company Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF782B)),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/alerts': (context) => const AlertsPage(),
        '/campus-commune': (context) => const CampusCommunePage(),
        '/buzz': (context) => const BuzzPage(),
        '/help-support': (context) => const HelpSupportPage(),
        '/login': (context) => const LoginPage(),
        '/login/employee': (context) => const EmployeeLoginPage(),
        '/login/hr': (context) => const HRLoginPage(),
      },
    );
  }
}
