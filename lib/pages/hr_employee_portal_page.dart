import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/employee_directory.dart';

class HREmployeePortalPage extends StatefulWidget {
  const HREmployeePortalPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  State<HREmployeePortalPage> createState() => _HREmployeePortalPageState();
}

class _HREmployeePortalPageState extends State<HREmployeePortalPage> {
  int _selectedIndex = 0;
  late EmployeeRecord _workingRecord;
  bool _isEditMode = false; // Default to read-only mode

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final directory = context.read<EmployeeDirectory>();
    final record = directory.tryGetById(widget.employeeId) ??
        directory.employees.first;
    _workingRecord = record.copy();
  }

  void _toggleEditMode() {
    setState(() {
      if (!_isEditMode) {
        final directory = context.read<EmployeeDirectory>();
        final record = directory.tryGetById(widget.employeeId) ??
            directory.employees.first;
        _workingRecord = record.copy();
      }
      _isEditMode = !_isEditMode;
    });
  }

  void _saveChanges() {
    final directory = context.read<EmployeeDirectory>();
    directory.updatePersonalDetails(widget.employeeId, _workingRecord.personal);
    directory.updateProfessionalProfile(widget.employeeId, _workingRecord.professional);
    directory.updateProfileImage(widget.employeeId, _workingRecord.personal.profileImageBytes);
    setState(() {
      _isEditMode = false; // Revert to read-only mode after saving
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully. Switched back to View Mode.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final directory = context.watch<EmployeeDirectory>();
    final liveRecord = directory.tryGetById(widget.employeeId) ??
        directory.employees.first;
    if (!_isEditMode) {
      _workingRecord = liveRecord.copy();
    }

    final tabs = <_PortalTab>[
      _PortalTab(
        icon: Icons.person_outline,
        label: 'Personal Details',
        builder: (context) => _PersonalDetailsEditor(
          personal: _workingRecord.personal,
          onChanged: () => setState(() {}),
          isEditMode: _isEditMode,
        ),
      ),
      _PortalTab(
        icon: Icons.work_outline,
        label: 'Professional Profile',
        builder: (context) => _ProfessionalProfileEditor(
          profile: _workingRecord.professional,
          onChanged: () => setState(() {}),
          isEditMode: _isEditMode,
        ),
      ),
      _PortalTab(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Compensation',
        builder: (context) => _CompensationEditor(record: _workingRecord, isEditMode: _isEditMode),
      ),
      _PortalTab(
        icon: Icons.assignment_outlined,
        label: 'Tax Information',
        builder: (context) => _TaxInformationEditor(record: _workingRecord, isEditMode: _isEditMode),
      ),
      _PortalTab(
        icon: Icons.access_time_outlined,
        label: 'Time Sheet',
        builder: (context) => _TimeSheetEditor(record: _workingRecord, isEditMode: _isEditMode),
      ),
      _PortalTab(
        icon: Icons.help_outline,
        label: "FAQ's",
        builder: (context) => _FaqEditor(record: _workingRecord, isEditMode: _isEditMode),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Portal — ${_workingRecord.personal.fullName}'),
        backgroundColor: const Color(0xFFFF782B), // Orange theme from HR Dashboard
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _isEditMode ? _saveChanges : _toggleEditMode,
              icon: Icon(_isEditMode ? Icons.save : Icons.edit),
              label: Text(_isEditMode ? 'Save Changes' : 'Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditMode ? Colors.green : const Color(0xFFFF782B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            color: const Color(0xFFFF782B).withOpacity(0.1), // Light orange background
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                return ChoiceChip(
                  label: Text(tab.label),
                  avatar: Icon(tab.icon, color: _selectedIndex == index ? Colors.white : const Color(0xFFFF782B)),
                  selected: _selectedIndex == index,
                  selectedColor: const Color(0xFFFF782B),
                  onSelected: (_) {
                    setState(() => _selectedIndex = index);
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: tabs.length,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: tabs[_selectedIndex].builder(context),
          ),
        ],
      ),
    );
  }
}

class _PortalTab {
  const _PortalTab({
    required this.icon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}

class _PersonalDetailsEditor extends StatefulWidget {
  const _PersonalDetailsEditor({
    required this.personal,
    required this.onChanged,
    required this.isEditMode,
  });

  final EmployeePersonalDetails personal;
  final VoidCallback onChanged;
  final bool isEditMode;

  @override
  State<_PersonalDetailsEditor> createState() => _PersonalDetailsEditorState();
}

class _PersonalDetailsEditorState extends State<_PersonalDetailsEditor> {
  late TextEditingController _fullName;
  late TextEditingController _familyName;
  late TextEditingController _corporateEmail;
  late TextEditingController _personalEmail;
  late TextEditingController _mobile;
  late TextEditingController _alternateMobile;
  late TextEditingController _currentAddress;
  late TextEditingController _permanentAddress;
  late TextEditingController _panId;
  late TextEditingController _aadharId;
  late DateTime? _dob;
  late String _bloodGroup;
  final List<String> _assets = const [
    'Laptop',
    'Desktop',
    'Monitor',
    'Keyboard',
    'Mouse',
    'Headphones',
    'Mobile Phone',
  ];

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.personal.fullName);
    _familyName = TextEditingController(text: widget.personal.familyName);
    _corporateEmail = TextEditingController(text: widget.personal.corporateEmail);
    _personalEmail = TextEditingController(text: widget.personal.personalEmail);
    _mobile = TextEditingController(text: widget.personal.mobileNumber);
    _alternateMobile = TextEditingController(text: widget.personal.alternateMobileNumber);
    _currentAddress = TextEditingController(text: widget.personal.currentAddress);
    _permanentAddress = TextEditingController(text: widget.personal.permanentAddress);
    _panId = TextEditingController(text: widget.personal.panId);
    _aadharId = TextEditingController(text: widget.personal.aadharId);
    _dob = widget.personal.dateOfBirth;
    _bloodGroup = widget.personal.bloodGroup;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _familyName.dispose();
    _corporateEmail.dispose();
    _personalEmail.dispose();
    _mobile.dispose();
    _alternateMobile.dispose();
    _currentAddress.dispose();
    _permanentAddress.dispose();
    _panId.dispose();
    _aadharId.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PersonalDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.personal, widget.personal)) {
      _fullName.text = widget.personal.fullName;
      _familyName.text = widget.personal.familyName;
      _corporateEmail.text = widget.personal.corporateEmail;
      _personalEmail.text = widget.personal.personalEmail;
      _mobile.text = widget.personal.mobileNumber;
      _alternateMobile.text = widget.personal.alternateMobileNumber;
      _currentAddress.text = widget.personal.currentAddress;
      _permanentAddress.text = widget.personal.permanentAddress;
      _panId.text = widget.personal.panId;
      _aadharId.text = widget.personal.aadharId;
      setState(() {
        _dob = widget.personal.dateOfBirth;
        _bloodGroup = widget.personal.bloodGroup;
      });
    } else if (oldWidget.isEditMode != widget.isEditMode) {
      setState(() {});
    }
  }

  Future<void> _pickDate() async {
    if (!widget.isEditMode) return; // Only allow editing in edit mode

    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        widget.personal.dateOfBirth = picked;
      });
      widget.onChanged();
    }
  }

  void _toggleAsset(String asset) {
    if (!widget.isEditMode) return; // Only allow editing in edit mode

    setState(() {
      if (widget.personal.assignedAssets.contains(asset)) {
        widget.personal.assignedAssets.remove(asset);
      } else {
        widget.personal.assignedAssets.add(asset);
      }
    });
    widget.onChanged();
  }

  void _applyChanges() {
    if (!widget.isEditMode) return; // Only allow changes in edit mode

    widget.personal
      ..fullName = _fullName.text
      ..familyName = _familyName.text
      ..corporateEmail = _corporateEmail.text
      ..personalEmail = _personalEmail.text
      ..mobileNumber = _mobile.text
      ..alternateMobileNumber = _alternateMobile.text
      ..currentAddress = _currentAddress.text
      ..permanentAddress = _permanentAddress.text
      ..panId = _panId.text
      ..aadharId = _aadharId.text
      ..bloodGroup = _bloodGroup;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabeledField('Full Name', _fullName, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Family Name', _familyName, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Corporate Email', _corporateEmail, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Personal Email', _personalEmail, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Mobile Number', _mobile, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Alternate Number', _alternateMobile, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Current Address', _currentAddress, maxLines: 3, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Permanent Address', _permanentAddress, maxLines: 3, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('PAN ID', _panId, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Aadhar ID', _aadharId, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _DatePickerField(
            label: 'Date of Birth',
            date: _dob,
            onTap: _pickDate,
            isEditMode: widget.isEditMode,
          ),
          _DropdownField<String>(
            label: 'Blood Group',
            value: _bloodGroup.isEmpty ? null : _bloodGroup,
            items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            isEditMode: widget.isEditMode,
            onChanged: (value) {
              if (value == null || !widget.isEditMode) return;
              setState(() {
                _bloodGroup = value;
                widget.personal.bloodGroup = value;
              });
              widget.onChanged();
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final asset in _assets)
                FilterChip(
                  label: Text(asset),
                  selected: widget.personal.assignedAssets.contains(asset),
                  onSelected: widget.isEditMode ? (_) => _toggleAsset(asset) : null,
                  backgroundColor: widget.isEditMode ? null : Colors.grey.shade100,
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: widget.personal.otherAssets)
              ..selection = TextSelection.collapsed(offset: widget.personal.otherAssets.length),
            enabled: widget.isEditMode,
            decoration: InputDecoration(
              labelText: 'Other Assets',
              border: const OutlineInputBorder(),
              filled: !widget.isEditMode,
              fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
            ),
            onChanged: (value) {
              if (widget.isEditMode) {
                widget.personal.otherAssets = value;
                widget.onChanged();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProfessionalProfileEditor extends StatefulWidget {
  const _ProfessionalProfileEditor({
    required this.profile,
    required this.onChanged,
    required this.isEditMode,
  });

  final EmployeeProfessionalProfile profile;
  final VoidCallback onChanged;
  final bool isEditMode;

  @override
  State<_ProfessionalProfileEditor> createState() => _ProfessionalProfileEditorState();
}

class _ProfessionalProfileEditorState extends State<_ProfessionalProfileEditor> {
  late TextEditingController _position;
  late TextEditingController _employeeId;
  late TextEditingController _department;
  late TextEditingController _managerName;
  late TextEditingController _employmentType;
  late TextEditingController _location;
  late TextEditingController _workspace;
  late TextEditingController _jobLevel;
  late TextEditingController _skills;
  DateTime? _startDate;
  DateTime? _confirmationDate;

  @override
  void initState() {
    super.initState();
    _position = TextEditingController(text: widget.profile.position);
    _employeeId = TextEditingController(text: widget.profile.employeeId);
    _department = TextEditingController(text: widget.profile.department);
    _managerName = TextEditingController(text: widget.profile.managerName);
    _employmentType = TextEditingController(text: widget.profile.employmentType);
    _location = TextEditingController(text: widget.profile.location);
    _workspace = TextEditingController(text: widget.profile.workSpace);
    _jobLevel = TextEditingController(text: widget.profile.jobLevel);
    _skills = TextEditingController(text: widget.profile.skills);
    _startDate = widget.profile.startDate;
    _confirmationDate = widget.profile.confirmationDate;
  }

  @override
  void dispose() {
    _position.dispose();
    _employeeId.dispose();
    _department.dispose();
    _managerName.dispose();
    _employmentType.dispose();
    _location.dispose();
    _workspace.dispose();
    _jobLevel.dispose();
    _skills.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    if (!widget.isEditMode) return; // Only allow editing in edit mode

    final initial = isStart ? _startDate : _confirmationDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          widget.profile.startDate = picked;
        } else {
          _confirmationDate = picked;
          widget.profile.confirmationDate = picked;
        }
      });
      widget.onChanged();
    }
  }

  void _applyChanges() {
    if (!widget.isEditMode) return; // Only allow changes in edit mode

    widget.profile
      ..position = _position.text
      ..employeeId = _employeeId.text
      ..department = _department.text
      ..managerName = _managerName.text
      ..employmentType = _employmentType.text
      ..location = _location.text
      ..workSpace = _workspace.text
      ..jobLevel = _jobLevel.text
      ..skills = _skills.text;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabeledField('Position', _position, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Employee ID', _employeeId, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Department', _department, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Manager Name', _managerName, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Employment Type', _employmentType, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Location', _location, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Workspace', _workspace, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Job Level', _jobLevel, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _DatePickerField(
            label: 'Start Date',
            date: _startDate,
            onTap: () => _pickDate(isStart: true),
            isEditMode: widget.isEditMode,
          ),
          _DatePickerField(
            label: 'Confirmation Date',
            date: _confirmationDate,
            onTap: () => _pickDate(isStart: false),
            isEditMode: widget.isEditMode,
          ),
          _LabeledField('Skills', _skills, maxLines: 3, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
        ],
      ),
    );
  }
}

