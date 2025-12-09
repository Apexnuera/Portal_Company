import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class JobPost {
  final String id;
  final String? referenceCode; // HR-friendly reference like "JOB-2024-001"
  final String title;
  final String description;
  final String location;
  final String contractType;
  final String department;
  final String postingDate;
  final String applicationDeadline;
  final String experience;
  final List<String> skills;
  final List<String> responsibilities;
  final List<String> qualifications;

  const JobPost({
    required this.id,
    this.referenceCode,
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

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'] as String,
      referenceCode: json['reference_code'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      contractType: json['contract_type'] as String,
      department: json['department'] as String,
      postingDate: json['posting_date'] as String,
      applicationDeadline: json['application_deadline'] as String,
      experience: json['experience'] as String,
      skills: List<String>.from(json['skills'] ?? []),
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      qualifications: List<String>.from(json['qualifications'] ?? []),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = {
      'title': title,
      'description': description,
      'location': location,
      'contract_type': contractType,
      'department': department,
      'posting_date': postingDate,
      'application_deadline': applicationDeadline,
      'experience': experience,
      'skills': skills,
      'responsibilities': responsibilities,
      'qualifications': qualifications,
    };
    
    // Only include reference_code if it's not null
    if (referenceCode != null) {
      map['reference_code'] = referenceCode!;
    }
    
    if (includeId) {
      map['id'] = id;
    }
    return map;
  }
}

class InternshipPost {
  final String id;
  final String? referenceCode; // HR-friendly reference like "INT-2024-001"
  final String title;
  final String skill;
  final String qualification;
  final String duration;
  final String description;
  final String location;
  final String contractType;
  final String postingDate;

  const InternshipPost({
    required this.id,
    this.referenceCode,
    required this.title,
    required this.skill,
    required this.qualification,
    required this.duration,
    required this.description,
    required this.location,
    required this.contractType,
    required this.postingDate,
  });

  factory InternshipPost.fromJson(Map<String, dynamic> json) {
    return InternshipPost(
      id: json['id'] as String,
      referenceCode: json['reference_code'] as String?,
      title: json['title'] as String,
      skill: json['skill'] as String,
      qualification: json['qualification'] as String,
      duration: json['duration'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      contractType: json['contract_type'] as String,
      postingDate: json['posting_date'] as String,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = {
      'title': title,
      'skill': skill,
      'qualification': qualification,
      'duration': duration,
      'description': description,
      'location': location,
      'contract_type': contractType,
      'posting_date': postingDate,
    };
    
    // Only include reference_code if it's not null
    if (referenceCode != null) {
      map['reference_code'] = referenceCode!;
    }
    
    if (includeId) {
      map['id'] = id;
    }
    return map;
  }
}

class PostStore extends ChangeNotifier {
  PostStore._internal();
  static final PostStore I = PostStore._internal();

  List<JobPost> _jobs = [];
  List<InternshipPost> _internships = [];
  bool _isLoading = false;

  List<JobPost> get jobs => List.unmodifiable(_jobs);
  List<InternshipPost> get internships => List.unmodifiable(_internships);
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final jobsResponse = await SupabaseConfig.client
          .from('jobs')
          .select()
          .order('created_at', ascending: false);
      _jobs = (jobsResponse as List).map((e) => JobPost.fromJson(e)).toList();

      final internshipsResponse = await SupabaseConfig.client
          .from('internships')
          .select()
          .order('created_at', ascending: false);
      _internships = (internshipsResponse as List).map((e) => InternshipPost.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addJob(JobPost post) async {
    try {
      final response = await SupabaseConfig.client
          .from('jobs')
          .insert(post.toJson())
          .select()
          .single();
      _jobs.insert(0, JobPost.fromJson(response));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding job: $e');
      rethrow;
    }
  }

  Future<void> updateJob(JobPost post) async {
    try {
      final response = await SupabaseConfig.client
          .from('jobs')
          .update(post.toJson(includeId: false))
          .eq('id', post.id)
          .select()
          .single();
      
      final index = _jobs.indexWhere((j) => j.id == post.id);
      if (index != -1) {
        _jobs[index] = JobPost.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating job: $e');
      rethrow;
    }
  }

  Future<bool> deleteJob(String id) async {
    try {
      await SupabaseConfig.client.from('jobs').delete().eq('id', id);
      _jobs.removeWhere((j) => j.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting job: $e');
      return false;
    }
  }

  Future<void> addInternship(InternshipPost post) async {
    try {
      final response = await SupabaseConfig.client
          .from('internships')
          .insert(post.toJson())
          .select()
          .single();
      _internships.insert(0, InternshipPost.fromJson(response));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding internship: $e');
      rethrow;
    }
  }

  Future<void> updateInternship(InternshipPost post) async {
    try {
      final response = await SupabaseConfig.client
          .from('internships')
          .update(post.toJson(includeId: false))
          .eq('id', post.id)
          .select()
          .single();
      
      final index = _internships.indexWhere((i) => i.id == post.id);
      if (index != -1) {
        _internships[index] = InternshipPost.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating internship: $e');
      rethrow;
    }
  }

  Future<bool> deleteInternship(String id) async {
    try {
      await SupabaseConfig.client.from('internships').delete().eq('id', id);
      _internships.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting internship: $e');
      return false;
    }
  }

  JobPost? getJobById(String id) {
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  InternshipPost? getInternshipById(String id) {
    try {
      return _internships.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearAll() {
    _jobs.clear();
    _internships.clear();
    notifyListeners();
  }
}
