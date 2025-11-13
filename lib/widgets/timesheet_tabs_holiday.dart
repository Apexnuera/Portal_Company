import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timesheet_service.dart';

class HolidayCalendarTab extends StatefulWidget {
  const HolidayCalendarTab({super.key, required this.employeeId, required this.isHrMode});
  final String employeeId;
  final bool isHrMode;

  @override
  State<HolidayCalendarTab> createState() => _HolidayCalendarTabState();
}

class _HolidayCalendarTabState extends State<HolidayCalendarTab> {
  final _holidayNameController = TextEditingController();
  DateTime? _holidayDate;

  @override
  void dispose() {
    _holidayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickHolidayDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _holidayDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) setState(() => _holidayDate = picked);
  }

  void _addHoliday() {
    final ts = Provider.of<TimeSheetService>(context, listen: false);
    if (_holidayNameController.text.isNotEmpty && _holidayDate != null) {
      ts.addHoliday(
        name: _holidayNameController.text,
        date: _holidayDate!,
        type: 'Company', // Default type
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Holiday added successfully')));
      setState(() {
        _holidayNameController.clear();
        _holidayDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TimeSheetService>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Company Holiday Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (widget.isHrMode) _buildHrHolidayForm(ts),
          const SizedBox(height: 16),
          _buildHolidayList(ts),
        ],
      ),
    );
  }

  Widget _buildHrHolidayForm(TimeSheetService ts) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Holiday', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _holidayNameController,
              decoration: const InputDecoration(labelText: 'Holiday Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickHolidayDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_holidayDate == null ? 'Select Date' : ts.formatDate(_holidayDate!)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addHoliday,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF782B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Holiday'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayList(TimeSheetService ts) {
    final holidays = ts.holidays;

    if (holidays.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No holidays scheduled yet.')));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: holidays.length,
      itemBuilder: (context, index) {
        final holiday = holidays[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.celebration, color: Color(0xFFFF782B)),
            title: Text(holiday.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${ts.formatDate(holiday.date)} (${_getDayOfWeek(holiday.date)})'),
            trailing: widget.isHrMode
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      ts.removeHoliday(holiday.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Holiday removed')));
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}