class _CompensationEditor extends StatelessWidget {
  const _CompensationEditor({required this.record, required this.isEditMode});

  final EmployeeRecord record;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isEditMode ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: isEditMode ? const Color(0xFFFF782B) : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isEditMode
                  ? 'Compensation & Benefits Editor'
                  : 'Compensation & Benefits (View Mode)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEditMode
                  ? 'Edit salary details, benefits, allowances, and tax information.'
                  : 'View salary details, benefits, and compensation structure.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isEditMode ? const Color(0xFFFF782B).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isEditMode ? const Color(0xFFFF782B).withOpacity(0.3) : Colors.grey.shade300,
                ),
              ),
              child: Text(
                isEditMode
                    ? 'Compensation editing features will be implemented here.'
                    : 'Compensation details will be displayed here in view mode.',
                style: TextStyle(
                  fontSize: 14,
                  color: isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaxInformationEditor extends StatelessWidget {
  const _TaxInformationEditor({required this.record, required this.isEditMode});

  final EmployeeRecord record;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isEditMode ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: isEditMode ? const Color(0xFFFF782B) : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isEditMode
                  ? 'Tax Information Editor'
                  : 'Tax Information (View Mode)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEditMode
                  ? 'Manage tax declarations, exemptions, and tax-saving investments.'
                  : 'View tax-related information and declarations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isEditMode ? const Color(0xFFFF782B).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isEditMode ? const Color(0xFFFF782B).withOpacity(0.3) : Colors.grey.shade300,
                ),
              ),
              child: Text(
                isEditMode
                    ? 'Tax information editing features will be implemented here.'
                    : 'Tax information will be displayed here in view mode.',
                style: TextStyle(
                  fontSize: 14,
                  color: isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSheetEditor extends StatelessWidget {
  const _TimeSheetEditor({required this.record, required this.isEditMode});

  final EmployeeRecord record;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isEditMode ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 64,
              color: isEditMode ? const Color(0xFFFF782B) : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isEditMode
                  ? 'Time Sheet Editor'
                  : 'Time Sheet (View Mode)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEditMode
                  ? 'Track work hours, manage leave requests, and submit timesheets.'
                  : 'View attendance records and timesheet history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isEditMode ? const Color(0xFFFF782B).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isEditMode ? const Color(0xFFFF782B).withOpacity(0.3) : Colors.grey.shade300,
                ),
              ),
              child: Text(
                isEditMode
                    ? 'Time sheet editing features will be implemented here.'
                    : 'Time sheet records will be displayed here in view mode.',
                style: TextStyle(
                  fontSize: 14,
                  color: isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqEditor extends StatelessWidget {
  const _FaqEditor({required this.record, required this.isEditMode});

  final EmployeeRecord record;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isEditMode ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 64,
              color: isEditMode ? const Color(0xFFFF782B) : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isEditMode
                  ? 'FAQ Editor'
                  : 'FAQ (View Mode)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEditMode
                  ? 'Edit and manage frequently asked questions and answers.'
                  : 'Browse frequently asked questions and support resources.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isEditMode ? const Color(0xFFFF782B).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isEditMode ? const Color(0xFFFF782B).withOpacity(0.3) : Colors.grey.shade300,
                ),
              ),
              child: Text(
                isEditMode
                    ? 'FAQ editing features will be implemented here.'
                    : 'FAQ content will be displayed here in view mode.',
                style: TextStyle(
                  fontSize: 14,
                  color: isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField(
    this.label,
    this.controller, {
    this.maxLines = 1,
    this.onChanged,
    this.isEditMode = true,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      // Read-only mode
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.text.isEmpty ? 'Not provided' : controller.text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    // Edit mode
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
    this.isEditMode = true,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      // Read-only mode
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                date != null
                    ? '${date!.day}/${date!.month}/${date!.year}'
                    : 'Not set',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    // Edit mode
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Text(
            date != null
                ? '${date!.day}/${date!.month}/${date!.year}'
                : 'Select $label',
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isEditMode = true,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      // Read-only mode
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value?.toString() ?? 'Not selected',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    // Edit mode
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                ))
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ProfileImagePreview extends StatelessWidget {
  const _ProfileImagePreview({
    required this.imageBytes,
    required this.onPick,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage:
              imageBytes != null ? MemoryImage(imageBytes!) : null,
          child: imageBytes == null ? const Icon(Icons.person, size: 48) : null,
        ),
        TextButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.upload),
          label: const Text('Upload Profile Picture'),
        ),
      ],
    );
  }
}
