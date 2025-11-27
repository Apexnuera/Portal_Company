import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing Jobs and Internships in Supabase
class HRPostsService {
  static final HRPostsService instance = HRPostsService._();
  HRPostsService._();

  final _supabase = Supabase.instance.client;

  // ============================================================================
  // JOBS
  // ============================================================================

  /// Create a new job posting
  Future<Map<String, dynamic>?> createJob({
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
      final response = await _supabase
          .from('jobs')
          .insert({
            'id': id,
            'title': title,
            'location': location,
            'contract_type': contractType,
            'department': department,
            'posting_date': postingDate,
            'application_deadline': applicationDeadline,
            'experience': experience,
            'skills': skills,
            'responsibilities': responsibilities,
            'qualifications': qualifications,
            'description': description,
            'created_by': _supabase.auth.currentUser?.id,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating job: $e');
      return null;
    }
  }

  /// Get all jobs
  Future<List<Map<String, dynamic>>> getAllJobs() async {
    try {
      final response = await _supabase
          .from('jobs')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }

  /// Get a single job by ID
  Future<Map<String, dynamic>?> getJob(String id) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Error fetching job: $e');
      return null;
    }
  }

  /// Update a job
  Future<bool> updateJob(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('jobs').update(updates).eq('id', id);
      return true;
    } catch (e) {
      print('Error updating job: $e');
      return false;
    }
  }

  /// Delete a job
  Future<bool> deleteJob(String id) async {
    try {
      await _supabase.from('jobs').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting job: $e');
      return false;
    }
  }

  // ============================================================================
  // INTERNSHIPS
  // ============================================================================

