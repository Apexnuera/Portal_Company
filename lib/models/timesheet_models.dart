import 'dart:convert';

class AttendanceRecord {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final String status; // 'Present', 'Absent', 'Half Day', 'WFH'
  final String? notes;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    required this.status,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      employeeId: json['employee_id'],
      date: DateTime.parse(json['date']),
      clockInTime: json['clock_in_time'] != null ? DateTime.parse(json['clock_in_time']).toLocal() : null,
      clockOutTime: json['clock_out_time'] != null ? DateTime.parse(json['clock_out_time']).toLocal() : null,
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'date': date.toIso8601String().split('T')[0], // Just the date part
      'clock_in_time': clockInTime?.toIso8601String(),
      'clock_out_time': clockOutTime?.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

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
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String leaveType;
  final String reason;
  String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime submittedDate;
  final DateTime? approvedDate;
  final String? approverComments;
  final String? documentUrl;
  final String? documentName;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    required this.status,
    required this.submittedDate,
    this.approvedDate,
    this.approverComments,
    this.documentUrl,
    this.documentName,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      employeeId: json['employee_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      leaveType: json['leave_type'],
      reason: json['reason'],
      status: json['status'],
      submittedDate: DateTime.parse(json['submitted_date']).toLocal(),
      approvedDate: json['approved_date'] != null ? DateTime.parse(json['approved_date']).toLocal() : null,
      approverComments: json['approver_comments'],
      documentUrl: json['document_url'],
      documentName: json['document_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'leave_type': leaveType,
      'reason': reason,
      'status': status,
      // 'submitted_date' is usually handled by default default now() in DB, but can pass if needed
      'document_url': documentUrl,
      'document_name': documentName,
    };
  }

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }
}

class WFHRequest {
  final String id;
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime submittedDate;
  final DateTime? approvedDate;
  final String? approverComments;

  WFHRequest({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.submittedDate,
    this.approvedDate,
    this.approverComments,
  });

  factory WFHRequest.fromJson(Map<String, dynamic> json) {
    return WFHRequest(
      id: json['id'],
      employeeId: json['employee_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'],
      status: json['status'],
      submittedDate: DateTime.parse(json['submitted_date']).toLocal(),
      approvedDate: json['approved_date'] != null ? DateTime.parse(json['approved_date']).toLocal() : null,
      approverComments: json['approver_comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'reason': reason,
      'status': status,
    };
  }

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }
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

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      description: json['description'] ?? '',
      isOptional: json['is_optional'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String().split('T')[0],
      'type': type,
      'description': description,
      'is_optional': isOptional,
    };
  }
}
