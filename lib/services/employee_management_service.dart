import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'auth_service.dart';

/// Service for managing employee creation and operations
/// Only accessible by HR users
class EmployeeManagementService {
  EmployeeManagementService._internal();
  static final EmployeeManagementService instance = EmployeeManagementService._internal();

  /// Verify that the current user has HR role
  Future<void> _ensureHRAccess() async {
    // Get fresh user session
    final session = SupabaseConfig.client.auth.currentSession;
    final user = session?.user;
    
    debugPrint('=== Checking HR Access ===');
    debugPrint('Session exists: ${session != null}');
    debugPrint('User: ${user?.email}');
    debugPrint('Auth service role: ${AuthService.instance.userRole}');
    debugPrint('Auth service isHRLoggedIn: ${AuthService.instance.isHRLoggedIn}');
    
    if (user == null) {
      throw Exception('User not authenticated. Please login again.');
    }
    
    if (AuthService.instance.userRole != 'hr') {
      throw Exception('Unauthorized: HR access required. Current role: ${AuthService.instance.userRole}');
    }
    
    debugPrint('HR access verified for: ${user.email}');
  }

  /// Create a new employee with Supabase Auth and database record
  /// Returns error message if creation fails, null if successful
  Future<String?> createEmployee({
    required String employeeId,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Verify HR access
      await _ensureHRAccess();

      // Validate email pattern: strict name.x@domain (any domain)
      // Allows: prasad.k@aex.com, mounika.p@mycompany.in
      final emailRegex = RegExp(r'^[a-zA-Z0-9]+\.[a-zA-Z0-9]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
      if (!emailRegex.hasMatch(email)) {
        return 'Email must follow the format: name.x@domain (e.g. prasad.k@company.com)';
      }

      // Step 1: Create Supabase Auth user using signUp
      // We pass 'is_hr_created' metadata so a trigger can auto-confirm the email
      final authResponse = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null,
        data: {'is_hr_created': true},
      );

      if (authResponse.user == null) {
        return 'Failed to create user account';
      }

      final newUserId = authResponse.user!.id;

      // Step 2: Call Secure Database Function to setup Role and Profile
      // This bypasses all client-side RLS permission errors
      final rpcResponse = await SupabaseConfig.client.rpc(
        'setup_employee_data',
        params: {
          'p_auth_user_id': newUserId,
          'p_email': email,
          'p_name': name,
          'p_employee_id': employeeId,
          'p_hr_id': SupabaseConfig.client.auth.currentUser?.id,
        },
      );

      debugPrint('Employee setup response: $rpcResponse');

      if (rpcResponse['success'] == true) {
        debugPrint('Employee created successfully: $email');
        return null; // Success
      } else {
        return 'Failed to setup employee data: ${rpcResponse['error']}';
      }

    } on AuthException catch (e) {
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      // Handle Supabase Auth errors
      if (e.message.contains('invalid') && e.message.toLowerCase().contains('email')) {
        return 'Invalid email domain. Please use a real email domain (e.g., gmail.com, outlook.com) or disable email confirmation in Supabase Settings → Authentication.';
      }
      if (e.message.contains('email') || e.message.contains('User already registered')) {
        return 'This email address is already registered. Please use a different email.';
      }
      if (e.message.contains('password')) {
        return 'Password does not meet requirements (minimum 6 characters)';
      }
      return e.message;
    } on PostgrestException catch (e) {
      debugPrint('Database error: ${e.message}');
      // Handle database errors
      if (e.message.contains('duplicate')) {
        return 'Employee ID or email already exists';
      }
      if (e.message.contains('permission denied') || e.message.contains('policy')) {
        return 'Permission denied. Please check RLS policies are enabled.';
      }
      return 'Database error: ${e.message}';
    } catch (e) {
      debugPrint('Unexpected error creating employee: $e');
      return 'An unexpected error occurred: $e';
    }
  }

  /// Get all employees (HR only)
  Future<List<Map<String, dynamic>>> getEmployees() async {
    try {
      await _ensureHRAccess();

      final response = await SupabaseConfig.client
          .from('employee_profiles')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching employees: $e');
      return [];
    }
  }

  /// Update employee data (HR only)
  Future<String?> updateEmployee({
    required String employeeId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _ensureHRAccess();

      await SupabaseConfig.client
          .from('employee_profiles')
          .update(updates)
          .eq('employee_id', employeeId);

      return null; // Success
    } catch (e) {
      debugPrint('Error updating employee: $e');
      return 'Failed to update employee: $e';
    }
  }

  /// Delete employee (HR only)
  /// Note: This deletes the employee record but cannot delete the auth user
  /// without admin API access. Consider marking as inactive instead.
  Future<String?> deleteEmployee({required String authUserId}) async {
    try {
      await _ensureHRAccess();

      // Delete from employee_profiles table (will cascade)
      await SupabaseConfig.client
          .from('employee_profiles')
          .delete()
          .eq('auth_user_id', authUserId);

      // Note: We cannot delete the auth user without admin API
      // The user account will remain but won't have employee data
      debugPrint('Employee data deleted. Auth user remains (admin API needed to delete).');

      return null; // Success
    } catch (e) {
      debugPrint('Error deleting employee: $e');
      return 'Failed to delete employee: $e';
    }
  }
}
