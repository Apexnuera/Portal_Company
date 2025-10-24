import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/image_picker.dart';
import '../state/employee_directory.dart';
import '../services/timesheet_service.dart';
import '../services/faq_service.dart';

class ProfessionalProfileContent extends StatefulWidget {
  final EmployeeProfessionalProfile initialProfile;
  final bool forceEditMode;
  final void Function(EmployeeProfessionalProfile) onSaved;

  const ProfessionalProfileContent({
    Key? key,
    required this.initialProfile,
    this.forceEditMode = false,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<ProfessionalProfileContent> createState() => _ProfessionalProfileContentState();
}

class _FaqReadOnlyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final faq = context.watch<FaqService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("FAQ's", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (faq.faqs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('No FAQs available'),
            )
          else
            ...faq.faqs.map((f) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: Text(f.question, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(f.answer)),
                  ),
                )),
        ],
      ),
    );
  }
}

class _ProfessionalProfileContentState extends State<ProfessionalProfileContent> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _position = TextEditingController();
  final _employeeId = TextEditingController();
  final _department = TextEditingController();
  final _managerName = TextEditingController();
  final _location = TextEditingController();
  final _workSpace = TextEditingController();
  final _jobLevel = TextEditingController();
  final TextEditingController _skillInput = TextEditingController();

  final List<String> _skills = <String>[];
  final List<_EducationEntryForm> _educationForms = <_EducationEntryForm>[];
  final List<String> _defaultEducationLevels = <String>['10', '+2', 'Highest Degree'];
  final List<_EmploymentEntryForm> _employmentForms = <_EmploymentEntryForm>[];

  // State variables
  DateTime? _startDate;
  DateTime? _confirmationDate;
  String? _selectedEmploymentType;
  late bool _isEditMode;

  void _removeEducationEntry(int index) {
    if (!_isEditMode) return;
    setState(() {
      _educationForms.removeAt(index).dispose();
    });
  }

  Future<void> _pickEducationDocument(_EducationEntryForm form) async {
    if (!_isEditMode) return;
    // TODO: Implement file picker for non-web platforms
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File picking not implemented on this platform')),
    );
  }

  void _addEmploymentEntry() {
    if (!_isEditMode) return;
    setState(() {
      _employmentForms.add(_EmploymentEntryForm(EmployeeEmploymentEntry()));
    });
  }

  void _removeEmploymentEntry(int index) {
    if (!_isEditMode) return;
    setState(() {
      _employmentForms.removeAt(index).dispose();
    });
  }

  Future<void> _pickEmploymentDocument(_EmploymentEntryForm form) async {
    if (!_isEditMode) return;
    // TODO: Implement file picker for non-web platforms
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File picking not implemented on this platform')),
    );
  }

  Future<void> _pickEmploymentDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onSelected,
  }) async {
    if (!_isEditMode) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        onSelected(picked);
      });
    }
  }

  void _selectStartDate() async {
    if (!_isEditMode) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectConfirmationDate() async {
    if (!_isEditMode) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _confirmationDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _confirmationDate = picked;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  EmployeeProfessionalProfile _buildUpdatedProfile() {
    final updatedProfile = widget.initialProfile.copy();
    updatedProfile
      ..position = _position.text
      ..employeeId = _employeeId.text
      ..department = _department.text
      ..managerName = _managerName.text
      ..employmentType = _selectedEmploymentType ?? ''
      ..location = _location.text
      ..workSpace = _workSpace.text
      ..jobLevel = _jobLevel.text
      ..skills = _skills.join(', ')
      ..startDate = _startDate
      ..confirmationDate = _confirmationDate
      ..education = _educationForms.map((form) => form.toEntry()).toList()
      ..employmentHistory = _employmentForms.map((form) => form.toEntry()).toList();
    return updatedProfile;
  }

  String _formattedDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  void _openDocument(String name, Uint8List? bytes) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document viewing not implemented')),
    );
  }

  void _addSkill() {
    if (!_isEditMode) return;
    final value = _skillInput.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a skill')),
      );
      return;
    }
    setState(() {
      _skills.add(value);
      _skillInput.clear();
    });
  }

  void _removeSkill(String skill) {
    if (!_isEditMode) return;
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  void initState() {
    super.initState();
    _applyInitialProfile(widget.initialProfile);
    _isEditMode = widget.forceEditMode;
  }

  @override
  void dispose() {
    _position.dispose();
    _employeeId.dispose();
    _department.dispose();
    _managerName.dispose();
    _location.dispose();
    _workSpace.dispose();
    _jobLevel.dispose();
    _skillInput.dispose();
    for (final form in _educationForms) {
      form.dispose();
    }
    for (final form in _employmentForms) {
      form.dispose();
    }
    super.dispose();
  }

  void _applyInitialProfile(EmployeeProfessionalProfile profile) {
    _position.text = profile.position;
    _employeeId.text = profile.employeeId;
    _department.text = profile.department;
    _managerName.text = profile.managerName;
    _location.text = profile.location;
    _workSpace.text = profile.workSpace;
    _jobLevel.text = profile.jobLevel;
    _selectedEmploymentType = profile.employmentType.isEmpty ? null : profile.employmentType;
    _startDate = profile.startDate;
    _confirmationDate = profile.confirmationDate;

    for (final form in _educationForms) {
      form.dispose();
    }
    _educationForms
      ..clear()
      ..addAll(profile.education.map(_EducationEntryForm.new));

    final existingLevels = _educationForms.map((form) => form.level).toSet();
    for (final level in _defaultEducationLevels) {
      if (!existingLevels.contains(level)) {
        _educationForms.add(_EducationEntryForm(EmployeeEducationEntry(level: level)));
      }
    }

    for (final form in _employmentForms) {
      form.dispose();
    }
    _employmentForms
      ..clear()
      ..addAll(profile.employmentHistory.map(_EmploymentEntryForm.new));

    _skills
      ..clear()
      ..addAll(profile.skills
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty));
  }

  @override
  void didUpdateWidget(covariant ProfessionalProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.initialProfile, widget.initialProfile)) {
      setState(() {
        _applyInitialProfile(widget.initialProfile);
        _isEditMode = widget.forceEditMode;
      });
    } else if (oldWidget.forceEditMode != widget.forceEditMode) {
      setState(() {
        _isEditMode = widget.forceEditMode;
      });
    }
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: _isEditMode ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : 'Not set',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    if (!_isEditMode) {
      return _buildReadOnlyField(label, controller.text);
    }
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSkillSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skillset',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (_isEditMode)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillInput,
                  decoration: const InputDecoration(
                    labelText: 'Add skill',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addSkill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF782B),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        if (_isEditMode) const SizedBox(height: 16),
        _skills.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No skills added yet',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills
                    .map(
                      (skill) => _isEditMode
                          ? InputChip(
                              label: Text(skill),
                              onDeleted: () => setState(() => _removeSkill(skill)),
                            )
                          : Chip(label: Text(skill)),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Education Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: _educationForms
              .asMap()
              .entries
              .map((entry) => _buildEducationCard(entry.key, entry.value))
              .toList(),
        ),
        if (_isEditMode) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _educationForms.add(_EducationEntryForm(EmployeeEducationEntry()));
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Education Entry'),
          ),
        ],
      ],
    );
  }

  Widget _buildEducationCard(int index, _EducationEntryForm form) {
    final availableLevels = <String>{
      ..._defaultEducationLevels,
      if (form.level.isNotEmpty) form.level,
    };
    final levelField = _isEditMode
        ? DropdownButtonFormField<String>(
            value: form.level.isEmpty ? null : form.level,
            decoration: const InputDecoration(
              labelText: 'Education Level',
              border: OutlineInputBorder(),
            ),
            items: availableLevels
                .map((level) => DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                form.level = value ?? '';
              });
            },
          )
        : _buildReadOnlyField('Education Level', form.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: levelField),
                if (_isEditMode)
                  IconButton(
                    tooltip: 'Remove entry',
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeEducationEntry(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEducationTextField('Institution / School', form.institution),
            const SizedBox(height: 16),
            _buildEducationTextField('Degree / Course', form.degree),
            const SizedBox(height: 16),
            _buildEducationTextField('Year of Completion', form.year),
            const SizedBox(height: 16),
            _buildEducationTextField('Grade / Percentage', form.grade),
            const SizedBox(height: 16),
            Row(
              children: [
                if (form.documentName != null)
                  TextButton.icon(
                    onPressed: () => _openDocument(form.documentName!, form.documentBytes),
                    icon: const Icon(Icons.visibility),
                    label: Text(form.documentName!),
                  )
                else
                  const Text('No document uploaded'),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isEditMode ? () => _pickEducationDocument(form) : null,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Docs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF782B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationTextField(String label, TextEditingController controller) {
    if (!_isEditMode) {
      return _buildReadOnlyField(label, controller.text);
    }
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
    );
  }

  Widget _buildEmploymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previous Employment History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: _employmentForms
              .asMap()
              .entries
              .map((entry) => _buildEmploymentCard(entry.key, entry.value))
              .toList(),
        ),
        if (_isEditMode) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addEmploymentEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add Employment Entry'),
          ),
        ],
      ],
    );
  }

  Widget _buildEmploymentCard(int index, _EmploymentEntryForm form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildEmploymentTextField('Company name', form.companyName)),
                if (_isEditMode)
                  IconButton(
                    tooltip: 'Remove entry',
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeEmploymentEntry(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEmploymentTextField('Designation', form.designation),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEmploymentDateField(
                    label: 'From date',
                    value: form.fromDate,
                    onTap: () => _pickEmploymentDate(
                      initial: form.fromDate,
                      onSelected: (value) => setState(() => form.fromDate = value),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEmploymentDateField(
                    label: 'To date',
                    value: form.toDate,
                    onTap: () => _pickEmploymentDate(
                      initial: form.toDate,
                      onSelected: (value) => setState(() => form.toDate = value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (form.documentName != null)
                  TextButton.icon(
                    onPressed: () => _openDocument(form.documentName!, form.documentBytes),
                    icon: const Icon(Icons.visibility),
                    label: Text(form.documentName!),
                  )
                else
                  const Text('No document uploaded'),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isEditMode ? () => _pickEmploymentDocument(form) : null,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Docs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF782B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentTextField(String label, TextEditingController controller) {
    if (!_isEditMode) {
      return _buildReadOnlyField(label, controller.text);
    }
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
    );
  }

  Widget _buildEmploymentDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isEditMode ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: _isEditMode ? const Color(0xFFFF782B) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              value == null ? 'Not set' : _formattedDate(value),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Professional Profile',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_isEditMode) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Edit Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isEditMode
                  ? 'You can now edit your professional information. Click "Save Details" when finished.'
                  : 'View and manage your professional information, education, and employment history.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Core Employment Details
            Text(
              'Employment Details',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                final employmentTypeField = DropdownButtonFormField<String>(
                  value: _selectedEmploymentType,
                  decoration: InputDecoration(
                    labelText: 'Employment type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
                    ),
                    filled: !_isEditMode,
                    fillColor: !_isEditMode ? Colors.grey.shade50 : Colors.transparent,
                  ),
                  items: ['Full time', 'Contract', 'Intern']
                      .map((type) => DropdownMenuItem<String>(value: type, child: Text(type)))
                      .toList(),
                  onChanged: _isEditMode
                      ? (value) {
                          setState(() {
                            _selectedEmploymentType = value;
                          });
                        }
                      : null,
                );

                if (!isWide) {
                  return Column(
                    children: [
                      _buildEditableField('Position', _position),
                      const SizedBox(height: 16),
                      _buildEditableField('Employee Id', _employeeId),
                      const SizedBox(height: 16),
                      _buildEditableField('Department', _department),
                      const SizedBox(height: 16),
                      _buildEditableField('Manager name', _managerName),
                      const SizedBox(height: 16),
                      employmentTypeField,
                      const SizedBox(height: 16),
                      _buildEditableField('Location', _location),
                      const SizedBox(height: 16),
                      _buildEditableField('Work space', _workSpace),
                      const SizedBox(height: 16),
                      _buildDateField('Start date', _startDate, _selectStartDate),
                      const SizedBox(height: 16),
                      _buildDateField('Confirmation date', _confirmationDate, _selectConfirmationDate),
                      const SizedBox(height: 16),
                      _buildEditableField('Job level/Grade', _jobLevel),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildEditableField('Position', _position)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildEditableField('Employee Id', _employeeId)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildEditableField('Department', _department)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildEditableField('Manager name', _managerName)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: employmentTypeField),
                        const SizedBox(width: 16),
                        Expanded(child: _buildEditableField('Location', _location)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildEditableField('Work space', _workSpace)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildEditableField('Job level/Grade', _jobLevel)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDateField('Start date', _startDate, _selectStartDate)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDateField('Confirmation date', _confirmationDate, _selectConfirmationDate)),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            _buildEducationSection(),

            const SizedBox(height: 32),

            _buildSkillSection(),

            const SizedBox(height: 32),

            _buildEmploymentSection(),

            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_isEditMode) {
                    // Save mode - validate and save
                    if (_formKey.currentState!.validate()) {
                      final updatedProfile = _buildUpdatedProfile();
                      widget.onSaved(updatedProfile);
                      setState(() {
                        _isEditMode = widget.forceEditMode;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Professional profile saved successfully!')),
                      );
                    }
                  } else {
                    // Edit mode - switch to edit mode
                    _toggleEditMode();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditMode ? Colors.green : const Color(0xFFFF782B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isEditMode ? 'Save Details' : 'Edit Professional Profile',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationEntryForm {
  String level = '';
  TextEditingController institution = TextEditingController();
  TextEditingController degree = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController grade = TextEditingController();
  String? documentName;
  Uint8List? documentBytes;

  _EducationEntryForm(EmployeeEducationEntry entry) {
    level = entry.level;
    institution.text = entry.institution;
    degree.text = entry.degree;
    year.text = entry.year;
    grade.text = entry.grade;
    documentName = entry.documentName;
    documentBytes = entry.documentBytes;
  }

  void dispose() {
    institution.dispose();
    degree.dispose();
    year.dispose();
    grade.dispose();
  }

  EmployeeEducationEntry toEntry() {
    return EmployeeEducationEntry(
      level: level,
      institution: institution.text,
      degree: degree.text,
      year: year.text,
      grade: grade.text,
      documentName: documentName,
      documentBytes: documentBytes,
    );
  }
}

class _EmploymentEntryForm {
  TextEditingController companyName = TextEditingController();
  TextEditingController designation = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;
  String? documentName;
  Uint8List? documentBytes;

  _EmploymentEntryForm(EmployeeEmploymentEntry entry) {
    companyName.text = entry.companyName;
    designation.text = entry.designation;
    fromDate = entry.fromDate;
    toDate = entry.toDate;
    documentName = entry.documentName;
    documentBytes = entry.documentBytes;
  }

  void dispose() {
    companyName.dispose();
    designation.dispose();
  }

  EmployeeEmploymentEntry toEntry() {
    return EmployeeEmploymentEntry(
      companyName: companyName.text,
      designation: designation.text,
      fromDate: fromDate,
      toDate: toDate,
      documentName: documentName,
      documentBytes: documentBytes,
    );
  }
}

class EmployeeDashboardPage extends StatelessWidget {
  const EmployeeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final directory = context.watch<EmployeeDirectory>();
    final employeeId = directory.primaryEmployeeId;
    final record = directory.tryGetById(employeeId);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            children: [
              _EmployeeTopHeader(record: record, employeeId: employeeId),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EmployeeSidebar(),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: record == null
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Text(
                                  'Employee data unavailable',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          : TabBarView(
                              children: [
                                PersonalDetailsContent(employeeId: employeeId),
                                ProfessionalProfileContent(
                                  initialProfile: record.professional,
                                  forceEditMode: false,
                                  onSaved: (updated) {
                                    directory.updateProfessionalProfile(employeeId, updated);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Professional profile saved.')),
                                    );
                                  },
                                ),
                                CompensationContent(employeeId: employeeId),
                                TaxInformationContent(employeeId: employeeId),
                                TimeSheetContent(employeeId: employeeId),
                                _FaqReadOnlyView(),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeeTopHeader extends StatelessWidget {
  const _EmployeeTopHeader({required this.record, required this.employeeId});
  final EmployeeRecord? record;
  final String employeeId;

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF782B);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(6)),
            child: const Text('ApexNuera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search dashboard...',
                  prefixIcon: const Icon(Icons.search, size: 18, color: orange),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: orange.withOpacity(0.4))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: orange.withOpacity(0.3))),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide(color: orange, width: 2)),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(tooltip: 'Alerts', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No new alerts'))), icon: const Icon(Icons.notifications_none)),
          TextButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact support: support@company.com'))), icon: const Icon(Icons.support_agent), label: const Text('Contact')),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final bytes = record?.personal.profileImageBytes;
              if (bytes != null) {
                _showProfilePreview(context, bytes);
              }
            },
            child: CircleAvatar(
              radius: 16,
              backgroundImage: record?.personal.profileImageBytes != null ? MemoryImage(record!.personal.profileImageBytes!) : null,
              child: record?.personal.profileImageBytes == null ? const Icon(Icons.person) : null,
            ),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((record?.personal.fullName.isNotEmpty == true ? record!.personal.fullName : 'John Doe'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(employeeId, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: () {
              // Clear auth state and navigate to login
              context.go('/login/employee');
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showProfilePreview(BuildContext context, Uint8List bytes) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile Preview',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: InteractiveViewer(
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmployeeSidebar extends StatefulWidget {
  @override
  State<_EmployeeSidebar> createState() => _EmployeeSidebarState();
}

class _EmployeeSidebarState extends State<_EmployeeSidebar> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = DefaultTabController.of(context);
    if (_controller != c) {
      _controller?.removeListener(_onTabChanged);
      _controller = c;
      _controller?.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF782B);
    final selected = _controller?.index ?? 0;
    Widget item(String label, IconData icon, int index) {
      final isSelected = selected == index;
      return Material(
        color: isSelected ? orange.withOpacity(0.08) : Colors.transparent,
        child: InkWell(
          onTap: () => _controller?.animateTo(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(width: 4, height: 24, color: isSelected ? orange : Colors.transparent),
                const SizedBox(width: 12),
                Icon(icon, size: 20, color: isSelected ? orange : Colors.black54),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500))),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: 240,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          item('Personal Details', Icons.person_outline, 0),
          item('Professional Details', Icons.badge_outlined, 1),
          item('Compensation', Icons.account_balance_wallet_outlined, 2),
          item('Tax Information', Icons.assignment_outlined, 3),
          item('Timesheet', Icons.access_time, 4),
          item("FAQs", Icons.help_outline, 5),
        ],
      ),
    );
  }
}

class PersonalDetailsContent extends StatefulWidget {
  const PersonalDetailsContent({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  final String employeeId;

  @override
  State<PersonalDetailsContent> createState() => _PersonalDetailsContentState();
}

class _PersonalDetailsContentState extends State<PersonalDetailsContent> {
  bool _isEditMode = false;
  late EmployeePersonalDetails _workingCopy;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _familyNameController;
  late TextEditingController _corporateEmailController;
  late TextEditingController _personalEmailController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _alternateMobileController;
  late TextEditingController _currentAddressController;
  late TextEditingController _permanentAddressController;
  late TextEditingController _panIdController;
  late TextEditingController _aadharIdController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _otherAssetsController;
  DateTime? _dateOfBirth;
  Set<String> _selectedAssets = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final directory = context.read<EmployeeDirectory>();
    final record = directory.getById(widget.employeeId);
    _workingCopy = record.personal.copy();
    
    _fullNameController = TextEditingController(text: _workingCopy.fullName);
    _familyNameController = TextEditingController(text: _workingCopy.familyName);
    _corporateEmailController = TextEditingController(text: _workingCopy.corporateEmail);
    _personalEmailController = TextEditingController(text: _workingCopy.personalEmail);
    _mobileNumberController = TextEditingController(text: _workingCopy.mobileNumber);
    _alternateMobileController = TextEditingController(text: _workingCopy.alternateMobileNumber);
    _currentAddressController = TextEditingController(text: _workingCopy.currentAddress);
    _permanentAddressController = TextEditingController(text: _workingCopy.permanentAddress);
    _panIdController = TextEditingController(text: _workingCopy.panId);
    _aadharIdController = TextEditingController(text: _workingCopy.aadharId);
    _bloodGroupController = TextEditingController(text: _workingCopy.bloodGroup);
    _otherAssetsController = TextEditingController(text: _workingCopy.otherAssets);
    _dateOfBirth = _workingCopy.dateOfBirth;
    _selectedAssets = Set<String>.from(_workingCopy.assignedAssets);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _familyNameController.dispose();
    _corporateEmailController.dispose();
    _personalEmailController.dispose();
    _mobileNumberController.dispose();
    _alternateMobileController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _panIdController.dispose();
    _aadharIdController.dispose();
    _bloodGroupController.dispose();
    _otherAssetsController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        // Cancel edit mode - reset to original values
        _initializeControllers();
      }
      _isEditMode = !_isEditMode;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      // Update working copy with form values
      _workingCopy.fullName = _fullNameController.text;
      _workingCopy.familyName = _familyNameController.text;
      _workingCopy.corporateEmail = _corporateEmailController.text;
      _workingCopy.personalEmail = _personalEmailController.text;
      _workingCopy.mobileNumber = _mobileNumberController.text;
      _workingCopy.alternateMobileNumber = _alternateMobileController.text;
      _workingCopy.currentAddress = _currentAddressController.text;
      _workingCopy.permanentAddress = _permanentAddressController.text;
      _workingCopy.panId = _panIdController.text;
      _workingCopy.aadharId = _aadharIdController.text;
      _workingCopy.bloodGroup = _bloodGroupController.text;
      _workingCopy.dateOfBirth = _dateOfBirth;
      _workingCopy.assignedAssets = _selectedAssets;
      _workingCopy.otherAssets = _otherAssetsController.text;

      // Save to directory
      final directory = context.read<EmployeeDirectory>();
      directory.updatePersonalDetails(widget.employeeId, _workingCopy);

      setState(() {
        _isEditMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal details saved successfully')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildField(String label, TextEditingController controller, {
    double width = 300,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    if (!_isEditMode) {
      return Container(
        width: width,
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
            Text(controller.text.isEmpty ? 'Not set' : controller.text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final directory = context.watch<EmployeeDirectory>();
    final record = directory.getById(widget.employeeId);
    final p = record.personal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Personal Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const Spacer(),
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
                      OutlinedButton(
                        onPressed: _toggleEditMode,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildField('Full Name', _fullNameController),
                _buildField('Father/Mother/Spouse Name', _familyNameController),
                _buildField('Employee Email', _corporateEmailController),
                _buildField('Personal Email', _personalEmailController),
                _buildField('Contact Number', _mobileNumberController),
                _buildField('Alternate Number', _alternateMobileController),
                if (!_isEditMode)
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date of Birth', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(_formatDate(_dateOfBirth), style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: 300,
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_formatDate(_dateOfBirth)),
                      ),
                    ),
                  ),
                _buildField('Blood Group', _bloodGroupController),
                _buildField('Current Address', _currentAddressController, width: 400),
                _buildField('Permanent Address', _permanentAddressController, width: 400),
                _buildField('PAN', _panIdController),
                _buildField('Aadhaar', _aadharIdController),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditMode)
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final bytes = await ImagePickerWeb.pickImage();
                      if (bytes != null && context.mounted) {
                        setState(() {
                          _workingCopy.profileImageBytes = bytes;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile image selected. Click Save to apply.')),
                        );
                      }
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picking not supported on this platform')));
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Profile Picture'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF782B), foregroundColor: Colors.white),
                ),
              ),
            if (_isEditMode) const SizedBox(height: 12),
            // Asset Details Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Asset Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (!_isEditMode)
                    ...[
                      if (_selectedAssets.isEmpty && _otherAssetsController.text.isEmpty)
                        const Text('No assets assigned')
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final asset in _selectedAssets)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text('• $asset'),
                              ),
                            if (_otherAssetsController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text('• ${_otherAssetsController.text}'),
                              ),
                          ],
                        ),
                    ]
                  else
                    ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final asset in ['Laptop', 'Mobile', 'ID Card', 'Access Card'])
                            FilterChip(
                              label: Text(asset),
                              selected: _selectedAssets.contains(asset),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedAssets.add(asset);
                                  } else {
                                    _selectedAssets.remove(asset);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _otherAssetsController,
                        decoration: const InputDecoration(
                          labelText: 'Other Assets',
                          hintText: 'Enter any other assets',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compensation Section with Edit/Save functionality
class CompensationContent extends StatefulWidget {
  const CompensationContent({Key? key, required this.employeeId}) : super(key: key);
  final String employeeId;

  @override
  State<CompensationContent> createState() => _CompensationContentState();
}

class _CompensationContentState extends State<CompensationContent> {
  bool _isEditMode = false;
  late CompensationInfo _workingCopy;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _basicController;
  late TextEditingController _netController;
  late TextEditingController _grossController;
  late TextEditingController _travelController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final directory = context.read<EmployeeDirectory>();
    final record = directory.getById(widget.employeeId);
    _workingCopy = record.compensation.copy();

    _basicController = TextEditingController(text: _workingCopy.salaryComponents['basic']?.toString() ?? '0');
    _netController = TextEditingController(text: _workingCopy.salaryComponents['net']?.toString() ?? '0');
    _grossController = TextEditingController(text: _workingCopy.salaryComponents['gross']?.toString() ?? '0');
    _travelController = TextEditingController(text: _workingCopy.salaryComponents['travel']?.toString() ?? '0');
  }

  @override
  void dispose() {
    _basicController.dispose();
    _netController.dispose();
    _grossController.dispose();
    _travelController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        _initializeControllers();
      }
      _isEditMode = !_isEditMode;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      _workingCopy.salaryComponents['basic'] = double.tryParse(_basicController.text) ?? 0;
      _workingCopy.salaryComponents['net'] = double.tryParse(_netController.text) ?? 0;
      _workingCopy.salaryComponents['gross'] = double.tryParse(_grossController.text) ?? 0;
      _workingCopy.salaryComponents['travel'] = double.tryParse(_travelController.text) ?? 0;

      final directory = context.read<EmployeeDirectory>();
      directory.updateCompensation(widget.employeeId, _workingCopy);

      setState(() => _isEditMode = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compensation details saved successfully')),
      );
    }
  }

  Widget _buildSalaryField(String label, TextEditingController controller) {
    if (!_isEditMode) {
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
            Text('₹ ${controller.text}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          if (double.tryParse(value) == null) return 'Invalid number';
          return null;
        },
      ),
    );
  }

  void _addItem(String listType) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $listType'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (text != null && text.isNotEmpty) {
      setState(() {
        switch (listType) {
          case 'Payslip':
            _workingCopy.payslips.add(text);
            break;
          case 'Bonus':
            _workingCopy.bonuses.add(text);
            break;
          case 'Benefit':
            _workingCopy.benefits.add(text);
            break;
          case 'Document':
            _workingCopy.documents.add(text);
            break;
          case 'Reimbursement':
            _workingCopy.reimbursements.add(text);
            break;
          case 'Policy':
            _workingCopy.policies.add(text);
            break;
        }
      });
    }
  }

  Widget _buildEditableList(String title, List<String> items, String itemType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (_isEditMode) ...[
              const Spacer(),
              IconButton(
                onPressed: () => _addItem(itemType),
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF782B)),
                tooltip: 'Add $itemType',
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: items.isEmpty
              ? const Text('No data available')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text('• $item')),
                          if (_isEditMode)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              onPressed: () => setState(() => items.remove(item)),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Compensation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const Spacer(),
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
                      OutlinedButton(onPressed: _toggleEditMode, child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Salary Structure', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildSalaryField('Basic', _basicController),
                _buildSalaryField('Net', _netController),
                _buildSalaryField('Gross', _grossController),
                _buildSalaryField('Travel Allowance', _travelController),
              ],
            ),
            _buildEditableList('Payslips', _workingCopy.payslips, 'Payslip'),
            _buildEditableList('Bonuses & Incentives', _workingCopy.bonuses, 'Bonus'),
            _buildEditableList('Benefits Summary', _workingCopy.benefits, 'Benefit'),
            _buildEditableList('Compensation Letters/Agreements', _workingCopy.documents, 'Document'),
            _buildEditableList('Reimbursements', _workingCopy.reimbursements, 'Reimbursement'),
            _buildEditableList('Compensation Policies & FAQs', _workingCopy.policies, 'Policy'),
            if (_isEditMode) ...[
              const SizedBox(height: 16),
              const Text('Deductions', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _workingCopy.selectedDeduction.isEmpty ? null : _workingCopy.selectedDeduction,
                items: const [
                  DropdownMenuItem(value: 'PF', child: Text('Provident Fund')),
                  DropdownMenuItem(value: 'ESI', child: Text('ESI')),
                  DropdownMenuItem(value: 'PT', child: Text('Professional Tax')),
                  DropdownMenuItem(value: 'TDS', child: Text('TDS')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Deduction Type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _workingCopy.selectedDeduction = value ?? '';
                  });
                },
              ),
            ] else if (_workingCopy.selectedDeduction.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selected Deduction', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(_workingCopy.selectedDeduction, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Tax Information Section with Edit/Save functionality  
class TaxInformationContent extends StatefulWidget {
  const TaxInformationContent({Key? key, required this.employeeId}) : super(key: key);
  final String employeeId;

  @override
  State<TaxInformationContent> createState() => _TaxInformationContentState();
}

class _TaxInformationContentState extends State<TaxInformationContent> {
  bool _isEditMode = false;
  late TaxInfo _workingCopy;
  String? _selectedRegime;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final directory = context.read<EmployeeDirectory>();
    final record = directory.getById(widget.employeeId);
    _workingCopy = record.tax.copy();
    _selectedRegime = _workingCopy.regime.isEmpty ? null : _workingCopy.regime;
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        _initializeData();
      }
      _isEditMode = !_isEditMode;
    });
  }

  void _saveChanges() {
    _workingCopy.regime = _selectedRegime ?? '';
    
    final directory = context.read<EmployeeDirectory>();
    directory.updateTax(widget.employeeId, _workingCopy);

    setState(() => _isEditMode = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tax information saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Tax Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const Spacer(),
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
                    OutlinedButton(onPressed: _toggleEditMode, child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isEditMode)
            Container(
              width: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected Tax Regime', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(_selectedRegime ?? 'Not selected', style: const TextStyle(fontSize: 16)),
                ],
              ),
            )
          else
            SizedBox(
              width: 300,
              child: DropdownButtonFormField<String>(
                value: _selectedRegime,
                decoration: const InputDecoration(
                  labelText: 'Tax Regime',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'New', child: Text('New Tax Regime')),
                  DropdownMenuItem(value: 'Old', child: Text('Old Tax Regime')),
                ],
                onChanged: (value) => setState(() => _selectedRegime = value),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadOnlyPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _ReadOnlyPlaceholder({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        ],
      ),
    );
  }
}

