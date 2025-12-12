import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class JobApplication {
  final String id;
  final String jobId;
  final String email;
  final String resumeName;
  final DateTime createdAt;
  String status; // 'In Progress', 'Selected', 'Rejected'
  final String? resumeData; // Base64 encoded resume data for download

  JobApplication({
    required this.id,
    required this.jobId,
    required this.email,
    required this.resumeName,
    required this.createdAt,
    this.status = 'In Progress',
    this.resumeData,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      email: json['email'] as String,
      resumeName: json['resume_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'In Progress',
      resumeData: json['resume_data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'email': email,
      'resume_name': resumeName,
      'status': status,
      'resume_data': resumeData,
      // 'created_at': createdAt.toIso8601String(), // Let DB handle creation time
    };
  }
}

class InternshipApplication {
  final String id;
  final String internshipId;
  final String email;
  final String resumeName;
  final DateTime createdAt;
  String status; // 'In Progress', 'Selected', 'Rejected'
  final String? resumeData; // Base64 encoded resume data for download

  InternshipApplication({
    required this.id,
    required this.internshipId,
    required this.email,
    required this.resumeName,
    required this.createdAt,
    this.status = 'In Progress',
    this.resumeData,
  });

  factory InternshipApplication.fromJson(Map<String, dynamic> json) {
    return InternshipApplication(
      id: json['id'] as String,
      internshipId: json['internship_id'] as String,
      email: json['email'] as String,
      resumeName: json['resume_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'In Progress',
      resumeData: json['resume_data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'internship_id': internshipId,
      'email': email,
      'resume_name': resumeName,
      'status': status,
      'resume_data': resumeData,
      // 'created_at': createdAt.toIso8601String(),
    };
  }
}

class ApplicationStore extends ChangeNotifier {
  ApplicationStore._internal();
  static final ApplicationStore I = ApplicationStore._internal();

  List<JobApplication> _jobApps = [];
  List<InternshipApplication> _internApps = [];
  bool _isLoading = false;

  List<JobApplication> get jobApplications => List.unmodifiable(_jobApps);
  List<InternshipApplication> get internshipApplications => List.unmodifiable(_internApps);
  bool get isLoading => _isLoading;

  Future<void> fetchApplications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final jobAppsResponse = await SupabaseConfig.client
          .from('job_applications')
          .select()
          .order('created_at', ascending: false);
      _jobApps = (jobAppsResponse as List).map((e) => JobApplication.fromJson(e)).toList();

      final internAppsResponse = await SupabaseConfig.client
          .from('internship_applications')
          .select()
          .order('created_at', ascending: false);
      _internApps = (internAppsResponse as List).map((e) => InternshipApplication.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching applications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addJobApplication(JobApplication a) async {
    try {
      // Try insert with select first
      try {
        final response = await SupabaseConfig.client
            .from('job_applications')
            .insert(a.toJson())
            .select()
            .single();
        _jobApps.insert(0, JobApplication.fromJson(response));
        notifyListeners();
      } catch (selectError) {
        // If select fails (RLS may prevent reading), try insert only
        await SupabaseConfig.client
            .from('job_applications')
            .insert(a.toJson());
        // Application was inserted successfully, just can't read it back
        debugPrint('Job application inserted (without read-back due to RLS)');
      }
    } catch (e) {
      debugPrint('Error adding job application: $e');
      rethrow;
    }
  }

  Future<void> addInternshipApplication(InternshipApplication a) async {
    try {
      // Try insert with select first
      try {
        final response = await SupabaseConfig.client
            .from('internship_applications')
            .insert(a.toJson())
            .select()
            .single();
        _internApps.insert(0, InternshipApplication.fromJson(response));
        notifyListeners();
      } catch (selectError) {
        // If select fails (RLS may prevent reading), try insert only
        await SupabaseConfig.client
            .from('internship_applications')
            .insert(a.toJson());
        // Application was inserted successfully, just can't read it back
        debugPrint('Internship application inserted (without read-back due to RLS)');
      }
    } catch (e) {
      debugPrint('Error adding internship application: $e');
      rethrow;
    }
  }

  Future<void> updateJobApplicationStatus(String email, String jobId, String newStatus) async {
    try {
      // Find the application ID first (since we were using email+jobId as key previously)
      final app = _jobApps.firstWhere((a) => a.email == email && a.jobId == jobId);
      
      await SupabaseConfig.client
          .from('job_applications')
          .update({'status': newStatus})
          .eq('id', app.id);

      app.status = newStatus;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating job application status: $e');
    }
  }

  Future<void> updateInternshipApplicationStatus(String email, String internshipId, String newStatus) async {
    try {
      final app = _internApps.firstWhere((a) => a.email == email && a.internshipId == internshipId);
      
      await SupabaseConfig.client
          .from('internship_applications')
          .update({'status': newStatus})
          .eq('id', app.id);

      app.status = newStatus;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating internship application status: $e');
    }
  }

  Future<bool> deleteJobApplication(String email, String jobId) async {
    try {
      final app = _jobApps.firstWhere((a) => a.email == email && a.jobId == jobId);
      await SupabaseConfig.client.from('job_applications').delete().eq('id', app.id);
      _jobApps.remove(app);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting job application: $e');
      return false;
    }
  }

  Future<bool> deleteInternshipApplication(String email, String internshipId) async {
    try {
      final app = _internApps.firstWhere((a) => a.email == email && a.internshipId == internshipId);
      await SupabaseConfig.client.from('internship_applications').delete().eq('id', app.id);
      _internApps.remove(app);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting internship application: $e');
      return false;
    }
  }

  void clear() {
    _jobApps.clear();
    _internApps.clear();
    notifyListeners();
  }
}
