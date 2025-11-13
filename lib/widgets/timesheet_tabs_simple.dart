// This file contains all 4 timesheet tab implementations
// Copy this content to timesheet_tabs.dart

import 'package:flutter/material.dart';

// Simple placeholder tabs - will be enhanced
class EmployeeAttendanceTab extends StatelessWidget {
  const EmployeeAttendanceTab({super.key, required this.employeeId, required this.isHrMode});
  final String employeeId;
  final bool isHrMode;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Attendance Tab - Employee: $employeeId, HR Mode: $isHrMode'));
  }
}

class LeaveRequestTab extends StatelessWidget {
  const LeaveRequestTab({super.key, required this.employeeId, required this.isHrMode});
  final String employeeId;
  final bool isHrMode;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Leave Request Tab - Employee: $employeeId, HR Mode: $isHrMode'));
  }
}

class WFHRequestTab extends StatelessWidget {
  const WFHRequestTab({super.key, required this.employeeId, required this.isHrMode});
  final String employeeId;
  final bool isHrMode;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('WFH Request Tab - Employee: $employeeId, HR Mode: $isHrMode'));
  }
}

class HolidayCalendarTab extends StatelessWidget {
  const HolidayCalendarTab({super.key, required this.employeeId, required this.isHrMode});
  final String employeeId;
  final bool isHrMode;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Holiday Calendar Tab - Employee: $employeeId, HR Mode: $isHrMode'));
  }
}