  /// Create a new internship posting
  Future<Map<String, dynamic>?> createInternship({
    required String id,
    required String title,
    required String duration,
    required String skill,
    required String qualification,
    required String description,
    required String postingDate,
  }) async {
    try {
      final response = await _supabase
          .from('internships')
          .insert({
            'id': id,
            'title': title,
            'duration': duration,
            'skill': skill,
            'qualification': qualification,
            'description': description,
            'posting_date': postingDate,
            'created_by': _supabase.auth.currentUser?.id,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating internship: $e');
      return null;
    }
  }

  /// Get all internships
  Future<List<Map<String, dynamic>>> getAllInternships() async {
    try {
      final response = await _supabase
          .from('internships')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching internships: $e');
      return [];
    }
  }

  /// Get a single internship by ID
  Future<Map<String, dynamic>?> getInternship(String id) async {
    try {
      final response = await _supabase
          .from('internships')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Error fetching internship: $e');
      return null;
    }
  }

  /// Update an internship
  Future<bool> updateInternship(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('internships').update(updates).eq('id', id);
      return true;
    } catch (e) {
      print('Error updating internship: $e');
      return false;
    }
  }

  /// Delete an internship
  Future<bool> deleteInternship(String id) async {
    try {
      await _supabase.from('internships').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting internship: $e');
      return false;
    }
  }

  // ============================================================================
  // JOB APPLICATIONS
  // ============================================================================

  /// Create a job application
  Future<Map<String, dynamic>?> createJobApplication({
    required String jobId,
    required String email,
    required String resumeName,
    String? resumeData,
  }) async {
    try {
      final response = await _supabase
          .from('job_applications')
          .insert({
            'job_id': jobId,
            'email': email,
            'resume_name': resumeName,
            'resume_data': resumeData,
            'status': 'In Progress',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating job application: $e');
      return null;
    }
  }

  /// Get all job applications
  Future<List<Map<String, dynamic>>> getAllJobApplications() async {
    try {
      final response = await _supabase
          .from('job_applications')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching job applications: $e');
      return [];
    }
  }

  /// Get job applications for a specific job
  Future<List<Map<String, dynamic>>> getJobApplicationsByJobId(
    String jobId,
  ) async {
    try {
      final response = await _supabase
          .from('job_applications')
          .select()
          .eq('job_id', jobId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching job applications: $e');
      return [];
    }
  }

  /// Update job application status
  Future<bool> updateJobApplicationStatus(
    String jobId,
    String email,
    String status,
  ) async {
    try {
      await _supabase
          .from('job_applications')
          .update({'status': status})
          .eq('job_id', jobId)
          .eq('email', email);
      return true;
    } catch (e) {
      print('Error updating job application status: $e');
      return false;
    }
  }

  /// Delete a job application
  Future<bool> deleteJobApplication(String jobId, String email) async {
    try {
      await _supabase
          .from('job_applications')
          .delete()
          .eq('job_id', jobId)
          .eq('email', email);
      return true;
    } catch (e) {
      print('Error deleting job application: $e');
      return false;
    }
  }

  // ============================================================================
  // INTERNSHIP APPLICATIONS
  // ============================================================================

  /// Create an internship application
  Future<Map<String, dynamic>?> createInternshipApplication({
    required String internshipId,
    required String email,
    required String resumeName,
    String? resumeData,
  }) async {
    try {
      final response = await _supabase
          .from('internship_applications')
          .insert({
            'internship_id': internshipId,
            'email': email,
            'resume_name': resumeName,
            'resume_data': resumeData,
            'status': 'In Progress',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating internship application: $e');
      return null;
    }
  }

  /// Get all internship applications
  Future<List<Map<String, dynamic>>> getAllInternshipApplications() async {
    try {
      final response = await _supabase
          .from('internship_applications')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching internship applications: $e');
      return [];
    }
  }

  /// Get internship applications for a specific internship
  Future<List<Map<String, dynamic>>> getInternshipApplicationsByInternshipId(
    String internshipId,
  ) async {
    try {
      final response = await _supabase
          .from('internship_applications')
          .select()
          .eq('internship_id', internshipId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching internship applications: $e');
      return [];
    }
  }

  /// Update internship application status
  Future<bool> updateInternshipApplicationStatus(
    String internshipId,
    String email,
    String status,
  ) async {
    try {
      await _supabase
          .from('internship_applications')
          .update({'status': status})
          .eq('internship_id', internshipId)
          .eq('email', email);
      return true;
    } catch (e) {
      print('Error updating internship application status: $e');
      return false;
    }
  }

  /// Delete an internship application
  Future<bool> deleteInternshipApplication(
    String internshipId,
    String email,
  ) async {
    try {
      await _supabase
          .from('internship_applications')
          .delete()
          .eq('internship_id', internshipId)
          .eq('email', email);
      return true;
    } catch (e) {
      print('Error deleting internship application: $e');
      return false;
    }
  }

  // ============================================================================
  // REALTIME SUBSCRIPTIONS (Optional)
  // ============================================================================

  /// Subscribe to jobs changes
  StreamSubscription<List<Map<String, dynamic>>> subscribeToJobs(
    Function(List<Map<String, dynamic>>) onData,
  ) {
    return _supabase
        .from('jobs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
          onData(data);
        });
  }

  /// Subscribe to internships changes
  StreamSubscription<List<Map<String, dynamic>>> subscribeToInternships(
    Function(List<Map<String, dynamic>>) onData,
  ) {
    return _supabase
        .from('internships')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
          onData(data);
        });
  }

  /// Subscribe to job applications changes
  StreamSubscription<List<Map<String, dynamic>>> subscribeToJobApplications(
    Function(List<Map<String, dynamic>>) onData,
  ) {
    return _supabase
        .from('job_applications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
          onData(data);
        });
  }

  /// Subscribe to internship applications changes
  StreamSubscription<List<Map<String, dynamic>>>
  subscribeToInternshipApplications(
    Function(List<Map<String, dynamic>>) onData,
  ) {
    return _supabase
        .from('internship_applications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
          onData(data);
        });
  }
}
