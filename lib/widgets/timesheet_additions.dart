// This file contains the code that needs to be added to employee_dashboard_page.dart
// Add this import at the top of employee_dashboard_page.dart:
// import '../widgets/leave_request_form.dart';
// import '../widgets/wfh_request_form.dart';

// Replace _LeaveRequestForm(timeSheetService: _timeSheetService) with:
// LeaveRequestForm(timeSheetService: _timeSheetService)

// Replace _WFHRequestForm(timeSheetService: _timeSheetService) with:
// WFHRequestForm(timeSheetService: _timeSheetService)

// Add this method to _TimeSheetContentState class:

  // Holiday Calendar Tab
  Widget _buildHolidayCalendarTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Read-Only indicator
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFFFF782B), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Official Holiday Calendar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Read Only',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'All official holidays are managed by HR and cannot be modified by employees.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Holiday List
          Expanded(
            child: ListView.builder(
              itemCount: _timeSheetService.holidays.length,
              itemBuilder: (context, index) {
                final holiday = _timeSheetService.holidays[index];
                final isUpcoming = holiday.date.isAfter(DateTime.now());
                
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getHolidayTypeColor(holiday.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getHolidayIcon(holiday.type),
                        color: _getHolidayTypeColor(holiday.type),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      holiday.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isUpcoming ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _timeSheetService.formatDate(holiday.date),
                          style: TextStyle(
                            color: isUpcoming ? Colors.black87 : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          holiday.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getHolidayTypeColor(holiday.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            holiday.type,
                            style: TextStyle(
                              color: _getHolidayTypeColor(holiday.type),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (holiday.isOptional) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Optional',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        if (!isUpcoming) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Past',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getHolidayTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'national':
        return Colors.red;
      case 'regional':
        return Colors.blue;
      case 'company':
        return const Color(0xFFFF782B);
      default:
        return Colors.grey;
    }
  }

  IconData _getHolidayIcon(String type) {
    switch (type.toLowerCase()) {
      case 'national':
        return Icons.flag;
      case 'regional':
        return Icons.location_on;
      case 'company':
        return Icons.business;
      default:
        return Icons.event;
    }
  }
