import 'package:flutter/foundation.dart';

class JobPost {
  final String id; // HR-defined or auto-generated
  final String title;
  final String description;
  final String location; // city/country
  final String contractType; // Full-Time, Part-Time, Contract
  final String department;
  final String postingDate; // display-friendly, e.g., 2025-10-09
  final String applicationDeadline; // display-friendly date
  final String experience; // e.g., 3-5 years
  final List<String> skills; // parsed from comma-separated input
  final List<String> responsibilities;
  final List<String> qualifications;

  const JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.contractType,
    required this.department,
    required this.postingDate,
    required this.applicationDeadline,
    required this.experience,
    required this.skills,
    required this.responsibilities,
    required this.qualifications,
  });
}

class InternshipPost {
  final String id; // HR-defined or auto-generated
  final String title;
  final String skill;
  final String qualification;
  final String duration;
  final String description;
  final String location;
  final String contractType; // Full-Time, Part-Time, Contract, Intern
  final String postingDate; // display-friendly date string

  const InternshipPost({
    required this.id,
    required this.title,
    required this.skill,
    required this.qualification,
    required this.duration,
    required this.description,
    required this.location,
    required this.contractType,
    required this.postingDate,
  });
}

/// Simple in-memory store to simulate HR uploads adding posts.
/// Newest posts are inserted at index 0 to render first.
class PostStore extends ChangeNotifier {
  PostStore._internal();
  static final PostStore I = PostStore._internal();

  final List<JobPost> _jobs = <JobPost>[];
  final List<InternshipPost> _internships = <InternshipPost>[];

  List<JobPost> get jobs => List.unmodifiable(_jobs);
  List<InternshipPost> get internships => List.unmodifiable(_internships);

  void addJob(JobPost post) {
    _jobs.insert(0, post); // newest first
    notifyListeners();
  }

  JobPost? getJobById(String id) {
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  bool deleteJob(String id) {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx >= 0) {
      _jobs.removeAt(idx);
      notifyListeners();
      return true;
    }
    return false;
  }

  void addInternship(InternshipPost post) {
    _internships.insert(0, post); // newest first
    notifyListeners();
  }

  InternshipPost? getInternshipById(String id) {
    try {
      return _internships.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  bool deleteInternship(String id) {
    final idx = _internships.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      _internships.removeAt(idx);
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearAll() {
    _jobs.clear();
    _internships.clear();
    notifyListeners();
  }
}
