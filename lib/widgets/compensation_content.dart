import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/employee_directory.dart';
import '../utils/document_picker.dart';
import '../utils/document_viewer.dart';
import '../utils/document_saver.dart';
import '../services/employee_profile_service.dart'; // Added for Supabase sync

// Quick filter options for payslips
enum QuickFilter { all, thisYear }

class CompensationContent extends StatefulWidget {
  const CompensationContent({super.key, required this.employeeId, this.isHrMode = false});
  final String employeeId;
  final bool isHrMode;

  @override
  State<CompensationContent> createState() => _CompensationContentState();
}

class _CompensationContentState extends State<CompensationContent> {
  int? _selectedYear;
  int? _selectedMonth;
  bool _isEditMode = false; // Edit mode for HR
  late CompensationInfo _workingCopy; // Working copy of compensation data
  bool _isSaving = false;
  
  // Enhanced filter state
  QuickFilter? _quickFilter = QuickFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize working copy
    final directory = context.read<EmployeeDirectory>();
    final record = directory.getById(widget.employeeId);
    _workingCopy = record.compensation;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _applyQuickFilter(QuickFilter filter) {
    setState(() {
      _quickFilter = filter;
      _selectedYear = null;
      _selectedMonth = null;
      
      final now = DateTime.now();
      if (filter == QuickFilter.thisYear) {
        _selectedYear = now.year;
      }
    });
  }

  List<CompensationDocument> _getFilteredPayslips(List<CompensationDocument> payslips) {
    var filtered = payslips;
    
    // Apply quick filter  
    if (_quickFilter == QuickFilter.thisYear) {
      final now = DateTime.now();
      filtered = filtered.where((p) => p.date.year == now.year).toList();
    }
    
    // Apply year/month filter
    if (_selectedYear != null) {
      filtered = filtered.where((p) => p.date.year == _selectedYear).toList();
    }
    if (_selectedMonth != null) {
      filtered = filtered.where((p) => p.date.month == _selectedMonth).toList();
    }
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        // Cancel - reload original
        final directory = context.read<EmployeeDirectory>();
        final record = directory.getById(widget.employeeId);
        _workingCopy = record.compensation;
      }
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      // Sync to Supabase first
      final error = await EmployeeProfileService.instance.updateCompensationForEmployee(
        widget.employeeId,
        _workingCopy,
      );

