import 'package:flutter/foundation.dart';

class AppSession extends ChangeNotifier {
  String? _loggedInEmployeeId;

  String? get loggedInEmployeeId => _loggedInEmployeeId;

  void signIn(String employeeId) {
    if (_loggedInEmployeeId == employeeId) {
      return;
    }
    _loggedInEmployeeId = employeeId;
    notifyListeners();
  }

  void signOut() {
    if (_loggedInEmployeeId == null) {
      return;
    }
    _loggedInEmployeeId = null;
    notifyListeners();
  }
}
