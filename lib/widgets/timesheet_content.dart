import 'package:flutter/material.dart';
import 'timesheet_tabs.dart';

class TimeSheetContent extends StatefulWidget {
  const TimeSheetContent({super.key, required this.employeeId, this.isHrMode = false});
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFF782B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
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
