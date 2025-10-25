import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timesheet_service.dart';
import '../utils/document_picker.dart';
import 'timesheet_tabs.dart';

class TimeSheetContent extends StatefulWidget {
  const TimeSheetContent({Key? key, required this.employeeId, this.isHrMode = false}) : super(key: key);
  final String employeeId;
  final bool isHrMode;

  @override
  State<TimeSheetContent> createState() => _TimeSheetContentState();
}

class _TimeSheetContentState extends State<TimeSheetContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFFF782B).withOpacity(0.1),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFFF782B),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFFF782B),
            tabs: const [
              Tab(text: 'Employee Attendance'),
              Tab(text: 'Leave Request'),
              Tab(text: 'WFH Request'),
              Tab(text: 'Holiday Calendar'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              EmployeeAttendanceTab(employeeId: widget.employeeId, isHrMode: widget.isHrMode),
              LeaveRequestTab(employeeId: widget.employeeId, isHrMode: widget.isHrMode),
              WFHRequestTab(employeeId: widget.employeeId, isHrMode: widget.isHrMode),
              HolidayCalendarTab(employeeId: widget.employeeId, isHrMode: widget.isHrMode),
            ],
          ),
        ),
      ],
    );
  }
}
