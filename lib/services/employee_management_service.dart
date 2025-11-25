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

      // Step 1: Create Supabase Auth user using signUp
      final authResponse = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // No redirect needed for HR-created accounts
      );

      if (authResponse.user == null) {
        return 'Failed to create user account';
      }

      final newUserId = authResponse.user!.id;

      try {
        // Step 2: Assign employee role in user_roles table
        await SupabaseConfig.client.from('user_roles').insert({
          'id': newUserId,
          'role': 'employee',
          'email': email,
        });

        // Step 3: Create employee record in employees table
        final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
        await SupabaseConfig.client.from('employees').insert({
          'auth_user_id': newUserId,
          'employee_id': employeeId,
          'name': name,
          'email': email,
          'created_by': currentUserId,
        });

        debugPrint('Employee created successfully: $email');
        return null; // Success
      } catch (e) {
        debugPrint('Error during role/employee creation: $e');
        
        // Rollback: Try to delete the auth user if role/employee creation fails
        // Note: Since we're not using admin API, we can't delete the user programmatically
        // The user account will exist but won't have employee role/data
        
        // Check for specific errors
        if (e.toString().contains('duplicate key') || e.toString().contains('unique constraint')) {
          return 'Employee ID or email already exists';
        }
        
        if (e.toString().contains('policy') || e.toString().contains('permission')) {
          return 'Permission denied. Please ensure RLS policies are set up correctly.';
        }
        
        return 'Failed to create employee record: ${e.toString()}';
      }
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      // Handle Supabase Auth errors
      if (e.message.contains('email')) {
        return 'Email is already in use';
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
          .from('employees')
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
          .from('employees')
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

      // Delete from employees table (will cascade)
      await SupabaseConfig.client
          .from('employees')
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
