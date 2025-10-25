import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timesheet_service.dart';

class EmployeeAttendanceTab extends StatefulWidget {
  const EmployeeAttendanceTab({Key? key, required this.employeeId, required this.isHrMode}) : super(key: key);
  final String employeeId;
  final bool isHrMode;

  @override
  State<EmployeeAttendanceTab> createState() => _EmployeeAttendanceTabState();
}

class _EmployeeAttendanceTabState extends State<EmployeeAttendanceTab> {
  DateTime? _selectedDate;
  int? _selectedMonth;
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TimeSheetService>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isHrMode) ..._buildEmployeeControls(ts),
          if (widget.isHrMode) ..._buildHrFilters(ts),
          const SizedBox(height: 16),
          const Text('Attendance Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildAttendanceList(ts),
        ],
      ),
    );
  }

  List<Widget> _buildEmployeeControls(TimeSheetService ts) {
    return [
      Row(
        children: [
          ElevatedButton.icon(
            onPressed: ts.canClockIn() ? () => ts.clockIn() : null,
            icon: const Icon(Icons.login),
            label: const Text('Clock In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF782B),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: ts.canClockOut() ? () => ts.clockOut() : null,
            icon: const Icon(Icons.logout),
            label: const Text('Clock Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          if (ts.todayAttendance != null)
            Expanded(
              child: Text(
                'Today: '
                '${ts.todayAttendance!.clockInTime != null ? 'In ${ts.formatTime(ts.todayAttendance!.clockInTime!)}' : '-'}'
                ' • '
                '${ts.todayAttendance!.clockOutTime != null ? 'Out ${ts.formatTime(ts.todayAttendance!.clockOutTime!)}' : '-'}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    ];
  }

  List<Widget> _buildHrFilters(TimeSheetService ts) {
    return [
      Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
              items: List.generate(5, (i) => DateTime.now().year - i)
                  .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedYear = val;
                _selectedDate = null;
              }),
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
              items: List.generate(12, (i) => i + 1)
                  .map((m) => DropdownMenuItem(value: m, child: Text(_getMonthName(m))))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedMonth = val;
                _selectedDate = null;
              }),
            ),
          ),
          SizedBox(
            width: 220,
            child: OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(_selectedDate == null ? 'Select Specific Date' : ts.formatDate(_selectedDate!)),
            ),
          ),
          if (_selectedYear != null || _selectedMonth != null || _selectedDate != null)
            TextButton.icon(
              onPressed: () => setState(() {
                _selectedYear = null;
                _selectedMonth = null;
                _selectedDate = null;
              }),
              icon: const Icon(Icons.clear, color: Colors.red),
              label: const Text('Clear Filters', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    ];
  }

  Widget _buildAttendanceList(TimeSheetService ts) {
    var records = ts.attendanceRecords;
    if (widget.isHrMode) {
      if (_selectedDate != null) {
        records = records.where((r) =>
            r.date.year == _selectedDate!.year &&
            r.date.month == _selectedDate!.month &&
            r.date.day == _selectedDate!.day).toList();
      } else {
        if (_selectedYear != null) {
          records = records.where((r) => r.date.year == _selectedYear).toList();
        }
        if (_selectedMonth != null) {
          records = records.where((r) => r.date.month == _selectedMonth).toList();
        }
      }
    }

    if (records.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No attendance records found.')));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final a = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Color(0xFFFF782B)),
            title: Text(ts.formatDate(a.date)),
            subtitle: Text(
              'In: ${a.clockInTime != null ? ts.formatTime(a.clockInTime!) : '-'}  •  '
              'Out: ${a.clockOutTime != null ? ts.formatTime(a.clockOutTime!) : '-'}  •  '
              'Total: ${a.workingHoursFormatted}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: a.status == 'Present' ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                a.status,
                style: TextStyle(
                  color: a.status == 'Present' ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
