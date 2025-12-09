import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../state/employee_directory.dart';
import 'auth_service.dart';

/// Comprehensive service for managing employee profiles
/// Handles personal details, professional profile, education, employment history, and compensation
class EmployeeProfileService extends ChangeNotifier {
  EmployeeProfileService._internal();
  static final EmployeeProfileService instance = EmployeeProfileService._internal();

  bool _isLoading = false;
  String? _error;
  String? _currentEmployeeProfileId; // The database UUID for current employee profile
  EmployeeRecord? _currentProfile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  EmployeeRecord? get currentProfile => _currentProfile;

  /// Initialize and load current user's profile
  Future<void> initialize() async {
    debugPrint('EmployeeProfileService: Initializing...');
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) {
      debugPrint('EmployeeProfileService: No user logged in');
      return;
    }

    await loadCurrentUserProfile();
  }

  /// Load the current logged-in user's profile from Supabase
  Future<void> loadCurrentUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      debugPrint('Loading profile for user: ${user.id}');

      // Fetch employee profile
      final response = await SupabaseConfig.client
          .from('employee_profiles')
          .select()
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint('No profile found for user');
        _currentProfile = null;
        _currentEmployeeProfileId = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint('Profile data: $response');
      _currentEmployeeProfileId = response['id'];

      // Convert from Supabase format to EmployeeRecord
      _currentProfile = await _convertToEmployeeRecord(response);

      debugPrint('Profile loaded successfully');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a specific employee's profile by employee_id (for HR use)
  Future<EmployeeRecord?> loadEmployeeProfileById(String employeeId) async {
    try {
      debugPrint('Loading profile for employee: $employeeId');

      // Fetch employee profile by employee_id
      final response = await SupabaseConfig.client
          .from('employee_profiles')
          .select()
          .eq('employee_id', employeeId)
          .maybeSingle();

      if (response == null) {
        debugPrint('No profile found for employee: $employeeId');
        return null;
      }

      debugPrint('Profile data loaded for $employeeId');

      // Convert from Supabase format to EmployeeRecord (includes profile picture download)
      final employeeRecord = await _convertToEmployeeRecord(response);

      debugPrint('Profile loaded successfully for $employeeId');
      return employeeRecord;
    } catch (e) {
      debugPrint('Error loading profile for $employeeId: $e');
      return null;
    }
  }

  /// Create a new employee profile (HR only)
  Future<String?> createEmployeeProfile({
    required String authUserId,
    required String employeeId,
    required String fullName,
    required String corporateEmail,
    String? personalEmail,
  }) async {
    try {
      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser == null) {
        return 'Not authenticated';
      }

      // Verify HR access
      if (AuthService.instance.userRole != 'hr') {
        return 'Unauthorized: HR access required';
      }

      final profileData = {
        'auth_user_id': authUserId,
        'employee_id': employeeId,
        'full_name': fullName,
        'corporate_email': corporateEmail,
        'personal_email': personalEmail ?? '',
        'created_by': currentUser.id,
      };

      final response = await SupabaseConfig.client
          .from('employee_profiles')
          .insert(profileData)
          .select()
          .single();

      debugPrint('Employee profile created: ${response['id']}');
      return null; // Success
    } catch (e) {
      debugPrint('Error creating employee profile: $e');
      return 'Failed to create profile: $e';
    }
  }

  /// Update personal details
  Future<String?> updatePersonalDetails(EmployeePersonalDetails details) async {
    if (_currentEmployeeProfileId == null) {
      return 'No profile loaded';
    }

    try {
      final updates = {
        'full_name': details.fullName,
        'family_name': details.familyName,
        'corporate_email': details.corporateEmail,
        'personal_email': details.personalEmail,
        'mobile_number': details.mobileNumber,
        'alternate_mobile_number': details.alternateMobileNumber,
        'current_address': details.currentAddress,
        'permanent_address': details.permanentAddress,
        'pan_id': details.panId,
        'aadhar_id': details.aadharId,
        'date_of_birth': details.dateOfBirth?.toIso8601String(),
        'blood_group': details.bloodGroup,
        'assigned_assets': details.assignedAssets.toList(),
        'other_assets': details.otherAssets,
        'bank_account_holder_name': details.bankAccountHolderName,
        'bank_account_number': details.bankAccountNumber,
        'bank_ifsc_code': details.bankIfscCode,
        'bank_name': details.bankName,
        'bank_details_locked': details.bankDetailsLocked,
        'current_project_name': details.currentProjectName,
        'current_project_duration': details.currentProjectDuration,
        'current_project_manager': details.currentProjectManager,
      };

      await SupabaseConfig.client
          .from('employee_profiles')
          .update(updates)
          .eq('id', _currentEmployeeProfileId!);

      // Update project history
      await _updateProjectHistory(details.projectHistory);

      // Reload profile
      await loadCurrentUserProfile();

      return null; // Success
    } catch (e) {
      debugPrint('Error updating personal details: $e');
      return 'Failed to update: $e';
    }
  }

  /// Update professional profile
  Future<String?> updateProfessionalProfile(EmployeeProfessionalProfile profile) async {
    if (_currentEmployeeProfileId == null) {
      return 'No profile loaded';
    }

    try {
      final updates = {
        'position': profile.position,
        'department': profile.department,
        'manager_name': profile.managerName,
        'employment_type': profile.employmentType,
        'location': profile.location,
        'work_space': profile.workSpace,
        'job_level': profile.jobLevel,
        'start_date': profile.startDate?.toIso8601String(),
        'confirmation_date': profile.confirmationDate?.toIso8601String(),
        'skills': profile.skills,
      };

      await SupabaseConfig.client
          .from('employee_profiles')
          .update(updates)
          .eq('id', _currentEmployeeProfileId!);

      // Update education entries
      await _updateEducationEntries(profile.education);

      // Update employment history
      await _updateEmploymentHistory(profile.employmentHistory);

      // Reload profile
      await loadCurrentUserProfile();

      return null; // Success
    } catch (e) {
      debugPrint('Error updating professional profile: $e');
      return 'Failed to update: $e';
    }
  }

  /// Update compensation info
  Future<String?> updateCompensation(CompensationInfo compensation) async {
    if (_currentEmployeeProfileId == null) {
      return 'No profile loaded';
    }

    try {
      final updates = {
        'basic_salary': compensation.basic,
        'gross_salary': compensation.gross,
        'net_salary': compensation.net,
        'travel_allowance': compensation.travelAllowance,
      };

      await SupabaseConfig.client
          .from('employee_profiles')
          .update(updates)
          .eq('id', _currentEmployeeProfileId!);

      // Reload profile
      await loadCurrentUserProfile();

      return null; // Success
    } catch (e) {
      debugPrint('Error updating compensation: $e');
      return 'Failed to update: $e';
    }
  }

  /// Update compensation for a specific employee (HR use)
  Future<String?> updateCompensationForEmployee(String employeeId, CompensationInfo compensation) async {
    try {
      debugPrint('Updating compensation for employee: $employeeId');

      final updates = {
        'basic_salary': compensation.basic,
        'gross_salary': compensation.gross,
        'net_salary': compensation.net,
        'travel_allowance': compensation.travelAllowance,
      };

      await SupabaseConfig.client
          .from('employee_profiles')
          .update(updates)
          .eq('employee_id', employeeId);

      debugPrint('Compensation updated successfully for $employeeId');
      return null; // Success
    } catch (e) {
      debugPrint('Error updating compensation for $employeeId: $e');
      return 'Failed to update: $e';
    }
  }

  /// Update tax info
  Future<String?> updateTaxInfo(TaxInfo tax) async {
    if (_currentEmployeeProfileId == null) {
      return 'No profile loaded';
    }

    try {
      final updates = {
        'tax_regime': tax.regime,
      };

      await SupabaseConfig.client
          .from('employee_profiles')
          .update(updates)
          .eq('id', _currentEmployeeProfileId!);

      // Reload profile
      await loadCurrentUserProfile();

      return null; // Success
    } catch (e) {
      debugPrint('Error updating tax info: $e');
      return 'Failed to update: $e';
    }
  }

  /// Upload profile image
  Future<String?> uploadProfileImage(Uint8List imageData, String fileName) async {
    if (_currentEmployeeProfileId == null) {
      return 'No profile loaded';
    }

    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return 'Not authenticated';

      // Upload to storage
      final path = '${user.id}/$fileName';
      await SupabaseConfig.client.storage
          .from('employee-profiles')
          .uploadBinary(path, imageData, fileOptions: FileOptions(upsert: true));

      // Get public URL
      final url = SupabaseConfig.client.storage
          .from('employee-profiles')
          .getPublicUrl(path);

      // Update profile with image URL
      await SupabaseConfig.client
          .from('employee_profiles')
          .update({'profile_image_url': url})
          .eq('id', _currentEmployeeProfileId!);

      // Reload profile
      await loadCurrentUserProfile();

      return null; // Success
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return 'Failed to upload image: $e';
    }
  }

  /// Add compensation document
  Future<String?> addCompensationDocument({
    required String type,
    required String name,
    required Uint8List data,
  }) async {
    if (_currentEmployeeProfileId == null) {
      return 'No profile loaded';
    }

    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return 'Not authenticated';

      // Upload to storage
      final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$name';
      await SupabaseConfig.client.storage
          .from('compensation-docs')
          .uploadBinary(path, data);

      // Get public URL
      final url = SupabaseConfig.client.storage
          .from('compensation-docs')
          .getPublicUrl(path);

      // Insert document record
      await SupabaseConfig.client.from('compensation_documents').insert({
        'employee_profile_id': _currentEmployeeProfileId,
        'document_type': _mapCompensationType(type),
        'document_name': name,
        'document_url': url,
      });

      // Reload profile
      await loadCurrentUserProfile();

      return null; // Success
    } catch (e) {
      debugPrint('Error adding compensation document: $e');
      return 'Failed to add document: $e';
    }
  }

  /// Add compensation document for a specific employee (HR use)
  Future<String?> addCompensationDocumentForEmployee({
    required String employeeId,
    required String type,
    required String name,
    required Uint8List data,
  }) async {
    try {
      debugPrint('Uploading compensation document for employee: $employeeId');

      // Upload to Supabase Storage
      final path = '$employeeId/${DateTime.now().millisecondsSinceEpoch}_$name';
      await SupabaseConfig.client.storage
          .from('compensation-docs')
          .uploadBinary(path, data, fileOptions: FileOptions(upsert: true));

      // Get public URL
      final url = SupabaseConfig.client.storage
          .from('compensation-docs')
          .getPublicUrl(path);

      debugPrint('Document uploaded to: $url');

      // Get employee profile ID
      final profileResponse = await SupabaseConfig.client
          .from('employee_profiles')
          .select('id')
          .eq('employee_id', employeeId)
          .single();

      final profileId = profileResponse['id'];

      // Insert document record
      await SupabaseConfig.client.from('compensation_documents').insert({
        'employee_profile_id': profileId,
        'document_type': _mapCompensationType(type),
        'document_name': name,
        'document_url': url,
      });

      debugPrint('Document record created successfully');
      return null; // Success
    } catch (e) {
      debugPrint('Error adding compensation document for $employeeId: $e');
      return 'Failed to add document: $e';
    }
  }

  /// Delete compensation document
  Future<String?> deleteCompensationDocument(String documentId) async {
    try {
      // Get document info first to delete from storage
      final docResponse = await SupabaseConfig.client
          .from('compensation_documents')
          .select('document_url')
          .eq('id', documentId)
          .single();

      final documentUrl = docResponse['document_url'] as String?;

      // Delete from database
      await SupabaseConfig.client
          .from('compensation_documents')
          .delete()
          .eq('id', documentId);

      // Delete from storage if URL exists
      if (documentUrl != null && documentUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(documentUrl);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('compensation-docs');
          
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
            await SupabaseConfig.client.storage
                .from('compensation-docs')
                .remove([filePath]);
            debugPrint('Deleted file from storage: $filePath');
          }
        } catch (e) {
          debugPrint('Error deleting file from storage: $e');
          // Continue even if storage delete fails
        }
      }

      // Reload profile
      await loadCurrentUserProfile();

      return null; // Success
    } catch (e) {
      debugPrint('Error deleting compensation document: $e');
      return 'Failed to delete document: $e';
    }
  }

  /// Delete compensation document for a specific employee (HR use)
  Future<String?> deleteCompensationDocumentForEmployee({
    required String documentName,
    required String employeeId,
  }) async {
    try {
      debugPrint('Deleting document "$documentName" for employee: $employeeId');

      // Get employee profile ID
      final profileResponse = await SupabaseConfig.client
          .from('employee_profiles')
          .select('id')
          .eq('employee_id', employeeId)
          .single();

      final profileId = profileResponse['id'];

      // Get document info
      final docResponse = await SupabaseConfig.client
          .from('compensation_documents')
          .select('id, document_url')
          .eq('employee_profile_id', profileId)
          .eq('document_name', documentName)
          .single();

      final documentId = docResponse['id'];
      final documentUrl = docResponse['document_url'] as String?;

      // Delete from database
      await SupabaseConfig.client
          .from('compensation_documents')
          .delete()
          .eq('id', documentId);

      // Delete from storage
      if (documentUrl != null && documentUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(documentUrl);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('compensation-docs');
          
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
            await SupabaseConfig.client.storage
                .from('compensation-docs')
                .remove([filePath]);
            debugPrint('Deleted file from storage: $filePath');
          }
        } catch (e) {
          debugPrint('Error deleting file from storage: $e');
        }
      }

      debugPrint('Document deleted successfully');
      return null; // Success
    } catch (e) {
      debugPrint('Error deleting compensation document: $e');
      return 'Failed to delete document: $e';
    }
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  /// Convert Supabase data to EmployeeRecord
  Future<EmployeeRecord> _convertToEmployeeRecord(Map<String, dynamic> data) async {
    final profileId = data['id'];

    // Fetch related data
    final projects = await _fetchProjectHistory(profileId);
    final education = await _fetchEducationEntries(profileId);
    final employment = await _fetchEmploymentHistory(profileId);
    final compensationDocs = await _fetchCompensationDocuments(profileId);

    // Download profile image if URL exists
    Uint8List? profileImageBytes;
    if (data['profile_image_url'] != null && data['profile_image_url'].toString().isNotEmpty) {
      try {
        final imageUrl = data['profile_image_url'] as String;
        debugPrint('Downloading profile image from: $imageUrl');
        
        // Extract path from URL
        // URL format: https://<project>.supabase.co/storage/v1/object/public/employee-profiles/<user_id>/<filename>
        // We need: <user_id>/<filename>
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        
        // Find 'employee-profiles' in path and get everything after it
        final bucketIndex = pathSegments.indexOf('employee-profiles');
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
          debugPrint('Extracted file path: $filePath');
          
          // Download image from Supabase Storage
          final response = await SupabaseConfig.client.storage
              .from('employee-profiles')
              .download(filePath);
          
          profileImageBytes = response;
          debugPrint('Profile image downloaded successfully (${response.length} bytes)');
        } else {
          debugPrint('Could not extract file path from URL');
        }
      } catch (e) {
        debugPrint('Error downloading profile image: $e');
        profileImageBytes = null;
      }
    }

    // Build personal details
    final personal = EmployeePersonalDetails(
      fullName: data['full_name'] ?? '',
      familyName: data['family_name'] ?? '',
      corporateEmail: data['corporate_email'] ?? '',
      personalEmail: data['personal_email'] ?? '',
      mobileNumber: data['mobile_number'] ?? '',
      alternateMobileNumber: data['alternate_mobile_number'] ?? '',
      currentAddress: data['current_address'] ?? '',
      permanentAddress: data['permanent_address'] ?? '',
      panId: data['pan_id'] ?? '',
      aadharId: data['aadhar_id'] ?? '',
      dateOfBirth: data['date_of_birth'] != null ? DateTime.parse(data['date_of_birth']) : null,
      bloodGroup: data['blood_group'] ?? '',
      assignedAssets: (data['assigned_assets'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {},
      otherAssets: data['other_assets'] ?? '',
      profileImageBytes: profileImageBytes, // Now loaded from Supabase!
      bankAccountHolderName: data['bank_account_holder_name'] ?? '',
      bankAccountNumber: data['bank_account_number'] ?? '',
      bankIfscCode: data['bank_ifsc_code'] ?? '',
      bankName: data['bank_name'] ?? '',
      bankDetailsLocked: data['bank_details_locked'] ?? false,
      currentProjectName: data['current_project_name'] ?? '',
      currentProjectDuration: data['current_project_duration'] ?? '',
      currentProjectManager: data['current_project_manager'] ?? '',
      projectHistory: projects,
    );

    // Build professional profile
    final professional = EmployeeProfessionalProfile(
      position: data['position'] ?? '',
      employeeId: data['employee_id'] ?? '',
      department: data['department'] ?? '',
      managerName: data['manager_name'] ?? '',
      employmentType: data['employment_type'] ?? '',
      location: data['location'] ?? '',
      workSpace: data['work_space'] ?? '',
      jobLevel: data['job_level'] ?? '',
      startDate: data['start_date'] != null ? DateTime.parse(data['start_date']) : null,
      confirmationDate: data['confirmation_date'] != null ? DateTime.parse(data['confirmation_date']) : null,
      skills: data['skills'] ?? '',
      education: education,
      employmentHistory: employment,
    );

    // Build compensation info
    final compensation = CompensationInfo(
      basic: (data['basic_salary'] ?? 0).toDouble(),
      gross: (data['gross_salary'] ?? 0).toDouble(),
      net: (data['net_salary'] ?? 0).toDouble(),
      travelAllowance: (data['travel_allowance'] ?? 0).toDouble(),
    );

    // Populate compensation documents
    await _populateCompensationDocuments(compensation, compensationDocs);

    // Build tax info
    final tax = TaxInfo(regime: data['tax_regime'] ?? '');

    // Create employee record
    final record = EmployeeRecord(
      id: data['employee_id'] ?? '',
      name: data['full_name'] ?? '',
      primaryEmail: data['corporate_email'] ?? '',
      personal: personal,
      professional: professional,
    );

    record.compensation = compensation;
    record.tax = tax;

    return record;
  }

  Future<List<ProjectAllocationEntry>> _fetchProjectHistory(String profileId) async {
    try {
      final response = await SupabaseConfig.client
          .from('project_allocations')
          .select()
          .eq('employee_profile_id', profileId)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        return ProjectAllocationEntry(
          projectName: item['project_name'] ?? '',
          duration: item['duration'] ?? '',
          reportingManager: item['reporting_manager'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching project history: $e');
      return [];
    }
  }

  Future<List<EmployeeEducationEntry>> _fetchEducationEntries(String profileId) async {
    try {
      final response = await SupabaseConfig.client
          .from('education_entries')
          .select()
          .eq('employee_profile_id', profileId)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        return EmployeeEducationEntry(
          level: item['level_of_education'] ?? '',
          institution: item['institution'] ?? '',
          degree: item['degree'] ?? '',
          year: item['year'] ?? '',
          grade: item['grade'] ?? '',
          documentName: item['document_name'],
          // Note: documentBytes will be null, download separately if needed
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching education entries: $e');
      return [];
    }
  }

  Future<List<EmployeeEmploymentEntry>> _fetchEmploymentHistory(String profileId) async {
    try {
      final response = await SupabaseConfig.client
          .from('employment_entries')
          .select()
          .eq('employee_profile_id', profileId)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        return EmployeeEmploymentEntry(
          companyName: item['company_name'] ?? '',
          designation: item['designation'] ?? '',
          fromDate: item['from_date'] != null ? DateTime.parse(item['from_date']) : null,
          toDate: item['to_date'] != null ? DateTime.parse(item['to_date']) : null,
          documentName: item['document_name'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching employment history: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCompensationDocuments(String profileId) async {
    try {
      final response = await SupabaseConfig.client
          .from('compensation_documents')
          .select()
          .eq('employee_profile_id', profileId)
          .order('upload_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching compensation documents: $e');
      return [];
    }
  }

  Future<void> _populateCompensationDocuments(
    CompensationInfo compensation,
    List<Map<String, dynamic>> docs,
  ) async {
    debugPrint('Populating ${docs.length} compensation documents');

    for (final doc in docs) {
      try {
        final documentUrl = doc['document_url'] as String?;
        final documentName = doc['document_name'] as String? ?? 'Unknown';
        final documentType = doc['document_type'] as String? ?? '';
        final uploadDate = doc['upload_date'] != null 
            ? DateTime.parse(doc['upload_date']) 
            : DateTime.now();

        if (documentUrl == null || documentUrl.isEmpty) {
          debugPrint('Skipping document with no URL: $documentName');
          continue;
        }

        // Extract file path from URL
        final uri = Uri.parse(documentUrl);
        final pathSegments = uri.pathSegments;
        
        // Find 'compensation-docs' in path and get everything after it
        final bucketIndex = pathSegments.indexOf('compensation-docs');
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
          debugPrint('Downloading document: $filePath');
          
          // Download document from Supabase Storage
          final bytes = await SupabaseConfig.client.storage
              .from('compensation-docs')
              .download(filePath);
          
          // Create CompensationDocument
          final compensationDoc = CompensationDocument(
            name: documentName,
            date: uploadDate,
            data: bytes,
          );

          // Add to appropriate list based on document type
          switch (documentType) {
            case 'payslip':
              compensation.payslips.add(compensationDoc);
              break;
            case 'bonus':
              compensation.bonusesAndIncentives.add(compensationDoc);
              break;
            case 'benefits':
              compensation.benefitsSummary.add(compensationDoc);
              break;
            case 'compensation_letter':
              compensation.compensationLetters.add(compensationDoc);
              break;
            case 'offer_letter':
              compensation.offerLetters.add(compensationDoc);
              break;
            case 'reimbursement':
              compensation.reimbursements.add(compensationDoc);
              break;
            case 'policy':
              compensation.compensationPolicies.add(compensationDoc);
              break;
            default:
              debugPrint('Unknown document type: $documentType');
          }
          
          debugPrint('Document loaded successfully: $documentName');
        } else {
          debugPrint('Could not extract file path from URL: $documentUrl');
        }
      } catch (e) {
        debugPrint('Error loading compensation document: $e');
      }
    }
    
    debugPrint('Loaded ${compensation.payslips.length} payslips, '
        '${compensation.bonusesAndIncentives.length} bonuses, '
        '${compensation.benefitsSummary.length} benefits');
  }

  Future<void> _updateProjectHistory(List<ProjectAllocationEntry> projects) async {
    if (_currentEmployeeProfileId == null) return;

    try {
      // Delete existing projects
      await SupabaseConfig.client
          .from('project_allocations')
          .delete()
          .eq('employee_profile_id', _currentEmployeeProfileId!);

      // Insert new projects
      if (projects.isNotEmpty) {
        final projectData = projects.map((p) => {
          'employee_profile_id': _currentEmployeeProfileId,
          'project_name': p.projectName,
          'duration': p.duration,
          'reporting_manager': p.reportingManager,
        }).toList();

        await SupabaseConfig.client
            .from('project_allocations')
            .insert(projectData);
      }
    } catch (e) {
      debugPrint('Error updating project history: $e');
    }
  }

  Future<void> _updateEducationEntries(List<EmployeeEducationEntry> entries) async {
    if (_currentEmployeeProfileId == null) return;

    try {
      // Delete existing entries
      await SupabaseConfig.client
          .from('education_entries')
          .delete()
          .eq('employee_profile_id', _currentEmployeeProfileId!);

      // Insert new entries
      if (entries.isNotEmpty) {
        final educationData = entries.map((e) => {
          'employee_profile_id': _currentEmployeeProfileId,
          'level_of_education': e.level,
          'institution': e.institution,
          'degree': e.degree,
          'year': e.year,
          'grade': e.grade,
          'document_name': e.documentName,
        }).toList();

        await SupabaseConfig.client
            .from('education_entries')
            .insert(educationData);
      }
    } catch (e) {
      debugPrint('Error updating education entries: $e');
    }
  }

  Future<void> _updateEmploymentHistory(List<EmployeeEmploymentEntry> entries) async {
    if (_currentEmployeeProfileId == null) return;

    try {
      // Delete existing entries
      await SupabaseConfig.client
          .from('employment_entries')
          .delete()
          .eq('employee_profile_id', _currentEmployeeProfileId!);

      // Insert new entries
      if (entries.isNotEmpty) {
        final employmentData = entries.map((e) => {
          'employee_profile_id': _currentEmployeeProfileId,
          'company_name': e.companyName,
          'designation': e.designation,
          'from_date': e.fromDate?.toIso8601String(),
          'to_date': e.toDate?.toIso8601String(),
          'document_name': e.documentName,
        }).toList();

        await SupabaseConfig.client
            .from('employment_entries')
            .insert(employmentData);
      }
    } catch (e) {
      debugPrint('Error updating employment history: $e');
    }
  }

  String _mapCompensationType(String displayType) {
    switch (displayType) {
      case 'Payslips':
        return 'payslip';
      case 'Bonuses and Incentives':
        return 'bonus';
      case 'Benefits Summary':
        return 'benefit';
      case 'Compensation Letters / Agreements':
        return 'letter';
      case 'Offer Letters':
        return 'offer';
      case 'Reimbursements':
        return 'reimbursement';
      case 'Compensation Policies and FAQs':
        return 'policy';
      default:
        return 'other';
    }
  }
}
