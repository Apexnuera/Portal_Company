import 'package:flutter/foundation.dart';
import 'hr_posts_service.dart';

/// Supabase-backed store for managing Jobs, Internships, and Applications
/// This replaces the in-memory PostStore and ApplicationStore
class SupabaseHRStore extends ChangeNotifier {
  static final SupabaseHRStore instance = SupabaseHRStore._();
  SupabaseHRStore._();

  final _service = HRPostsService.instance;

  // State
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _internships = [];
  List<Map<String, dynamic>> _jobApplications = [];
  List<Map<String, dynamic>> _internshipApplications = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get jobs => _jobs;
  List<Map<String, dynamic>> get internships => _internships;
  List<Map<String, dynamic>> get jobApplications => _jobApplications;
  List<Map<String, dynamic>> get internshipApplications =>
      _internshipApplications;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize and load all data from Supabase
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadJobs(),
        loadInternships(),
        loadJobApplications(),
        loadInternshipApplications(),
      ]);
    } catch (e) {
      _error = 'Failed to initialize: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // JOBS
  // ============================================================================

  /// Load all jobs from Supabase
  Future<void> loadJobs() async {
    try {
      _jobs = await _service.getAllJobs();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load jobs: $e';
      print(_error);
    }
  }

  /// Create a new job
  Future<bool> createJob({
    required String id,
    required String title,
    required String location,
    required String contractType,
    required String department,
    required String postingDate,
    required String applicationDeadline,
    required String experience,
    required List<String> skills,
    required List<String> responsibilities,
    required List<String> qualifications,
    required String description,
  }) async {
    try {
      final result = await _service.createJob(
        id: id,
        title: title,
        location: location,
        contractType: contractType,
        department: department,
        postingDate: postingDate,
        applicationDeadline: applicationDeadline,
        experience: experience,
        skills: skills,
        responsibilities: responsibilities,
        qualifications: qualifications,
        description: description,
      );

      if (result != null) {
        _jobs.insert(0, result);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to create job: $e';
      print(_error);
      return false;
    }
  }

  /// Update a job
  Future<bool> updateJob(String id, Map<String, dynamic> updates) async {
    try {
      final success = await _service.updateJob(id, updates);
      if (success) {
        await loadJobs();
      }
      return success;
    } catch (e) {
      _error = 'Failed to update job: $e';
      print(_error);
      return false;
    }
  }

  /// Delete a job
  Future<bool> deleteJob(String id) async {
    try {
      final success = await _service.deleteJob(id);
      if (success) {
        _jobs.removeWhere((job) => job['id'] == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete job: $e';
      print(_error);
      return false;
    }
  }

  // ============================================================================
  // INTERNSHIPS
  // ============================================================================

  /// Load all internships from Supabase
  Future<void> loadInternships() async {
    try {
      _internships = await _service.getAllInternships();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load internships: $e';
      print(_error);
    }
  }

  /// Create a new internship
  Future<bool> createInternship({
    required String id,
    required String title,
    required String duration,
    required String skill,
    required String qualification,
    required String description,
    required String postingDate,
  }) async {
    try {
      final result = await _service.createInternship(
        id: id,
        title: title,
        duration: duration,
        skill: skill,
        qualification: qualification,
        description: description,
        postingDate: postingDate,
      );

      if (result != null) {
        _internships.insert(0, result);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to create internship: $e';
      print(_error);
      return false;
    }
  }

  /// Update an internship
  Future<bool> updateInternship(String id, Map<String, dynamic> updates) async {
    try {
      final success = await _service.updateInternship(id, updates);
      if (success) {
        await loadInternships();
      }
      return success;
    } catch (e) {
      _error = 'Failed to update internship: $e';
      print(_error);
      return false;
    }
  }

  /// Delete an internship
  Future<bool> deleteInternship(String id) async {
    try {
      final success = await _service.deleteInternship(id);
      if (success) {
        _internships.removeWhere((internship) => internship['id'] == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete internship: $e';
      print(_error);
      return false;
    }
  }

  // ============================================================================
  // JOB APPLICATIONS
  // ============================================================================

  /// Load all job applications
  Future<void> loadJobApplications() async {
    try {
      _jobApplications = await _service.getAllJobApplications();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load job applications: $e';
      print(_error);
    }
  }

  /// Create a job application
  Future<bool> createJobApplication({
    required String jobId,
    required String email,
    required String resumeName,
    String? resumeData,
  }) async {
    try {
      final result = await _service.createJobApplication(
        jobId: jobId,
        email: email,
        resumeName: resumeName,
        resumeData: resumeData,
      );

      if (result != null) {
        _jobApplications.insert(0, result);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to create job application: $e';
      print(_error);
      return false;
    }
  }

  /// Update job application status
  Future<bool> updateJobApplicationStatus(
    String jobId,
    String email,
    String status,
  ) async {
    try {
      final success = await _service.updateJobApplicationStatus(
        jobId,
        email,
        status,
      );
      if (success) {
        final index = _jobApplications.indexWhere(
          (app) => app['job_id'] == jobId && app['email'] == email,
        );
        if (index != -1) {
          _jobApplications[index]['status'] = status;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to update job application status: $e';
      print(_error);
      return false;
    }
  }

  /// Delete a job application
  Future<bool> deleteJobApplication(String jobId, String email) async {
    try {
      final success = await _service.deleteJobApplication(jobId, email);
      if (success) {
        _jobApplications.removeWhere(
          (app) => app['job_id'] == jobId && app['email'] == email,
        );
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete job application: $e';
      print(_error);
      return false;
    }
  }

  // ============================================================================
  // INTERNSHIP APPLICATIONS
  // ============================================================================

  /// Load all internship applications
  Future<void> loadInternshipApplications() async {
    try {
      _internshipApplications = await _service.getAllInternshipApplications();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load internship applications: $e';
      print(_error);
    }
  }

  /// Create an internship application
  Future<bool> createInternshipApplication({
    required String internshipId,
    required String email,
    required String resumeName,
    String? resumeData,
  }) async {
    try {
      final result = await _service.createInternshipApplication(
        internshipId: internshipId,
        email: email,
        resumeName: resumeName,
        resumeData: resumeData,
      );

      if (result != null) {
        _internshipApplications.insert(0, result);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to create internship application: $e';
      print(_error);
      return false;
    }
  }

  /// Update internship application status
  Future<bool> updateInternshipApplicationStatus(
    String internshipId,
    String email,
    String status,
  ) async {
    try {
      final success = await _service.updateInternshipApplicationStatus(
        internshipId,
        email,
        status,
      );
      if (success) {
        final index = _internshipApplications.indexWhere(
          (app) =>
              app['internship_id'] == internshipId && app['email'] == email,
        );
        if (index != -1) {
          _internshipApplications[index]['status'] = status;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to update internship application status: $e';
      print(_error);
      return false;
    }
  }

  /// Delete an internship application
  Future<bool> deleteInternshipApplication(
    String internshipId,
    String email,
  ) async {
    try {
      final success = await _service.deleteInternshipApplication(
        internshipId,
        email,
      );
      if (success) {
        _internshipApplications.removeWhere(
          (app) =>
              app['internship_id'] == internshipId && app['email'] == email,
        );
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete internship application: $e';
      print(_error);
      return false;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get job applications for a specific job
  List<Map<String, dynamic>> getJobApplicationsByJobId(String jobId) {
    return _jobApplications.where((app) => app['job_id'] == jobId).toList();
  }

  /// Get internship applications for a specific internship
  List<Map<String, dynamic>> getInternshipApplicationsByInternshipId(
    String internshipId,
  ) {
    return _internshipApplications
        .where((app) => app['internship_id'] == internshipId)
        .toList();
  }

  /// Get a job by ID
  Map<String, dynamic>? getJobById(String id) {
    try {
      return _jobs.firstWhere((job) => job['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get an internship by ID
  Map<String, dynamic>? getInternshipById(String id) {
    try {
      return _internships.firstWhere((internship) => internship['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }
}
