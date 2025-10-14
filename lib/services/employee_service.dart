import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class EmployeeService extends ChangeNotifier {
  EmployeeService._internal();
  static final EmployeeService instance = EmployeeService._internal();

  // Employee data
  String _employeeName = 'John Doe';
  String _employeeInitials = 'JD';
  Uint8List? _profilePicture;
  
  // Alerts data
  int _unreadAlertsCount = 3; // Default to 3 unread alerts
  List<String> _alerts = [
    'New company policy update available',
    'Your compensation details have been updated',
    'Time sheet submission deadline reminder',
  ];

  // Getters
  String get employeeName => _employeeName;
  String get employeeInitials => _employeeInitials;
  Uint8List? get profilePicture => _profilePicture;
  int get unreadAlertsCount => _unreadAlertsCount;
  List<String> get alerts => _alerts;
  bool get hasUnreadAlerts => _unreadAlertsCount > 0;

  // Methods
  void setEmployeeName(String name) {
    _employeeName = name;
    _employeeInitials = _generateInitials(name);
    notifyListeners();
  }

  void setProfilePicture(Uint8List? imageBytes) {
    _profilePicture = imageBytes;
    notifyListeners();
  }

  void markAlertsAsRead() {
    _unreadAlertsCount = 0;
    notifyListeners();
  }

  void addAlert(String alert) {
    _alerts.insert(0, alert);
    _unreadAlertsCount++;
    notifyListeners();
  }

  String _generateInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
