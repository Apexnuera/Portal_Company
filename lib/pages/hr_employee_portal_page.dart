import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timesheet_service.dart';

import '../state/employee_directory.dart';
import '../services/faq_service.dart';

class HREmployeePortalPage extends StatefulWidget {
  const HREmployeePortalPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  State<HREmployeePortalPage> createState() => _HREmployeePortalPageState();
}

class _CompNumberField extends StatelessWidget {
  final String label;
  final String initial;
  final bool isEditMode;
  final ValueChanged<String> onChanged;
  const _CompNumberField({required this.label, required this.initial, required this.isEditMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      return _KeyValueTile(label, initial);
    }
    return SizedBox(
      width: 260,
      child: TextFormField(
        initialValue: initial,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: onChanged,
      ),
    );
  }
}

class _KeyValueTile extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValueTile(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value.isEmpty ? 'Not set' : value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}

class _SimpleEditableList extends StatefulWidget {
  final List<String> items;
  final bool isEditMode;
  const _SimpleEditableList({required this.items, required this.isEditMode});

  @override
  State<_SimpleEditableList> createState() => _SimpleEditableListState();
}

class _SimpleEditableListState extends State<_SimpleEditableList> {
  void _addItem() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Item'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Title/Note')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (text != null && text.isNotEmpty) {
      setState(() => widget.items.insert(0, text));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('No data available'),
            ),
          ),
          if (widget.isEditMode) const SizedBox(width: 12),
          if (widget.isEditMode)
            OutlinedButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Add')),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.items.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(e),
              trailing: widget.isEditMode
                  ? IconButton(
                      onPressed: () => setState(() => widget.items.remove(e)),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    )
                  : null,
            )),
        if (widget.isEditMode)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Add')),
          ),
      ],
    );
  }
}

