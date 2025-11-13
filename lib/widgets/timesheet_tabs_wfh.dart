import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timesheet_service.dart';

class WFHRequestTab extends StatefulWidget {
  const WFHRequestTab({super.key, required this.employeeId, required this.isHrMode});
  final String employeeId;
  final bool isHrMode;

  @override
  State<WFHRequestTab> createState() => _WFHRequestTabState();
}

class _WFHRequestTabState extends State<WFHRequestTab> {
  DateTime? _wfhDate;
  final _wfhReasonController = TextEditingController();
  int? _filterMonth, _filterYear;

  @override
  void dispose() {
    _wfhReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickWFHDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _wfhDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _wfhDate = picked);
  }

  Future<void> _submitWFHRequest() async {
    final ts = Provider.of<TimeSheetService>(context, listen: false);
    final ok = await ts.submitWFHRequest(date: _wfhDate!, reason: _wfhReasonController.text.trim());
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WFH request submitted successfully')));
      setState(() {
        _wfhDate = null;
        _wfhReasonController.clear();
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
          if (!widget.isHrMode) _buildEmployeeForm(ts),
          if (widget.isHrMode) _buildHrFilters(),
          const SizedBox(height: 16),
          const Text('WFH Requests History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildWFHRequestsList(ts),
        ],
      ),
    );
  }

  Widget _buildEmployeeForm(TimeSheetService ts) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Submit New WFH Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickWFHDate,
              icon: const Icon(Icons.date_range),
              label: Text(_wfhDate == null ? 'Select Date' : ts.formatDate(_wfhDate!)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wfhReasonController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Reason for WFH', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _wfhDate != null && _wfhReasonController.text.trim().isNotEmpty ? _submitWFHRequest : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF782B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit WFH Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHrFilters() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int>(
              key: ValueKey(_filterYear),
              initialValue: _filterYear,
              decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
              items: List.generate(5, (i) => DateTime.now().year - i)
                  .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (val) => setState(() => _filterYear = val),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int>(
              key: ValueKey(_filterMonth),
              initialValue: _filterMonth,
              decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
              items: List.generate(12, (i) => i + 1)
                  .map((m) => DropdownMenuItem(value: m, child: Text(_getMonthName(m))))
                  .toList(),
              onChanged: (val) => setState(() => _filterMonth = val),
            ),
          ),
          const SizedBox(width: 16),
          if (_filterYear != null || _filterMonth != null)
            TextButton.icon(
              onPressed: () => setState(() {
                _filterYear = null;
                _filterMonth = null;
              }),
              icon: const Icon(Icons.clear, color: Colors.red),
              label: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildWFHRequestsList(TimeSheetService ts) {
    var requests = ts.wfhRequests;
    if (widget.isHrMode) {
      if (_filterYear != null) requests = requests.where((r) => r.date.year == _filterYear).toList();
      if (_filterMonth != null) requests = requests.where((r) => r.date.month == _filterMonth).toList();
    }

    if (requests.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No WFH requests found.')));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Work From Home Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(ts.formatDate(request.date), style: TextStyle(color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ts.getStatusColor(request.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.status,
                        style: TextStyle(color: ts.getStatusColor(request.status), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text('Reason: ${request.reason}'),
                if (widget.isHrMode && request.status == 'Pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ts.updateWFHRequestStatus(request.id, 'Approved');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WFH request approved')));
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          ts.updateWFHRequestStatus(request.id, 'Rejected');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WFH request rejected')));
                        },
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ],
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
