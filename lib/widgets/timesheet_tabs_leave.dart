import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timesheet_service.dart';
import '../utils/document_picker.dart';
import '../utils/document_viewer.dart';

class LeaveRequestTab extends StatefulWidget {
  const LeaveRequestTab({super.key, required this.employeeId, required this.isHrMode});
  final String employeeId;
  final bool isHrMode;

  @override
  State<LeaveRequestTab> createState() => _LeaveRequestTabState();
}

class _LeaveRequestTabState extends State<LeaveRequestTab> {
  DateTime? _startDate, _endDate;
  String? _leaveType;
  final _reasonController = TextEditingController();
  DocumentFile? _supportingDocument;
  int? _filterMonth, _filterYear;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) _endDate = _startDate;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _uploadDocument() async {
    final file = await pickDocument(context);
    if (file != null) {
      setState(() => _supportingDocument = file);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document uploaded: ${file.name}')));
    }
  }

  Future<void> _submitLeaveRequest() async {
    final ts = Provider.of<TimeSheetService>(context, listen: false);
    final ok = await ts.submitLeaveRequest(
      startDate: _startDate!,
      endDate: _endDate!,
      leaveType: _leaveType!,
      reason: _reasonController.text.trim(),
      document: _supportingDocument,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request submitted successfully')));
      setState(() {
        _startDate = null;
        _endDate = null;
        _leaveType = null;
        _reasonController.clear();
        _supportingDocument = null;
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
          const Text('Leave Requests History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildLeaveRequestsList(ts),
        ],
      ),
    );
  }

  Widget _buildEmployeeForm(TimeSheetService ts) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Submit New Leave Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_leaveType),
                    initialValue: _leaveType,
                    decoration: const InputDecoration(labelText: 'Leave Type', border: OutlineInputBorder()),
                    items: ts.leaveTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _leaveType = v),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: true),
                    icon: const Icon(Icons.date_range),
                    label: Text(_startDate == null ? 'Start Date' : ts.formatDate(_startDate!)),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: false),
                    icon: const Icon(Icons.date_range),
                    label: Text(_endDate == null ? 'End Date' : ts.formatDate(_endDate!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason for Leave', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _uploadDocument,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_supportingDocument == null ? 'Upload Document' : 'Document Uploaded'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _supportingDocument == null ? Colors.grey.shade600 : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_supportingDocument != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _supportingDocument!.name,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _leaveType != null && _startDate != null && _endDate != null && _reasonController.text.trim().isNotEmpty
                  ? _submitLeaveRequest
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF782B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Submit Request'),
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

  Widget _buildLeaveRequestsList(TimeSheetService ts) {
    var requests = ts.leaveRequests;
    if (widget.isHrMode) {
      if (_filterYear != null) requests = requests.where((r) => r.startDate.year == _filterYear).toList();
      if (_filterMonth != null) requests = requests.where((r) => r.startDate.month == _filterMonth).toList();
    }

    if (requests.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No leave requests found.')));
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
                          Text(request.leaveType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${ts.formatDate(request.startDate)} to ${ts.formatDate(request.endDate)}', style: TextStyle(color: Colors.grey.shade700)),
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
                if (request.documentName != null && request.documentBytes != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.attach_file, size: 18, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.documentName!,
                          style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).primaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final opened = await openDocumentBytes(
                            bytes: Uint8List.fromList(request.documentBytes!),
                            fileName: request.documentName!,
                          );
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Document preview not supported on this platform.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.visibility_outlined),
                        tooltip: 'View Document',
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ],
                if (widget.isHrMode && request.status == 'Pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ts.updateLeaveRequestStatus(request.id, 'Approved');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request approved')));
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          ts.updateLeaveRequestStatus(request.id, 'Rejected');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request rejected')));
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