class _MiniList extends StatelessWidget {
  final List<Widget> children;
  const _MiniList({required this.children});
  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No data available'),
      );
    }
    return Column(children: children);
  }
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
        final record = directory.tryGetById(widget.employeeId);
        if (record == null) return; // Handle missing record
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
    directory.updateCompensation(widget.employeeId, _workingRecord.compensation);
    directory.updateTax(widget.employeeId, _workingRecord.tax);
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
    final liveRecord = directory.tryGetById(widget.employeeId);
    
    // Handle missing employee record
    if (liveRecord == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Employee Portal - Error'),
          backgroundColor: const Color(0xFFFF782B),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Error: Employee profile not found or corrupted.', 
                style: TextStyle(fontSize: 18, color: Colors.red)),
        ),
      );
    }
    
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
          _LabeledField('Father or Mother or Spouse Name', _familyName, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Employee email id', _corporateEmail, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Personal email id', _personalEmail, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Contant number', _mobile, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Alternate number', _alternateMobile, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Current Address', _currentAddress, maxLines: 3, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Permanent Address', _permanentAddress, maxLines: 3, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Pan', _panId, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Adhar', _aadharId, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
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
              labelText: 'Asset details',
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

class _HREducationEntryForm {
  _HREducationEntryForm(EmployeeEducationEntry entry)
      : level = entry.level,
        institution = TextEditingController(text: entry.institution),
        degree = TextEditingController(text: entry.degree),
        year = TextEditingController(text: entry.year),
        grade = TextEditingController(text: entry.grade),
        documentName = entry.documentName,
        documentBytes = entry.documentBytes != null
            ? Uint8List.fromList(entry.documentBytes!)
            : null;

  String level;
  final TextEditingController institution;
  final TextEditingController degree;
  final TextEditingController year;
  final TextEditingController grade;
  String? documentName;
  Uint8List? documentBytes;

  EmployeeEducationEntry toEntry() {
    return EmployeeEducationEntry(
      level: level,
      institution: institution.text,
      degree: degree.text,
      year: year.text,
      grade: grade.text,
      documentName: documentName,
      documentBytes: documentBytes != null
          ? Uint8List.fromList(documentBytes!)
          : null,
    );
  }

  void dispose() {
    institution.dispose();
    degree.dispose();
    year.dispose();
    grade.dispose();
  }
}

class _HREmploymentEntryForm {
  _HREmploymentEntryForm(EmployeeEmploymentEntry entry)
      : companyName = TextEditingController(text: entry.companyName),
        designation = TextEditingController(text: entry.designation),
        fromDate = entry.fromDate,
        toDate = entry.toDate,
        documentName = entry.documentName,
        documentBytes = entry.documentBytes != null
            ? Uint8List.fromList(entry.documentBytes!)
            : null;

  final TextEditingController companyName;
  final TextEditingController designation;
  DateTime? fromDate;
  DateTime? toDate;
  String? documentName;
  Uint8List? documentBytes;

  EmployeeEmploymentEntry toEntry() {
    return EmployeeEmploymentEntry(
      companyName: companyName.text,
      designation: designation.text,
      fromDate: fromDate,
      toDate: toDate,
      documentName: documentName,
      documentBytes: documentBytes != null
          ? Uint8List.fromList(documentBytes!)
          : null,
    );
  }

  void dispose() {
    companyName.dispose();
    designation.dispose();
  }
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
  late TextEditingController _skillInput;
  late List<String> _skills;
  late List<_HREducationEntryForm> _educationForms;
  late List<_HREmploymentEntryForm> _employmentForms;
  final List<String> _defaultEducationLevels = <String>['10', '+2', 'Highest Degree'];
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
    _skillInput = TextEditingController();
    _skills = widget.profile.skills
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    _educationForms = widget.profile.education
        .map(_HREducationEntryForm.new)
        .toList();
    final existingLevels = _educationForms.map((form) => form.level).toSet();
    for (final level in _defaultEducationLevels) {
      if (!existingLevels.contains(level)) {
        _educationForms.add(_HREducationEntryForm(EmployeeEducationEntry(level: level)));
      }
    }
    _employmentForms = widget.profile.employmentHistory
        .map(_HREmploymentEntryForm.new)
        .toList();
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
    _skillInput.dispose();
    for (final form in _educationForms) {
      form.dispose();
    }
    for (final form in _employmentForms) {
      form.dispose();
    }
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
        } else {
          _confirmationDate = picked;
        }
      });
      _writeBackProfile();
    }
  }

  void _applyChanges() {
    if (!widget.isEditMode) return;
    _writeBackProfile();
  }

  void _writeBackProfile() {
    widget.profile
      ..position = _position.text
      ..employeeId = _employeeId.text
      ..department = _department.text
      ..managerName = _managerName.text
      ..employmentType = _employmentType.text
      ..location = _location.text
      ..workSpace = _workspace.text
      ..jobLevel = _jobLevel.text
      ..skills = _skills.join(', ')
      ..education = _educationForms.map((form) => form.toEntry()).toList()
      ..employmentHistory = _employmentForms.map((form) => form.toEntry()).toList()
      ..startDate = _startDate
      ..confirmationDate = _confirmationDate;
    widget.onChanged();
  }

  void _addSkill() {
    if (!widget.isEditMode) return;
    final value = _skillInput.text.trim();
    if (value.isEmpty) return;
    setState(() {
      if (!_skills.contains(value)) {
        _skills.add(value);
      }
      _skillInput.clear();
    });
    _writeBackProfile();
  }

  void _removeSkill(String skill) {
    if (!widget.isEditMode) return;
    setState(() {
      _skills.remove(skill);
    });
    _writeBackProfile();
  }

  void _addEducationEntry() {
    if (!widget.isEditMode) return;
    setState(() {
      _educationForms.add(_HREducationEntryForm(EmployeeEducationEntry()));
    });
    _writeBackProfile();
  }

  void _removeEducationEntry(int index) {
    if (!widget.isEditMode) return;
    setState(() {
      _educationForms.removeAt(index).dispose();
    });
    _writeBackProfile();
  }

  Future<void> _pickEducationDocument(_HREducationEntryForm form) async {
    if (!widget.isEditMode) return;
    final input = html.FileUploadInputElement()
      ..accept = '*/*'
      ..click();
    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) {
      return;
    }
    final file = input.files!.first;
    final reader = html.FileReader()..readAsArrayBuffer(file);
    await reader.onLoad.first;
    final buffer = reader.result as ByteBuffer;
    final bytes = buffer.asUint8List();
    setState(() {
      form
        ..documentName = file.name
        ..documentBytes = Uint8List.fromList(bytes);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploaded ${file.name}')),
    );
    _writeBackProfile();
  }

  void _openDocument(String name, Uint8List? bytes) {
    if (bytes == null) return;
    final blob = html.Blob(<Uint8List>[bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabeledField('Position', _position, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Employee Id', _employeeId, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Department', _department, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Manager name', _managerName, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          if (widget.isEditMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: _employmentType.text.isEmpty ? null : _employmentType.text,
                decoration: const InputDecoration(
                  labelText: 'Employment type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Full time', child: Text('Full time')),
                  DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                  DropdownMenuItem(value: 'Intern', child: Text('Intern')),
                ],
                onChanged: (value) {
                  _employmentType.text = value ?? '';
                  _applyChanges();
                },
              ),
            )
          else
            _LabeledField('Employment type', _employmentType, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Location', _location, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Work space', _workspace, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _LabeledField('Job level/Grade', _jobLevel, isEditMode: widget.isEditMode, onChanged: (_) => _applyChanges()),
          _DatePickerField(
            label: 'Start date',
            date: _startDate,
            onTap: () => _pickDate(isStart: true),
            isEditMode: widget.isEditMode,
          ),
          _DatePickerField(
            label: 'Confirmation date',
            date: _confirmationDate,
            onTap: () => _pickDate(isStart: false),
            isEditMode: widget.isEditMode,
          ),
          const SizedBox(height: 32),
          _buildEducationSection(),
          const SizedBox(height: 32),
          _buildSkillSection(),
          const SizedBox(height: 32),
          _buildEmploymentSection(),
        ],
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
        if (widget.isEditMode)
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
        if (widget.isEditMode) const SizedBox(height: 16),
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
                      (skill) => widget.isEditMode
                          ? InputChip(
                              label: Text(skill),
                              onDeleted: () => _removeSkill(skill),
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
        if (widget.isEditMode) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addEducationEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add Education Entry'),
          ),
        ],
      ],
    );
  }

  Widget _buildEducationCard(int index, _HREducationEntryForm form) {
    final availableLevels = <String>{..._defaultEducationLevels, if (form.level.isNotEmpty) form.level};
    final levelField = widget.isEditMode
        ? DropdownButtonFormField<String>(
            value: form.level.isEmpty ? null : form.level,
            decoration: const InputDecoration(
              labelText: 'Education Level',
              border: OutlineInputBorder(),
            ),
            items: availableLevels
                .map((level) => DropdownMenuItem<String>(value: level, child: Text(level)))
                .toList(),
            onChanged: (value) {
              setState(() {
                form.level = value ?? '';
              });
              _writeBackProfile();
            },
          )
        : _buildStaticField('Education Level', form.level);

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
                if (widget.isEditMode)
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
                  onPressed: widget.isEditMode ? () => _pickEducationDocument(form) : null,
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
    if (!widget.isEditMode) {
      return _buildStaticField(label, controller.text);
    }
    return TextFormField(
      controller: controller,
      onChanged: (_) => _writeBackProfile(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return TextFormField(
      enabled: false,
      initialValue: value.isEmpty ? 'Not provided' : value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        if (widget.isEditMode) ...[
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

  Widget _buildEmploymentCard(int index, _HREmploymentEntryForm form) {
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
                if (widget.isEditMode)
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
                  onPressed: widget.isEditMode ? () => _pickEmploymentDocument(form) : null,
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
    if (!widget.isEditMode) {
      return _buildStaticField(label, controller.text);
    }
    return TextFormField(
      controller: controller,
      onChanged: (_) => _writeBackProfile(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildEmploymentDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: widget.isEditMode ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              value == null ? 'Not set' : _formatDate(value),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickEmploymentDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onSelected,
  }) async {
    if (!widget.isEditMode) return;
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
      _writeBackProfile();
    }
  }

  void _addEmploymentEntry() {
    if (!widget.isEditMode) return;
    setState(() {
      _employmentForms.add(_HREmploymentEntryForm(EmployeeEmploymentEntry()));
    });
    _writeBackProfile();
  }

  void _removeEmploymentEntry(int index) {
    if (!widget.isEditMode) return;
    setState(() {
      _employmentForms.removeAt(index).dispose();
    });
    _writeBackProfile();
  }

  Future<void> _pickEmploymentDocument(_HREmploymentEntryForm form) async {
    if (!widget.isEditMode) return;
    final input = html.FileUploadInputElement()
      ..accept = '*/*'
      ..click();
    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) {
      return;
    }
    final file = input.files!.first;
    final reader = html.FileReader()..readAsArrayBuffer(file);
    await reader.onLoad.first;
    final buffer = reader.result as ByteBuffer;
    final bytes = buffer.asUint8List();
    setState(() {
      form
        ..documentName = file.name
        ..documentBytes = Uint8List.fromList(bytes);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploaded ${file.name}')),
    );
    _writeBackProfile();
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }
}

class _CompensationEditor extends StatelessWidget {
  const _CompensationEditor({required this.record, required this.isEditMode});

  final EmployeeRecord record;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final components = record.compensation.salaryComponents;
    String getComp(String k) => (components[k] ?? 0).toString();
    void setComp(String k, String v) {
      final parsed = double.tryParse(v.trim());
      if (parsed != null) components[k] = parsed;
    }

    final deductionOptions = record.compensation.deductions.isEmpty
        ? <String>['None', 'PF', 'ESI', 'Professional Tax']
        : record.compensation.deductions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditMode ? 'Compensation Editor' : 'Compensation (View Mode)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isEditMode ? const Color(0xFFFF782B) : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _CompNumberField(
                label: 'Basic',
                initial: getComp('basic'),
                isEditMode: isEditMode,
                onChanged: (v) => setComp('basic', v),
              ),
              _CompNumberField(
                label: 'Gross',
                initial: getComp('gross'),
                isEditMode: isEditMode,
                onChanged: (v) => setComp('gross', v),
              ),
              _CompNumberField(
                label: 'Net',
                initial: getComp('net'),
                isEditMode: isEditMode,
                onChanged: (v) => setComp('net', v),
              ),
              _CompNumberField(
                label: 'Traveling',
                initial: getComp('traveling'),
                isEditMode: isEditMode,
                onChanged: (v) => setComp('traveling', v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isEditMode
              ? DropdownButtonFormField<String>(
                  value: record.compensation.selectedDeduction.isEmpty
                      ? null
                      : record.compensation.selectedDeduction,
                  items: deductionOptions
                      .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => record.compensation.selectedDeduction = v ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Deductions',
                    border: OutlineInputBorder(),
                  ),
                )
              : _KeyValueTile('Deductions',
                  record.compensation.selectedDeduction.isEmpty ? 'None' : record.compensation.selectedDeduction),
          const SizedBox(height: 16),
          _SectionHeader('Payslips'),
          _SimpleEditableList(
            items: record.compensation.payslips,
            isEditMode: isEditMode,
          ),
          const SizedBox(height: 12),
          _SectionHeader('Bonuses & Incentives'),
          _SimpleEditableList(items: record.compensation.bonuses, isEditMode: isEditMode),
          const SizedBox(height: 12),
          _SectionHeader('Benefits Summary'),
          _SimpleEditableList(items: record.compensation.benefits, isEditMode: isEditMode),
          const SizedBox(height: 12),
          _SectionHeader('Compensation Letters/Agreements'),
          _SimpleEditableList(items: record.compensation.documents, isEditMode: isEditMode),
          const SizedBox(height: 12),
          _SectionHeader('Reimbursements'),
          _SimpleEditableList(items: record.compensation.reimbursements, isEditMode: isEditMode),
          const SizedBox(height: 12),
          _SectionHeader('Compensation Policies & FAQs'),
          _SimpleEditableList(items: record.compensation.policies, isEditMode: isEditMode),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditMode ? 'Tax Information Editor' : 'Tax Information (View Mode)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          if (isEditMode)
            Row(
              children: [
                Radio<String>(
                  value: 'New',
                  groupValue: record.tax.regime,
                  onChanged: (v) => record.tax.regime = v ?? '',
                ),
                const Text('New tax regime'),
                const SizedBox(width: 24),
                Radio<String>(
                  value: 'Old',
                  groupValue: record.tax.regime,
                  onChanged: (v) => record.tax.regime = v ?? '',
                ),
                const Text('Old tax regime'),
              ],
            )
          else
            _KeyValueTile('Selected Tax Regime', record.tax.regime.isEmpty ? 'Not selected' : record.tax.regime),
        ],
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
    final ts = context.watch<TimeSheetService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Time Sheet (Read-Only)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _SectionHeader('Attendance Records'),
          _MiniList(
            children: ts.attendanceRecords
                .map((a) => ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(ts.formatDate(a.date)),
                      subtitle: Text('In: ${a.clockInTime != null ? ts.formatTime(a.clockInTime!) : '-'}  •  Out: ${a.clockOutTime != null ? ts.formatTime(a.clockOutTime!) : '-'}'),
                      trailing: Text(a.status),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          _SectionHeader('Leave Requests'),
          _MiniList(
            children: ts.leaveRequests
                .map((l) => ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text('${ts.formatDate(l.startDate)} - ${ts.formatDate(l.endDate)} (${l.totalDays} days)'),
                      subtitle: Text(l.leaveType),
                      trailing: Text(l.status),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          _SectionHeader('WFH Requests'),
          _MiniList(
            children: ts.wfhRequests
                .map((w) => ListTile(
                      leading: const Icon(Icons.home_work_outlined),
                      title: Text(ts.formatDate(w.date)),
                      subtitle: Text(w.reason),
                      trailing: Text(w.status),
                    ))
                .toList(),
          ),
        ],
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
    final faq = context.watch<FaqService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditMode ? 'FAQ Editor' : 'FAQ (View Mode)',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
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
            ),
          if (faq.faqs.isNotEmpty)
            ...faq.faqs.map((f) => Card(
                  child: ListTile(
                    title: Text(f.question, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(f.answer),
                    ),
                    trailing: isEditMode
                        ? Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final q = TextEditingController(text: f.question);
                                  final a = TextEditingController(text: f.answer);
                                  final updated = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Edit FAQ'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(controller: q, decoration: const InputDecoration(labelText: 'Question')),
                                          const SizedBox(height: 8),
                                          TextField(controller: a, decoration: const InputDecoration(labelText: 'Answer'), maxLines: 3),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
                                      ],
                                    ),
                                  );
                                  if (updated == true) {
                                    context.read<FaqService>().updateFaq(f.id, question: q.text.trim(), answer: a.text.trim());
                                  }
                                },
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: () => context.read<FaqService>().removeFaq(f.id),
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                              ),
                            ],
                          )
                        : null,
                  ),
                )),
          if (isEditMode) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final q = TextEditingController();
                final a = TextEditingController();
                final create = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Add FAQ'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: q, decoration: const InputDecoration(labelText: 'Question')),
                        const SizedBox(height: 8),
                        TextField(controller: a, decoration: const InputDecoration(labelText: 'Answer'), maxLines: 3),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
                    ],
                  ),
                );
                if (create == true && q.text.trim().isNotEmpty && a.text.trim().isNotEmpty) {
                  context.read<FaqService>().addFaq(q.text.trim(), a.text.trim());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add FAQ'),
            ),
          ],
        ],
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
          label: const Text('Uploading profile picture (Control/Link)'),
        ),
      ],
    );
  }
}
