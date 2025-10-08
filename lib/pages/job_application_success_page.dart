import 'package:flutter/material.dart';
import '../widgets/app_header_clean.dart';

class JobApplicationSuccessPage extends StatelessWidget {
  final String jobId;
  const JobApplicationSuccessPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 56),
                        SizedBox(height: 12),
                        Text(
                          'Application Successfully Submitted!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Thank you for applying. Our team will review your resume and get back to you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
