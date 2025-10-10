import 'package:flutter/foundation.dart';

class JobApplication {
  final String jobId;
  final String email;
  final String resumeName;
  final DateTime createdAt;
  String status; // 'In Progress', 'Selected', 'Rejected'
  final String? resumeData; // Base64 encoded resume data for download

  JobApplication({
    required this.jobId,
    required this.email,
    required this.resumeName,
    required this.createdAt,
    this.status = 'In Progress',
    this.resumeData,
  });
}

class InternshipApplication {
  final String internshipId;
  final String email;
  final String resumeName;
  final DateTime createdAt;
  String status; // 'In Progress', 'Selected', 'Rejected'
  final String? resumeData; // Base64 encoded resume data for download

  InternshipApplication({
    required this.internshipId,
    required this.email,
    required this.resumeName,
    required this.createdAt,
    this.status = 'In Progress',
    this.resumeData,
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

  void updateJobApplicationStatus(String email, String jobId, String newStatus) {
    final index = _jobApps.indexWhere((a) => a.email == email && a.jobId == jobId);
    if (index != -1) {
      _jobApps[index].status = newStatus;
      notifyListeners();
    }
  }

  void updateInternshipApplicationStatus(String email, String internshipId, String newStatus) {
    final index = _internApps.indexWhere((a) => a.email == email && a.internshipId == internshipId);
    if (index != -1) {
      _internApps[index].status = newStatus;
      notifyListeners();
    }
  }

  bool deleteJobApplication(String email, String jobId) {
    final index = _jobApps.indexWhere((a) => a.email == email && a.jobId == jobId);
    if (index != -1) {
      _jobApps.removeAt(index);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool deleteInternshipApplication(String email, String internshipId) {
    final index = _internApps.indexWhere((a) => a.email == email && a.internshipId == internshipId);
    if (index != -1) {
      _internApps.removeAt(index);
      notifyListeners();
      return true;
    }
    return false;
  }

  void clear() {
    _jobApps.clear();
    _internApps.clear();
    notifyListeners();
  }
}
