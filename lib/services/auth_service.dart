import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  bool _isHRLoggedIn = false;

  bool get isHRLoggedIn => _isHRLoggedIn;

  void setHRLoggedIn(bool value) {
    if (_isHRLoggedIn != value) {
      _isHRLoggedIn = value;
      notifyListeners();
    }
  }
}
