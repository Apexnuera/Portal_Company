import 'package:flutter/foundation.dart';

class JobPost {
  final String id;
  final String title;
  final String date; // simple string for demo
  final String description;
  final String location;

  const JobPost({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.location,
  });
}

class InternshipPost {
  final String id;
  final String title;
  final String date;
  final String description;
  final String location;

  const InternshipPost({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.location,
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

  void addInternship(InternshipPost post) {
    _internships.insert(0, post); // newest first
    notifyListeners();
  }

  void clearAll() {
    _jobs.clear();
    _internships.clear();
    notifyListeners();
  }
}
