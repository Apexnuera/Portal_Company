import 'package:flutter/foundation.dart';

class JobApplication {
  final String jobId;
  final String email;
  final String resumeName;
  final DateTime createdAt;

  const JobApplication({
    required this.jobId,
    required this.email,
    required this.resumeName,
    required this.createdAt,
  });
}

class InternshipApplication {
  final String internshipId;
  final String email;
  final String resumeName;
  final DateTime createdAt;

  const InternshipApplication({
    required this.internshipId,
    required this.email,
    required this.resumeName,
    required this.createdAt,
  });
}

/// Simple in-memory application store for HR review.
class ApplicationStore extends ChangeNotifier {
  ApplicationStore._internal();
  static final ApplicationStore I = ApplicationStore._internal();

  final List<JobApplication> _jobApps = <JobApplication>[];
  final List<InternshipApplication> _internApps = <InternshipApplication>[];

  List<JobApplication> get jobApplications => List.unmodifiable(_jobApps);
  List<InternshipApplication> get internshipApplications => List.unmodifiable(_internApps);

  void addJobApplication(JobApplication a) {
    _jobApps.insert(0, a);
    notifyListeners();
  }

  void addInternshipApplication(InternshipApplication a) {
    _internApps.insert(0, a);
    notifyListeners();
  }

  void clear() {
    _jobApps.clear();
    _internApps.clear();
    notifyListeners();
  }
}
