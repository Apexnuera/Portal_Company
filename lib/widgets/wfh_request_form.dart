import 'package:flutter/material.dart';
import '../services/timesheet_service.dart';

class WFHRequestForm extends StatefulWidget {
  final TimeSheetService timeSheetService;

  const WFHRequestForm({super.key, required this.timeSheetService});

  @override
  State<WFHRequestForm> createState() => _WFHRequestFormState();
}

class _WFHRequestFormState extends State<WFHRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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

  Future<void> _submitWFHRequest() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      final success = await widget.timeSheetService.submitWFHRequest(
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WFH request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        setState(() {
          _startDate = null;
          _endDate = null;
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
              const Icon(Icons.home_work, color: Color(0xFFFF782B), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Submit WFH Request',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
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
          
          // Reason Text Field
          TextFormField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for WFH',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
              hintText: 'e.g., Home internet installation, family emergency, etc.',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide a reason for WFH request';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitWFHRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF782B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Submit WFH Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'WFH requests should be submitted at least 24 hours in advance and require manager approval.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
