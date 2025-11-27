import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  bool _isHRLoggedIn = false;
  bool _isEmployeeLoggedIn = false;
  User? _currentUser;
  String? _userRole;

  bool get isHRLoggedIn => _isHRLoggedIn;
  bool get isEmployeeLoggedIn => _isEmployeeLoggedIn;
  User? get currentUser => _currentUser;
  String? get userRole => _userRole;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Initialize auth service and restore session
  Future<void> initialize() async {
    final session = SupabaseConfig.client.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
      debugPrint('Restoring session for user: ${_currentUser?.id}');

      // Fetch role
      await _fetchUserRole(_currentUser!.id);

      // Set login flags based on role
      if (_userRole == 'hr') {
        _isHRLoggedIn = true;
      } else if (_userRole == 'employee') {
        _isEmployeeLoggedIn = true;
      }

      notifyListeners();
    }

    // Listen for auth state changes
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _userRole = null;
        _isHRLoggedIn = false;
        _isEmployeeLoggedIn = false;
        notifyListeners();
      } else if (event == AuthChangeEvent.signedIn && session != null) {
        // Handle explicit sign in if needed, though usually handled by signInWithEmail
        if (_currentUser == null) {
          _currentUser = session.user;
          _fetchUserRole(_currentUser!.id).then((_) {
            if (_userRole == 'hr') {
              _isHRLoggedIn = true;
            } else if (_userRole == 'employee') {
              _isEmployeeLoggedIn = true;
            }
            notifyListeners();
          });
        }
      }
    });
  }

  /// Sign in with email and password
  /// Returns error message if login fails, null if successful
  Future<String?> signInWithEmail(
    String email,
    String password, {
    required bool isHR,
  }) async {
    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;

        // Fetch user role from database
        await _fetchUserRole(response.user!.id);

        // Verify role matches expected role
        if (isHR && _userRole != 'hr') {
          await signOut();
          return 'Access denied. This account is not authorized for HR access.';
        }

        if (!isHR && _userRole != 'employee') {
          await signOut();
          return 'Access denied. This account is not authorized for employee access.';
        }

        // Set appropriate login flag
        if (isHR) {
          _isHRLoggedIn = true;
        } else {
          _isEmployeeLoggedIn = true;
        }

        notifyListeners();
        return null; // Success
      }

      return 'Login failed. Please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  /// Fetch user role from user_roles table
  Future<void> _fetchUserRole(String userId) async {
    try {
      debugPrint('Fetching role for user: $userId');
      final response = await SupabaseConfig.client
          .from('user_roles')
          .select('role')
          .eq('id', userId)
          .single();

      debugPrint('Role fetch response: $response');
      _userRole = response['role'] as String?;
      debugPrint('Assigned role: $_userRole');
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      // Default to employee if role not found
      _userRole = 'employee';
      debugPrint('Defaulted role to: $_userRole');
    }
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    return SupabaseConfig.client.auth.currentUser;
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      _currentUser = null;
      _userRole = null;
      _isHRLoggedIn = false;
      _isEmployeeLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Legacy methods for backward compatibility
  void setHRLoggedIn(bool value) {
    if (_isHRLoggedIn != value) {
      _isHRLoggedIn = value;
      notifyListeners();
    }
  }

  void setEmployeeLoggedIn(bool value) {
    if (_isEmployeeLoggedIn != value) {
      _isEmployeeLoggedIn = value;
      notifyListeners();
    }
  }

  /// Legacy logout method
  void logout() {
    signOut();
  }
}
