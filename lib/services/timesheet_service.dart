import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/timesheet_models.dart';
import '../utils/document_picker.dart';

// Re-export models for ease of use
export '../models/timesheet_models.dart';

// Time Sheet Service
class TimeSheetService extends ChangeNotifier {
  TimeSheetService._internal();
  static final TimeSheetService instance = TimeSheetService._internal();

  List<AttendanceRecord> _attendanceRecords = [];
  List<LeaveRequest> _leaveRequests = [];
  List<WFHRequest> _wfhRequests = [];
  List<Holiday> _holidays = [];
  List<String> _leaveTypes = [];

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

  // Check if can clock in (only once per day, only for today)
  bool canClockIn() {
    final now = DateTime.now();
    
    // Check if already clocked in today
    if (_todayAttendance != null) {
        // If we have a record for today, check if it's already clocked in
        // If clockInTime is present, user has clocked in.
        // If clockOutTime is NOT present, user is currently working.
        // If clockOutTime IS present, user has finished for the day.
        
        // Simple logic: if a record exists for today, you can't clock in again
        return false;
    }
    return true;
  }

  // Check if can clock out
  bool canClockOut() {
    return isClockedIn && !isClockedOut;
  }

  Future<void> initialize() async {
    _leaveTypes = [
      'Sick Leave',
      'Casual Leave',
      'Annual Leave',
      'Personal Leave',
      'Emergency Leave',
      'Maternity/Paternity Leave',
    ];

    print('Initializing TimeSheetService with Supabase...');
    await _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
        final userId = SupabaseConfig.client.auth.currentUser?.id;
        if (userId == null) return;
        
        // Fetch Holidays (Public)
        final holidaysResponse = await SupabaseConfig.client
            .from('timetracking_holidays')
            .select()
            .order('date', ascending: true);
        _holidays = (holidaysResponse as List).map((e) => Holiday.fromJson(e)).toList();

        // Check user role to decide what to fetch
        // For simplicity, we fetch everything allowed by RLS policies
        // RLS will ensure employees only see their own records, and HR sees all

        // Fetch Attendance
        final attendanceResponse = await SupabaseConfig.client
            .from('timetracking_attendance')
            .select()
            .order('date', ascending: false);
        _attendanceRecords = (attendanceResponse as List).map((e) => AttendanceRecord.fromJson(e)).toList();
        
        // Set today attendance
        final now = DateTime.now();
        final todayStr = now.toIso8601String().split('T')[0];
        try {
            _todayAttendance = _attendanceRecords.firstWhere((element) => 
                element.date.year == now.year && 
                element.date.month == now.month && 
                element.date.day == now.day
            );
        } catch (e) {
            _todayAttendance = null;
        }

        // Fetch Leave Requests
        final leaveResponse = await SupabaseConfig.client
            .from('timetracking_leave_requests')
            .select()
            .order('submitted_date', ascending: false);
        _leaveRequests = (leaveResponse as List).map((e) => LeaveRequest.fromJson(e)).toList();

        // Fetch WFH Requests
        final wfhResponse = await SupabaseConfig.client
            .from('timetracking_wfh_requests')
            .select()
            .order('submitted_date', ascending: false);
        _wfhRequests = (wfhResponse as List).map((e) => WFHRequest.fromJson(e)).toList();

        notifyListeners();
        print('TimeSheetService data fetched successfully.');
    } catch (e) {
        print('Error fetching timesheet data: $e');
    }
  }

  // Clock In
  Future<bool> clockIn() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return false;

      final now = DateTime.now();
      final dateStr = now.toIso8601String().split('T')[0];

      final response = await SupabaseConfig.client
          .from('timetracking_attendance')
          .insert({
            'employee_id': user.id,
            'date': dateStr,
            'clock_in_time': now.toIso8601String(),
            'status': 'Present',
          })
          .select()
          .single();

      _todayAttendance = AttendanceRecord.fromJson(response);
      _attendanceRecords.insert(0, _todayAttendance!);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error clocking in: $e');
      return false;
    }
  }

  // Clock Out
  Future<bool> clockOut() async {
    try {
      if (_todayAttendance == null) return false;

      final now = DateTime.now();

      final response = await SupabaseConfig.client
          .from('timetracking_attendance')
          .update({
            'clock_out_time': now.toIso8601String(),
          })
          .eq('id', _todayAttendance!.id)
          .select()
          .single();

      _todayAttendance = AttendanceRecord.fromJson(response);
      // Update the record in the list
      final index = _attendanceRecords.indexWhere((r) => r.id == _todayAttendance!.id);
      if (index != -1) {
          _attendanceRecords[index] = _todayAttendance!;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error clocking out: $e');
      return false;
    }
  }

  // Submit Leave Request
  Future<bool> submitLeaveRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String leaveType,
    required String reason,
    DocumentFile? document,
  }) async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return false;
      
      String? documentUrl;
      String? documentName = document?.name;

      // Upload document if present
      if (document != null && document.data != null) {
          try {
              final fileName = '${DateTime.now().millisecondsSinceEpoch}_${document.name}';
              final path = 'leave_documents/$fileName';
              // Check if bucket exists, creating automatically usually requires admin token or setup
              // Assuming 'documents' bucket exists as per legacy code? Or creating new logic.
              // We'll use a specific bucket for leave docs if possible, or general 'documents'.
              // For now assuming 'documents' bucket is available publicly or authenticated.
              
              await SupabaseConfig.client.storage
                  .from('documents') 
                  .uploadBinary(path, document.data!);
              
              documentUrl = SupabaseConfig.client.storage.from('documents').getPublicUrl(path);
          } catch (e) {
              print('Error uploading document: $e');
              // Continue without doc or fail? usually fail if doc is required.
              // For now we log and proceed without doc url if upload fails, but ideally should stop.
          }
      }

      final response = await SupabaseConfig.client
          .from('timetracking_leave_requests')
          .insert({
            'employee_id': user.id,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'leave_type': leaveType,
            'reason': reason,
            'status': 'Pending',
            'document_url': documentUrl,
            'document_name': documentName,
          })
          .select()
          .single();
      
      final newRequest = LeaveRequest.fromJson(response);
      _leaveRequests.insert(0, newRequest);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error submitting leave request: $e');
      return false;
    }
  }

  // Submit WFH Request
  Future<bool> submitWFHRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
        final user = SupabaseConfig.client.auth.currentUser;
        if (user == null) return false;

        final response = await SupabaseConfig.client
            .from('timetracking_wfh_requests')
            .insert({
                'employee_id': user.id,
                'start_date': startDate.toIso8601String().split('T')[0],
                'end_date': endDate.toIso8601String().split('T')[0],
                'reason': reason,
                'status': 'Pending',
            })
            .select()
            .single();

        final newRequest = WFHRequest.fromJson(response);
        _wfhRequests.insert(0, newRequest);
        notifyListeners();
        return true;
    } catch (e) {
      print('Error submitting WFH request: $e');
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

  // HR Methods - Update Leave Request Status
  Future<void> updateLeaveRequestStatus(String requestId, String newStatus) async {
    try {
        final response = await SupabaseConfig.client
            .from('timetracking_leave_requests')
            .update({
                'status': newStatus,
                'approved_date': newStatus == 'Approved' ? DateTime.now().toIso8601String() : null,
            })
            .eq('id', requestId)
            .select()
            .single();
            
        final index = _leaveRequests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
            _leaveRequests[index] = LeaveRequest.fromJson(response);
            notifyListeners();
        }
    } catch (e) {
        print('Error updating leave status: $e');
    }
  }

  // HR Methods - Update WFH Request Status
  Future<void> updateWFHRequestStatus(String requestId, String newStatus) async {
    try {
        final response = await SupabaseConfig.client
            .from('timetracking_wfh_requests')
            .update({
                'status': newStatus,
                'approved_date': newStatus == 'Approved' ? DateTime.now().toIso8601String() : null,
            })
            .eq('id', requestId)
            .select()
            .single();

        final index = _wfhRequests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
            _wfhRequests[index] = WFHRequest.fromJson(response);
            notifyListeners();
        }
    } catch (e) {
        print('Error updating WFH status: $e');
    }
  }

  // HR Methods - Add Holiday
  Future<void> addHoliday({
    required String name,
    required DateTime date,
    required String type,
    String description = '',
    bool isOptional = false,
  }) async {
    try {
        final response = await SupabaseConfig.client
            .from('timetracking_holidays')
            .insert({
                'name': name,
                'date': date.toIso8601String().split('T')[0],
                'type': type,
                'description': description,
                'is_optional': isOptional,
            })
            .select()
            .single();

        final newHoliday = Holiday.fromJson(response);
        _holidays.add(newHoliday);
        _holidays.sort((a, b) => a.date.compareTo(b.date));
        notifyListeners();
    } catch (e) {
        print('Error adding holiday: $e');
    }
  }

  // HR Methods - Remove Holiday
  Future<void> removeHoliday(String holidayId) async {
    try {
        await SupabaseConfig.client
            .from('timetracking_holidays')
            .delete()
            .eq('id', holidayId);
            
        _holidays.removeWhere((h) => h.id == holidayId);
        notifyListeners();
    } catch (e) {
        print('Error removing holiday: $e');
    }
  }
}
