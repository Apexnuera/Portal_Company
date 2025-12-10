import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../services/timesheet_service.dart';
import '../utils/document_picker.dart';

class LeaveRequestForm extends StatefulWidget {
  final TimeSheetService timeSheetService;

  const LeaveRequestForm({super.key, required this.timeSheetService});

  @override
  State<LeaveRequestForm> createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLeaveType;
  Uint8List? _uploadedDocument;
  String? _documentName;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final doc = await pickDocument(context);
    if (doc != null && mounted) {
      setState(() {
        _uploadedDocument = doc.data;
        _documentName = doc.name;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFFF782B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_formKey.currentState!.validate() && 
        _startDate != null && 
        _endDate != null && 
        _selectedLeaveType != null) {
      
      // Validate document upload for Sick Leave
      if (_selectedLeaveType == 'Sick Leave' && _uploadedDocument == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload a medical certificate for sick leave'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final success = await widget.timeSheetService.submitLeaveRequest(
        startDate: _startDate!,
        endDate: _endDate!,
        leaveType: _selectedLeaveType!,
        reason: _reasonController.text,
        document: _uploadedDocument != null && _documentName != null
            ? {'name': _documentName, 'data': _uploadedDocument}
            : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        setState(() {
          _startDate = null;
          _endDate = null;
          _selectedLeaveType = null;
          _uploadedDocument = null;
          _documentName = null;
          _reasonController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_busy, color: Color(0xFFFF782B), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Submit Leave Request',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Leave Type Dropdown
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedLeaveType),
            initialValue: _selectedLeaveType,
            decoration: const InputDecoration(
              labelText: 'Leave Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: widget.timeSheetService.leaveTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLeaveType = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a leave type';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Date Selection Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _startDate != null 
                        ? widget.timeSheetService.formatDate(_startDate!)
                        : 'Select start date',
                      style: TextStyle(
                        color: _startDate != null ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _endDate != null 
                        ? widget.timeSheetService.formatDate(_endDate!)
                        : 'Select end date',
                      style: TextStyle(
                        color: _endDate != null ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Document Upload (only for Sick Leave)
          if (_selectedLeaveType == 'Sick Leave') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _uploadedDocument == null 
                      ? Colors.orange.withValues(alpha: 0.5)
                      : Colors.green.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _uploadedDocument == null 
                            ? Icons.upload_file_outlined 
                            : Icons.check_circle_outlined,
                        color: _uploadedDocument == null 
                            ? const Color(0xFFFF782B) 
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _uploadedDocument == null
                              ? 'Medical Certificate Required *'
                              : 'Document Uploaded: $_documentName',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _uploadedDocument == null 
                                ? Colors.orange.shade800 
                                : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickDocument,
                      icon: Icon(
                        _uploadedDocument == null 
                            ? Icons.attach_file 
                            : Icons.refresh,
                      ),
                      label: Text(
                        _uploadedDocument == null 
                            ? 'Upload Medical Certificate' 
                            : 'Change Document',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF782B),
                        side: const BorderSide(color: Color(0xFFFF782B)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_uploadedDocument == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Please attach a medical certificate or doctor\'s note for sick leave',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Reason Text Field
          TextFormField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason/Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide a reason for leave';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitLeaveRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF782B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Submit Leave Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
