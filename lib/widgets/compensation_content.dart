import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/employee_directory.dart';
import '../utils/document_picker.dart';
import '../utils/document_viewer.dart';
import '../utils/document_saver.dart';

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
    final compensation = record.compensation;

    final uniqueYears = compensation.payslips.map((p) => p.date.year).toSet().toList()..sort();

    final filteredPayslips = compensation.payslips.where((p) {
      if (_selectedYear == null) return true; // Show all if no year is selected
      if (p.date.year != _selectedYear) return false;
      if (_selectedMonth == null) return true; // Show all for year if no month is selected
      return p.date.month == _selectedMonth;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSalaryDetails(context, compensation),
          const SizedBox(height: 24),
          _buildPayslipFilter(uniqueYears),
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
    return Text(
      'Compensation',
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
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
              isEditMode: widget.isHrMode,
              onChanged: (val) => context.read<EmployeeDirectory>().updateCompensationValue(widget.employeeId, basic: val),
            ),
            _EditableNumberField(
              label: 'Gross',
              value: compensation.gross,
              isEditMode: widget.isHrMode,
              onChanged: (val) => context.read<EmployeeDirectory>().updateCompensationValue(widget.employeeId, gross: val),
            ),
            _EditableNumberField(
              label: 'Net',
              value: compensation.net,
              isEditMode: widget.isHrMode,
              onChanged: (val) => context.read<EmployeeDirectory>().updateCompensationValue(widget.employeeId, net: val),
            ),
            _EditableNumberField(
              label: 'Travel Allowance',
              value: compensation.travelAllowance,
              isEditMode: widget.isHrMode,
              onChanged: (val) => context.read<EmployeeDirectory>().updateCompensationValue(widget.employeeId, travelAllowance: val),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayslipFilter(List<int> years) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Text('Filter Payslips:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          if (years.isNotEmpty)
            SizedBox(
              width: 150,
              child: DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Select Year'),
                value: _selectedYear,
                onChanged: (val) => setState(() {
                  _selectedYear = val;
                  _selectedMonth = null;
                }),
                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
              ),
            ),
          const SizedBox(width: 16),
          if (_selectedYear != null)
            SizedBox(
              width: 150,
              child: DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Select Month'),
                value: _selectedMonth,
                onChanged: (val) => setState(() => _selectedMonth = val),
                items: List.generate(12, (i) => i + 1)
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.toString())))
                    .toList(),
              ),
            ),
          const SizedBox(width: 16),
          if (_selectedYear != null)
            TextButton(onPressed: () => setState(() {
              _selectedYear = null;
              _selectedMonth = null;
            }), child: const Text('Clear Filter')),
        ],
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
                    context.read<EmployeeDirectory>().addCompensationDocument(widget.employeeId, title, file);
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
