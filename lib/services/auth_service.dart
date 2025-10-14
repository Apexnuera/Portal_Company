import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  bool _isHRLoggedIn = false;
  bool _isEmployeeLoggedIn = false;

  bool get isHRLoggedIn => _isHRLoggedIn;
  bool get isEmployeeLoggedIn => _isEmployeeLoggedIn;

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

  void logout() {
    _isHRLoggedIn = false;
    _isEmployeeLoggedIn = false;
    notifyListeners();
  }
}