class TimeSheetContent extends StatelessWidget {
  const TimeSheetContent({Key? key, required this.employeeId}) : super(key: key);
  final String employeeId;
  
  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TimeSheetService>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Time Sheet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: ts.isClockedIn ? null : () => ts.clockIn(),
                icon: const Icon(Icons.login),
                label: const Text('Clock In'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: ts.isClockedIn && !ts.isClockedOut ? () => ts.clockOut() : null,
                icon: const Icon(Icons.logout),
                label: const Text('Clock Out'),
              ),
              const SizedBox(width: 16),
              if (ts.todayAttendance != null)
                Text('Today: '
                    '${ts.todayAttendance!.clockInTime != null ? 'In ${ts.formatTime(ts.todayAttendance!.clockInTime!)}' : '-'}'
                    ' • '
                    '${ts.todayAttendance!.clockOutTime != null ? 'Out ${ts.formatTime(ts.todayAttendance!.clockOutTime!)}' : '-'}'),
            ],
          ),
          const SizedBox(height: 24),
          const _TimeSheetLeaveForm(),
          const SizedBox(height: 24),
          const _TimeSheetWFHForm(),
          const SizedBox(height: 24),
          const _TimeSheetAttendanceList(),
          const SizedBox(height: 24),
          const _TimeSheetHolidayList(),
        ],
      ),
    );
  }
}

