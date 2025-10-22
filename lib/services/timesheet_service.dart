import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Data Models
class AttendanceRecord {
  final String id;
  final DateTime date;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final String status; // 'Present', 'Absent', 'Half Day', 'WFH'
  final String? notes;

  AttendanceRecord({
    required this.id,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    required this.status,
    this.notes,
  });

  Duration? get workingHours {
    if (clockInTime != null && clockOutTime != null) {
      return clockOutTime!.difference(clockInTime!);
    }
    return null;
  }

  String get workingHoursFormatted {
    final hours = workingHours;
    if (hours != null) {
      final h = hours.inHours;
      final m = hours.inMinutes % 60;
      return '${h}h ${m}m';
    }
    return 'N/A';
  }
}

class LeaveRequest {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String leaveType;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime submittedDate;
  final DateTime? approvedDate;
  final String? approverComments;

  LeaveRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    required this.status,
    required this.submittedDate,
    this.approvedDate,
    this.approverComments,
  });

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }
}

class WFHRequest {
  final String id;
  final DateTime date;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime submittedDate;
  final DateTime? approvedDate;
  final String? approverComments;

  WFHRequest({
    required this.id,
    required this.date,
    required this.reason,
    required this.status,
    required this.submittedDate,
    this.approvedDate,
    this.approverComments,
  });
}

class Holiday {
  final String id;
  final String name;
  final DateTime date;
  final String type; // 'National', 'Regional', 'Company'
  final String description;
  final bool isOptional;

  Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    required this.description,
    this.isOptional = false,
  });
}

// Time Sheet Service
class TimeSheetService extends ChangeNotifier {
  TimeSheetService._internal();
  static final TimeSheetService instance = TimeSheetService._internal();

  // Sample data - in a real app, this would come from an API
  late List<AttendanceRecord> _attendanceRecords;
  late List<LeaveRequest> _leaveRequests;
  late List<WFHRequest> _wfhRequests;
  late List<Holiday> _holidays;
  late List<String> _leaveTypes;

  // Current day attendance
  AttendanceRecord? _todayAttendance;

  // Getters
  List<AttendanceRecord> get attendanceRecords => List.unmodifiable(_attendanceRecords);
  List<LeaveRequest> get leaveRequests => List.unmodifiable(_leaveRequests);
  List<WFHRequest> get wfhRequests => List.unmodifiable(_wfhRequests);
  List<Holiday> get holidays => List.unmodifiable(_holidays);
  List<String> get leaveTypes => List.unmodifiable(_leaveTypes);
  AttendanceRecord? get todayAttendance => _todayAttendance;

  bool get isClockedIn => _todayAttendance?.clockInTime != null && _todayAttendance?.clockOutTime == null;
  bool get isClockedOut => _todayAttendance?.clockOutTime != null;

  void initialize() {
    _initializeSampleData();
    print('TimeSheetService initialized with ${_holidays.length} holidays and ${_leaveTypes.length} leave types');
  }

  void _initializeSampleData() {
    // Leave Types (keep these as they're needed for the form)
    _leaveTypes = [
      'Sick Leave',
      'Casual Leave',
      'Annual Leave',
      'Personal Leave',
      'Emergency Leave',
      'Maternity/Paternity Leave',
    ];

    // Initialize empty lists - no sample data
    _attendanceRecords = [];
    _todayAttendance = null;
    _leaveRequests = [];
    _wfhRequests = [];
    _holidays = [];
  }

  // Clock In/Out functionality
  Future<bool> clockIn() async {
    try {
      final now = DateTime.now();
      if (_todayAttendance == null ||
          _todayAttendance!.date.year != now.year ||
          _todayAttendance!.date.month != now.month ||
          _todayAttendance!.date.day != now.day) {
        _todayAttendance = AttendanceRecord(
          id: 'ATT-${now.year}${now.month}${now.day}',
          date: DateTime(now.year, now.month, now.day),
          clockInTime: now,
          status: 'Present',
        );
      } else {
        _todayAttendance = AttendanceRecord(
          id: _todayAttendance!.id,
          date: _todayAttendance!.date,
          clockInTime: now,
          status: 'Present',
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clockOut() async {
    try {
      if (_todayAttendance?.clockInTime != null) {
        final now = DateTime.now();
        _todayAttendance = AttendanceRecord(
          id: _todayAttendance!.id,
          date: _todayAttendance!.date,
          clockInTime: _todayAttendance!.clockInTime,
          clockOutTime: now,
          status: 'Present',
        );
        
        // Add to attendance records
        _attendanceRecords.insert(0, _todayAttendance!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Submit Leave Request
  Future<bool> submitLeaveRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String leaveType,
    required String reason,
  }) async {
    try {
      final request = LeaveRequest(
        id: 'LR-${DateTime.now().millisecondsSinceEpoch}',
        startDate: startDate,
        endDate: endDate,
        leaveType: leaveType,
        reason: reason,
        status: 'Pending',
        submittedDate: DateTime.now(),
      );
      
      _leaveRequests.insert(0, request);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Submit WFH Request
  Future<bool> submitWFHRequest({
    required DateTime date,
    required String reason,
  }) async {
    try {
      final request = WFHRequest(
        id: 'WFH-${DateTime.now().millisecondsSinceEpoch}',
        date: date,
        reason: reason,
        status: 'Pending',
        submittedDate: DateTime.now(),
      );
      
      _wfhRequests.insert(0, request);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Utility methods
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'wfh':
        return Colors.blue;
      case 'half day':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Holiday> getHolidaysForMonth(int year, int month) {
    return _holidays.where((holiday) => 
      holiday.date.year == year && holiday.date.month == month
    ).toList();
  }

  bool isHoliday(DateTime date) {
    return _holidays.any((holiday) => 
      holiday.date.year == date.year &&
      holiday.date.month == date.month &&
      holiday.date.day == date.day
    );
  }

  Holiday? getHolidayForDate(DateTime date) {
    try {
      return _holidays.firstWhere((holiday) => 
        holiday.date.year == date.year &&
        holiday.date.month == date.month &&
        holiday.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }
}