      if (error == null) {
        // Update local EmployeeDirectory
        if (mounted) {
          context.read<EmployeeDirectory>().updateCompensation(
            widget.employeeId,
            _workingCopy,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compensation saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _isEditMode = false;
            _isSaving = false;
          });
        }
      } else {
        // Error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: $error')),
          );
          setState(() => _isSaving = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openDocument(BuildContext ctx, CompensationDocument doc) async {
    final opened = await openDocumentBytes(bytes: doc.data, fileName: doc.name);
    if (!ctx.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Document preview not supported on this platform.')),
      );
    }
  }

  Future<void> _downloadDocument(BuildContext ctx, CompensationDocument doc) async {
    final saved = await saveDocumentBytes(bytes: doc.data, fileName: doc.name);
    if (!ctx.mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Download not supported on this platform.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final directory = context.watch<EmployeeDirectory>();
    final record = directory.getById(widget.employeeId);
    final compensation = _isEditMode ? _workingCopy : record.compensation;

    final uniqueYears = compensation.payslips.map((p) => p.date.year).toSet().toList()..sort();
    final filteredPayslips = _getFilteredPayslips(compensation.payslips);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSalaryDetails(context, compensation),
          const SizedBox(height: 24),
          _buildEnhancedPayslipFilter(uniqueYears),
          _buildDocumentSection('Payslips', compensation.payslips, filteredPayslips),
          _buildDocumentSection('Bonuses and Incentives', compensation.bonusesAndIncentives),
          _buildDocumentSection('Benefits Summary', compensation.benefitsSummary),
          _buildDocumentSection('Compensation Letters / Agreements', compensation.compensationLetters),
          _buildDocumentSection('Offer Letters', compensation.offerLetters),
          _buildDocumentSection('Reimbursements', compensation.reimbursements),
          _buildDocumentSection('Compensation Policies and FAQs', compensation.compensationPolicies),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Compensation',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        if (widget.isHrMode) ...[
          if (!_isEditMode)
            ElevatedButton.icon(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF782B),
                foregroundColor: Colors.white,
              ),
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: _isSaving ? null : _toggleEditMode,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }

  Widget _buildSalaryDetails(BuildContext context, CompensationInfo compensation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Salary Structure', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _EditableNumberField(
              label: 'Basic',
              value: compensation.basic,
              isEditMode: widget.isHrMode && _isEditMode, // Only editable when HR is in edit mode
              onChanged: (val) {
                setState(() {
                  _workingCopy = CompensationInfo(
                    basic: val,
                    gross: _workingCopy.gross,
                    net: _workingCopy.net,
                    travelAllowance: _workingCopy.travelAllowance,
                    payslips: _workingCopy.payslips,
                    bonusesAndIncentives: _workingCopy.bonusesAndIncentives,
                    benefitsSummary: _workingCopy.benefitsSummary,
                    compensationLetters: _workingCopy.compensationLetters,
                    offerLetters: _workingCopy.offerLetters,
                    reimbursements: _workingCopy.reimbursements,
                    compensationPolicies: _workingCopy.compensationPolicies,
                  );
                });
              },
            ),
            _EditableNumberField(
              label: 'Gross',
              value: compensation.gross,
              isEditMode: widget.isHrMode && _isEditMode,
              onChanged: (val) {
                setState(() {
                  _workingCopy = CompensationInfo(
                    basic: _workingCopy.basic,
                    gross: val,
                    net: _workingCopy.net,
                    travelAllowance: _workingCopy.travelAllowance,
                    payslips: _workingCopy.payslips,
                    bonusesAndIncentives: _workingCopy.bonusesAndIncentives,
                    benefitsSummary: _workingCopy.benefitsSummary,
                    compensationLetters: _workingCopy.compensationLetters,
                    offerLetters: _workingCopy.offerLetters,
                    reimbursements: _workingCopy.reimbursements,
                    compensationPolicies: _workingCopy.compensationPolicies,
                  );
                });
              },
            ),
            _EditableNumberField(
              label: 'Net',
              value: compensation.net,
              isEditMode: widget.isHrMode && _isEditMode,
              onChanged: (val) {
                setState(() {
                  _workingCopy = CompensationInfo(
                    basic: _workingCopy.basic,
                    gross: _workingCopy.gross,
                    net: val,
                    travelAllowance: _workingCopy.travelAllowance,
                    payslips: _workingCopy.payslips,
                    bonusesAndIncentives: _workingCopy.bonusesAndIncentives,
                    benefitsSummary: _workingCopy.benefitsSummary,
                    compensationLetters: _workingCopy.compensationLetters,
                    offerLetters: _workingCopy.offerLetters,
                    reimbursements: _workingCopy.reimbursements,
                    compensationPolicies: _workingCopy.compensationPolicies,
                  );
                });
              },
            ),
            _EditableNumberField(
              label: 'Travel Allowance',
              value: compensation.travelAllowance,
              isEditMode: widget.isHrMode && _isEditMode,
              onChanged: (val) {
                setState(() {
                  _workingCopy = CompensationInfo(
                    basic: _workingCopy.basic,
                    gross: _workingCopy.gross,
                    net: _workingCopy.net,
                    travelAllowance: val,
                    payslips: _workingCopy.payslips,
                    bonusesAndIncentives: _workingCopy.bonusesAndIncentives,
                    benefitsSummary: _workingCopy.benefitsSummary,
                    compensationLetters: _workingCopy.compensationLetters,
                    offerLetters: _workingCopy.offerLetters,
                    reimbursements: _workingCopy.reimbursements,
                    compensationPolicies: _workingCopy.compensationPolicies,
                  );
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedPayslipFilter(List<int> years) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Payslips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Year dropdown
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: _selectedYear,
                    items: years.map((y) => DropdownMenuItem(
                      value: y,
                      child: Text(y.toString()),
                    )).toList(),
                    onChanged: (val) => setState(() {
                      _selectedYear = val;
                      _selectedMonth = null;
                      _quickFilter = null;
                    }),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Month dropdown with names
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: _selectedMonth,
                    items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(_getMonthName(m)), // Show month name!
                    )).toList(),
                    onChanged: _selectedYear == null ? null : (val) => setState(() {
                      _selectedMonth = val;
                      _quickFilter = null;
                    }),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Clear button
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear Filters',
                  onPressed: () => setState(() {
                    _selectedYear = null;
                    _selectedMonth = null;
                    _quickFilter = QuickFilter.all;
                    _searchQuery = '';
                  }),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Search box
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search by document name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSection(String title, List<CompensationDocument> documents, [List<CompensationDocument>? displayList]) {
    final itemsToShow = displayList ?? documents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (widget.isHrMode)
              ElevatedButton.icon(
                onPressed: () async {
                  final file = await pickDocument(context);
                  if (file != null) {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Uploading document...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                    
                    // Upload to Supabase
                    final error = await EmployeeProfileService.instance
                        .addCompensationDocumentForEmployee(
                          employeeId: widget.employeeId,
                          type: title,
                          name: file.name,
                          data: file.data,
                        );
                    
                    // Close loading dialog
                    if (context.mounted) Navigator.pop(context);
                    
                    if (error == null) {
                      // Reload employee profile from Supabase to get updated documents
                      final reloadedProfile = await EmployeeProfileService.instance
                          .loadEmployeeProfileById(widget.employeeId);
                      
                      if (reloadedProfile != null && context.mounted) {
                        // Update EmployeeDirectory with reloaded profile (addEmployee updates if exists)
                        context.read<EmployeeDirectory>().addEmployee(reloadedProfile);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document uploaded successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document uploaded but profile reload failed. Please refresh.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } else {
                      // Show error
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to upload: $error')),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF782B)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (itemsToShow.isEmpty)
          const Text('No documents available.')
        else
          ...itemsToShow.map((doc) => Card(
                child: InkWell(
                  onDoubleTap: () => _openDocument(context, doc),
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(doc.name),
                    subtitle: Text('Uploaded on: ${doc.date.day}/${doc.date.month}/${doc.date.year}'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          onPressed: () => _openDocument(context, doc),
                          icon: const Icon(Icons.visibility_outlined),
                          tooltip: 'View Document',
                        ),
                        IconButton(
                          onPressed: () => _downloadDocument(context, doc),
                          icon: const Icon(Icons.download_outlined),
                          tooltip: 'Download',
                        ),
                        if (widget.isHrMode)
                          IconButton(
                            onPressed: () async {
                              // Show confirmation dialog
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Document'),
                                  content: Text('Are you sure you want to delete "${doc.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                // Show loading
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => const Center(
                                    child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text('Deleting document...'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );

                                // Delete from Supabase
                                final error = await EmployeeProfileService.instance
                                    .deleteCompensationDocumentForEmployee(
                                      documentName: doc.name,
                                      employeeId: widget.employeeId,
                                    );

                                // Close loading
                                if (context.mounted) Navigator.pop(context);

                                if (error == null) {
                                  // Remove from local state
                                  if (context.mounted) {
                                    setState(() {
                                      itemsToShow.remove(doc);
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Document deleted successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } else {
                                  // Show error
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to delete: $error')),
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: 'Delete Document',
                          ),
                      ],
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

class _EditableNumberField extends StatelessWidget {
  final String label;
  final double value;
  final bool isEditMode;
  final ValueChanged<double> onChanged;

  const _EditableNumberField({
    required this.label,
    required this.value,
    required this.isEditMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      return Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    final controller = TextEditingController(text: value.toString());
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: (str) {
          final val = double.tryParse(str);
          if (val != null) {
            onChanged(val);
          }
        },
      ),
    );
  }
}