class _TimeSheetAttendanceList extends StatelessWidget {
  const _TimeSheetAttendanceList();
  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TimeSheetService>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attendance Records', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ts.attendanceRecords.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: ts.attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final a = ts.attendanceRecords[index];
                    return ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(ts.formatDate(a.date)),
                      subtitle: Text('In: ${a.clockInTime != null ? ts.formatTime(a.clockInTime!) : '-'}  •  Out: ${a.clockOutTime != null ? ts.formatTime(a.clockOutTime!) : '-'}  •  ${a.workingHoursFormatted}'),
                      trailing: Text(a.status),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TimeSheetLeaveForm extends StatefulWidget {
  const _TimeSheetLeaveForm();
  @override
  State<_TimeSheetLeaveForm> createState() => _TimeSheetLeaveFormState();
}

class _TimeSheetLeaveFormState extends State<_TimeSheetLeaveForm> {
  DateTime? _start;
  DateTime? _end;
  String? _type;
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final ts = Provider.of<TimeSheetService>(context, listen: false);
    final initial = start ? (_start ?? DateTime.now()) : (_end ?? _start ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _start = picked;
          if (_end != null && _end!.isBefore(_start!)) _end = _start;
        } else {
          _end = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TimeSheetService>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Leave Request', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                value: _type,
                items: ts.leaveTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                decoration: const InputDecoration(labelText: 'Leave type', border: OutlineInputBorder()),
                onChanged: (v) => setState(() => _type = v),
              ),
            ),
            SizedBox(
              width: 220,
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(start: true),
                icon: const Icon(Icons.date_range),
                label: Text(_start == null ? 'Start date' : ts.formatDate(_start!)),
              ),
            ),
            SizedBox(
              width: 220,
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(start: false),
                icon: const Icon(Icons.date_range),
                label: Text(_end == null ? 'End date' : ts.formatDate(_end!)),
              ),
            ),
            SizedBox(
              width: 320,
              child: TextField(
                controller: _reason,
                decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
              ),
            ),
            ElevatedButton(
              onPressed: _type != null && _start != null && _end != null && _reason.text.trim().isNotEmpty
                  ? () async {
                      final ok = await ts.submitLeaveRequest(
                        startDate: _start!,
                        endDate: _end!,
                        leaveType: _type!,
                        reason: _reason.text.trim(),
                      );
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request submitted')));
                        setState(() {
                          _start = null;
                          _end = null;
                          _type = null;
                          _reason.clear();
                        });
                      }
                    }
                  : null,
              child: const Text('Submit Leave'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeSheetWFHForm extends StatefulWidget {
  const _TimeSheetWFHForm();
  @override
  State<_TimeSheetWFHForm> createState() => _TimeSheetWFHFormState();
}

class _TimeSheetWFHFormState extends State<_TimeSheetWFHForm> {
  DateTime? _date;
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TimeSheetService>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WFH Request', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.date_range),
              label: Text(_date == null ? 'Select date' : ts.formatDate(_date!)),
            ),
            SizedBox(
              width: 320,
              child: TextField(
                controller: _reason,
                decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
              ),
            ),
            ElevatedButton(
              onPressed: _date != null && _reason.text.trim().isNotEmpty
                  ? () async {
                      final ok = await ts.submitWFHRequest(date: _date!, reason: _reason.text.trim());
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WFH request submitted')));
                        setState(() {
                          _date = null;
                          _reason.clear();
                        });
                      }
                    }
                  : null,
              child: const Text('Submit WFH'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeSheetHolidayList extends StatelessWidget {
  const _TimeSheetHolidayList();
  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TimeSheetService>(context);
    final now = DateTime.now();
    final holidays = ts.getHolidaysForMonth(now.year, now.month);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Holiday Calendar', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: holidays.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: holidays.length,
                  itemBuilder: (context, index) {
                    final h = holidays[index];
                    return ListTile(
                      leading: const Icon(Icons.event_available),
                      title: Text('${h.name} (${h.type})'),
                      subtitle: Text(ts.formatDate(h.date)),
                    );
                  },
                ),
        ),
      ],
    );
  }

}

class _TaxReadOnlyView extends StatelessWidget {
  final String employeeId;
  const _TaxReadOnlyView({required this.employeeId});
  @override
  Widget build(BuildContext context) {
    final directory = context.watch<EmployeeDirectory>();
    final record = directory.getById(employeeId);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tax Information (Read-Only)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _KeyValue('Selected Tax Regime', record.tax.regime.isEmpty ? 'Not selected' : record.tax.regime),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValue(this.label, this.value);
  @override
  Widget build(BuildContext context) {
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
          Text(value.isEmpty ? 'Not set' : value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _KeyList extends StatelessWidget {
  final String title;
  final List<String> items;
  const _KeyList(this.title, this.items);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: items.isEmpty
              ? const Text('No data available')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('• $e'))).toList(),
                ),
        ),
      ],
    );
  }
}
