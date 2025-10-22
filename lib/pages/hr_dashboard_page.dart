import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/post_store.dart';
import '../data/support_store.dart';
import '../data/application_store.dart';
import '../state/employee_directory.dart';
import 'hr_employee_portal_page.dart';

enum _HRMenu { overview, queries, postJob, postInternship, employeeDetails }

class _EmployeeDetailsData extends ChangeNotifier {
  final List<_EmployeeRecord> _employees = [];

  List<_EmployeeRecord> get employees => List.unmodifiable(_employees);

  void addEmployee(_EmployeeRecord record) {
    _employees.insert(0, record);
    notifyListeners();
  }

  void removeEmployee(_EmployeeRecord record) {
    _employees.remove(record);
    notifyListeners();
  }

  void updateEmployee(_EmployeeRecord original, _EmployeeRecord updated) {
    final index = _employees.indexOf(original);
    if (index != -1) {
      _employees[index] = updated;
      notifyListeners();
    }
  }
}

class _EmployeeRecord {
  final String id;
  final String name;
  final String email;
  final String password;
  final _EmployeeProfileData profile;

  const _EmployeeRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.profile,
  });

  _EmployeeRecord copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    _EmployeeProfileData? profile,
  }) {
    return _EmployeeRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profile: profile ?? this.profile.clone(),
    );
  }
}

class _EmployeeProfileData {
  String personalEmail;
  String alternatePhone;
  String address;
  DateTime? dateOfBirth;
  String bloodGroup;
  Uint8List? profileImageBytes;

  String designation;
  String department;
  String managerName;
  String employmentType;
  String workLocation;
  DateTime? startDate;
  DateTime? confirmationDate;
  List<String> skills;

  String baseSalary;
  String bonus;
  String allowances;

  String panId;
  String taxId;

  List<_TimeSheetEntry> timeSheet;
  List<_FaqItem> faqs;

  _EmployeeProfileData({
    required this.personalEmail,
    required this.alternatePhone,
    required this.address,
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.profileImageBytes,
    required this.designation,
    required this.department,
    required this.managerName,
    required this.employmentType,
    required this.workLocation,
    required this.startDate,
    required this.confirmationDate,
    required this.skills,
    required this.baseSalary,
    required this.bonus,
    required this.allowances,
    required this.panId,
    required this.taxId,
    required this.timeSheet,
    required this.faqs,
  });

  factory _EmployeeProfileData.empty() {
    return _EmployeeProfileData(
      personalEmail: '',
      alternatePhone: '',
      address: '',
      dateOfBirth: null,
      bloodGroup: '',
      profileImageBytes: null,
      designation: '',
      department: '',
      managerName: '',
      employmentType: '',
      workLocation: '',
      startDate: null,
      confirmationDate: null,
      skills: [],
      baseSalary: '',
      bonus: '',
      allowances: '',
      panId: '',
      taxId: '',
      timeSheet: [],
      faqs: [],
    );
  }

  _EmployeeProfileData clone() {
    return _EmployeeProfileData(
      personalEmail: personalEmail,
      alternatePhone: alternatePhone,
      address: address,
      dateOfBirth: dateOfBirth != null ? DateTime.fromMillisecondsSinceEpoch(dateOfBirth!.millisecondsSinceEpoch) : null,
      bloodGroup: bloodGroup,
      profileImageBytes: profileImageBytes != null ? Uint8List.fromList(profileImageBytes!) : null,
      designation: designation,
      department: department,
      managerName: managerName,
      employmentType: employmentType,
      workLocation: workLocation,
      startDate: startDate != null ? DateTime.fromMillisecondsSinceEpoch(startDate!.millisecondsSinceEpoch) : null,
      confirmationDate: confirmationDate != null ? DateTime.fromMillisecondsSinceEpoch(confirmationDate!.millisecondsSinceEpoch) : null,
      skills: List<String>.from(skills),
      baseSalary: baseSalary,
      bonus: bonus,
      allowances: allowances,
      panId: panId,
      taxId: taxId,
      timeSheet: timeSheet.map((e) => e.clone()).toList(),
      faqs: faqs.map((e) => e.clone()).toList(),
    );
  }
}

class _TimeSheetEntry {
  String title;
  DateTime date;
  double hours;
  String status;

  _TimeSheetEntry({
    required this.title,
    required this.date,
    required this.hours,
    required this.status,
  });

  _TimeSheetEntry clone() {
    return _TimeSheetEntry(
      title: title,
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      hours: hours,
      status: status,
    );
  }
}

class _FaqItem {
  String question;
  String answer;

  _FaqItem({required this.question, required this.answer});

  _FaqItem clone() {
    return _FaqItem(question: question, answer: answer);
  }
}

class _EmployeeDetailsModule extends StatefulWidget {
  const _EmployeeDetailsModule();

  @override
  State<_EmployeeDetailsModule> createState() => _EmployeeDetailsModuleState();
}

class _EmployeeDetailsModuleState extends State<_EmployeeDetailsModule> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _EmployeeDetailsData _data = _EmployeeDetailsData();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _data,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFFF782B),
                      unselectedLabelColor: Colors.black54,
                      indicator: BoxDecoration(
                        color: const Color(0xFFFF782B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFF782B).withValues(alpha: 0.5)),
                      ),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      tabs: const [
                        Tab(text: 'Create New Employee'),
                        Tab(text: 'Employee List'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 540,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _CreateEmployeeForm(
                          onCreate: (record) {
                            _data.addEmployee(record);
                            // Add to global EmployeeDirectory
                            final globalRecord = EmployeeRecord(
                              id: record.id,
                              name: record.name,
                              primaryEmail: record.email,
                              personal: EmployeePersonalDetails(
                                fullName: record.name,
                                familyName: '',
                                corporateEmail: record.email,
                                personalEmail: '',
                                mobileNumber: '',
                                alternateMobileNumber: '',
                                currentAddress: '',
                                permanentAddress: '',
                                panId: '',
                                aadharId: '',
                                dateOfBirth: null,
                                bloodGroup: '',
                                otherAssets: '',
                                profileImageBytes: null,
                                assignedAssets: <String>{},
                              ),
                              professional: EmployeeProfessionalProfile(
                                position: '',
                                employeeId: record.id,
                                department: '',
                                managerName: '',
                                employmentType: '',
                                location: '',
                                workSpace: '',
                                jobLevel: '',
                                startDate: null,
                                confirmationDate: null,
                                skills: '',
                              ),
                            );
                            context.read<EmployeeDirectory>().addEmployee(globalRecord);
                            _tabController.animateTo(1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Employee "${record.name}" created successfully.')),
                            );
                          },
                        ),
                        _EmployeeListView(
                          employees: _data.employees,
                          onView: (record) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ChangeNotifierProvider<EmployeeDirectory>.value(
                                  value: context.read<EmployeeDirectory>()..setPrimaryEmployee(record.id),
                                  child: HREmployeePortalPage(employeeId: record.id),
                                ),
                              ),
                            );
                          },
                          onEdit: (record) async {
                            final updatedRecord = await showDialog<_EmployeeRecord>(
                              context: context,
                              builder: (context) => _EditEmployeeDialog(employee: record),
                            );

                            if (updatedRecord != null) {
                              _data.updateEmployee(record, updatedRecord);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Employee "${updatedRecord.name}" updated.')),
                              );
                            }
                          },
                          onDelete: (record) async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Employee'),
                                content: Text('Are you sure you want to delete ${record.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              _data.removeEmployee(record);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Employee "${record.name}" deleted.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CreateEmployeeForm extends StatefulWidget {
  final ValueChanged<_EmployeeRecord> onCreate;
  const _CreateEmployeeForm({required this.onCreate});

  @override
  State<_CreateEmployeeForm> createState() => _CreateEmployeeFormState();
}

class _CreateEmployeeFormState extends State<_CreateEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createEmployee() {
    if (_formKey.currentState?.validate() ?? false) {
      final record = _EmployeeRecord(
        id: _employeeIdController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        profile: _EmployeeProfileData.empty(),
      );
      widget.onCreate(record);
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _employeeIdController.clear();
    }
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
            const Text(
              'Create New Employee',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              'Fill in the details below to set up a new employee account. The password entered will be used for the initial login.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _employeeIdController,
              decoration: InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an employee ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Employee Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the employee name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Employee Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the employee email';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a password';
                }
                if (value.trim().length < 6) {
                  return 'Password should be at least 6 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _createEmployee,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Create Employee', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF782B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeListView extends StatelessWidget {
  final List<_EmployeeRecord> employees;
  final ValueChanged<_EmployeeRecord> onView;
  final ValueChanged<_EmployeeRecord> onEdit;
  final ValueChanged<_EmployeeRecord> onDelete;
  const _EmployeeListView({
    required this.employees,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No employees have been added yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Employee List',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                      columnSpacing: 28,
                      horizontalMargin: 24,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                      columns: const [
                        DataColumn(label: Text('Employee ID')),
                        DataColumn(label: Text('Employee Name')),
                        DataColumn(label: Text('Employee Email')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: employees.map((employee) {
                        return DataRow(
                          cells: [
                            DataCell(Text(employee.id)),
                            DataCell(Text(employee.name)),
                            DataCell(Text(employee.email)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => onView(employee),
                                    icon: const Icon(Icons.visibility_outlined),
                                    tooltip: 'View Details',
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () => onEdit(employee),
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: 'Edit Employee',
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () => onDelete(employee),
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red,
                                    tooltip: 'Delete Employee',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewEmployeeDialog extends StatelessWidget {
  final _EmployeeRecord employee;
  const _ViewEmployeeDialog({required this.employee});

  Widget _buildDetailTile({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF782B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFFF782B), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.visibility_outlined, color: Color(0xFFFF782B)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Employee Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 1,
                  childAspectRatio: 3.8,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDetailTile(
                      icon: Icons.badge_outlined,
                      label: 'Employee ID',
                      value: employee.id,
                    ),
                    _buildDetailTile(
                      icon: Icons.person_outline,
                      label: 'Employee Name',
                      value: employee.name,
                    ),
                    _buildDetailTile(
                      icon: Icons.email_outlined,
                      label: 'Employee Email',
                      value: employee.email,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditEmployeeDialog extends StatefulWidget {
  final _EmployeeRecord employee;
  const _EditEmployeeDialog({required this.employee});

  @override
  State<_EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<_EditEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _employeeIdController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _employeeIdController = TextEditingController(text: widget.employee.id);
    _nameController = TextEditingController(text: widget.employee.name);
    _emailController = TextEditingController(text: widget.employee.email);
    _passwordController = TextEditingController(text: widget.employee.password);
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.employee.copyWith(
        id: _employeeIdController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.of(context).pop(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_outlined, color: Color(0xFFFF782B)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Edit Employee',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _employeeIdController,
                    decoration: InputDecoration(
                      labelText: 'Employee ID',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an employee ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Employee Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the employee name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Employee Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the employee email';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a password';
                      }
                      if (value.trim().length < 6) {
                        return 'Password should be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF782B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JobsModule extends StatefulWidget {
  const _JobsModule();

  @override
  State<_JobsModule> createState() => _JobsModuleState();
}

class _JobsModuleState extends State<_JobsModule> {
  static const int _itemsPerPage = 10;
  int _currentPage = 0;

  void _downloadResume(BuildContext context, String fileName, String? resumeData) {
    if (resumeData != null && resumeData.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading $fileName...')),
      );
      // TODO: Implement actual file download using dart:html for web or file_saver package
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume data not available')),
      );
    }
  }

  Future<void> _deleteApplication(BuildContext context, String email, String jobId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: Text('Are you sure you want to delete the application from $email?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = ApplicationStore.I.deleteJobApplication(email, jobId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ApplicationStore.I.jobApplications;
    final totalPages = (allItems.length / _itemsPerPage).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TabBar(
                      labelColor: const Color(0xFFFF782B),
                      unselectedLabelColor: Colors.black54,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: const Color(0xFFFF782B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFF782B).withValues(alpha: 0.5)),
                      ),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      tabs: const [
                        Tab(text: 'Applications'),
                        Tab(text: 'Post New Job'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    double h = MediaQuery.of(context).size.height - 330;
                    if (h < 320) h = 320;
                    if (h > 900) h = 900;
                    return SizedBox(
                      height: h,
                      child: TabBarView(
                        children: [
                          _JobApplicationsList(
                            currentPage: _currentPage,
                            itemsPerPage: _itemsPerPage,
                            onDownload: _downloadResume,
                            onDelete: _deleteApplication,
                          ),
                          const _PostJobFormInline(),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          totalPages > 1
              ? _PaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _InternshipsModule extends StatefulWidget {
  const _InternshipsModule();

  @override
  State<_InternshipsModule> createState() => _InternshipsModuleState();
}

class _InternshipsModuleState extends State<_InternshipsModule> {
  static const int _itemsPerPage = 10;
  int _currentPage = 0;

  void _downloadResume(BuildContext context, String fileName, String? resumeData) {
    if (resumeData != null && resumeData.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading $fileName...')),
      );
      // TODO: Implement actual file download using dart:html for web or file_saver package
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume data not available')),
      );
    }
  }

  Future<void> _deleteApplication(BuildContext context, String email, String internshipId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: Text('Are you sure you want to delete the application from $email?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = ApplicationStore.I.deleteInternshipApplication(email, internshipId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ApplicationStore.I.internshipApplications;
    final totalPages = (allItems.length / _itemsPerPage).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TabBar(
                      labelColor: const Color(0xFFFF782B),
                      unselectedLabelColor: Colors.black54,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: const Color(0xFFFF782B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFF782B).withOpacity(0.5)),
                      ),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      tabs: const [
                        Tab(text: 'Applications'),
                        Tab(text: 'Post New Intern'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    double h = MediaQuery.of(context).size.height - 330;
                    if (h < 320) h = 320;
                    if (h > 900) h = 900;
                    return SizedBox(
                      height: h,
                      child: TabBarView(
                        children: [
                          _InternshipApplicationsList(
                            currentPage: _currentPage,
                            itemsPerPage: _itemsPerPage,
                            onDownload: _downloadResume,
                            onDelete: _deleteApplication,
                          ),
                          const _PostInternshipFormInline(),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          totalPages > 1
              ? _PaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _ApplicationListHeader extends StatelessWidget {
  const _ApplicationListHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFFF782B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF782B).withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          // 1. Email Header (with icon space)
          const SizedBox(width: 36), // Icon space
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              'Email',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // 2. Resume Header
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const SizedBox(width: 22), // Icon space
                Text(
                  'Resume',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // 3. Applied On Header
          Row(
            children: [
              const SizedBox(width: 22), // Icon space
              Text(
                'Applied On',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          
          // 4. Status Header
          SizedBox(
            width: 130,
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // 5. Download Header
          SizedBox(
            width: 110,
            child: Text(
              'Download',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 6. Delete Header
          SizedBox(
            width: 40,
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobApplicationsList extends StatelessWidget {
  final int currentPage;
  final int itemsPerPage;
  final Function(BuildContext, String, String?) onDownload;
  final Function(BuildContext, String, String) onDelete;

  const _JobApplicationsList({
    required this.currentPage,
    required this.itemsPerPage,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ApplicationStore.I,
      builder: (context, _) {
        final allItems = ApplicationStore.I.jobApplications;

        if (allItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No job applications yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        final startIndex = currentPage * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage).clamp(0, allItems.length);
        final items = allItems.sublist(startIndex, endIndex);

        return Column(
          children: [
            const _ApplicationListHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = items[index];
                  final dateStr = '${app.createdAt.year.toString().padLeft(4, '0')}-${app.createdAt.month.toString().padLeft(2, '0')}-${app.createdAt.day.toString().padLeft(2, '0')}';

                  return _ApplicationCard(
                    email: app.email,
                    resumeName: app.resumeName,
                    dateStr: dateStr,
                    status: app.status,
                    onStatusChanged: (newStatus) {
                      ApplicationStore.I.updateJobApplicationStatus(app.email, app.jobId, newStatus);
                    },
                    onDownload: () => onDownload(context, app.resumeName, app.resumeData),
                    onDelete: () => onDelete(context, app.email, app.jobId),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InternshipApplicationsList extends StatelessWidget {
  final int currentPage;
  final int itemsPerPage;
  final Function(BuildContext, String, String?) onDownload;
  final Function(BuildContext, String, String) onDelete;

  const _InternshipApplicationsList({
    required this.currentPage,
    required this.itemsPerPage,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ApplicationStore.I,
      builder: (context, _) {
        final allItems = ApplicationStore.I.internshipApplications;

        if (allItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No internship applications yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        final startIndex = currentPage * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage).clamp(0, allItems.length);
        final items = allItems.sublist(startIndex, endIndex);

        return Column(
          children: [
            const _ApplicationListHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = items[index];
                  final dateStr = '${app.createdAt.year.toString().padLeft(4, '0')}-${app.createdAt.month.toString().padLeft(2, '0')}-${app.createdAt.day.toString().padLeft(2, '0')}';

                  return _ApplicationCard(
                    email: app.email,
                    resumeName: app.resumeName,
                    dateStr: dateStr,
                    status: app.status,
                    onStatusChanged: (newStatus) {
                      ApplicationStore.I.updateInternshipApplicationStatus(app.email, app.internshipId, newStatus);
                    },
                    onDownload: () => onDownload(context, app.resumeName, app.resumeData),
                    onDelete: () => onDelete(context, app.email, app.internshipId),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String email;
  final String resumeName;
  final String dateStr;
  final String status;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _ApplicationCard({
    required this.email,
    required this.resumeName,
    required this.dateStr,
    required this.status,
    required this.onStatusChanged,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 1. Candidate Email with icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF782B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFFFF782B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            
            // 2. Resume File Name
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      resumeName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // 3. Applied On Date
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // 4. Status Dropdown
            _StatusChipDropdown(
              currentStatus: status,
              onStatusChanged: onStatusChanged,
            ),
            const SizedBox(width: 16),
            
            // 5. Download Button
            ElevatedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF782B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // 6. Delete Button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              iconSize: 20,
              tooltip: 'Delete Application',
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatusChipDropdown extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  const _StatusChipDropdown({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (currentStatus) {
      case 'Selected':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = const Color(0xFFF44336);
        statusIcon = Icons.cancel;
        break;
      case 'In Progress':
      default:
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isDense: true,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          icon: Icon(Icons.arrow_drop_down, color: statusColor, size: 18),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem(
              value: 'In Progress',
              child: Row(
                children: const [
                  Icon(Icons.pending, size: 14, color: Color(0xFFFF9800)),
                  SizedBox(width: 6),
                  Text('In Progress', style: TextStyle(color: Color(0xFFFF9800), fontSize: 12)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Selected',
              child: Row(
                children: const [
                  Icon(Icons.check_circle, size: 14, color: Color(0xFF4CAF50)),
                  SizedBox(width: 6),
                  Text('Selected', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Rejected',
              child: Row(
                children: const [
                  Icon(Icons.cancel, size: 14, color: Color(0xFFF44336)),
                  SizedBox(width: 6),
                  Text('Rejected', style: TextStyle(color: Color(0xFFF44336), fontSize: 12)),
                ],
              ),
            ),
          ],
          onChanged: (newValue) {
            if (newValue != null) {
              onStatusChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
            style: IconButton.styleFrom(
              backgroundColor: currentPage > 0 ? const Color(0xFFFF782B).withValues(alpha: 0.1) : Colors.grey.shade200,
              foregroundColor: currentPage > 0 ? const Color(0xFFFF782B) : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
          
          // Page numbers
          ...List.generate(totalPages, (index) {
            // Show first page, last page, current page, and pages around current
            if (index == 0 || 
                index == totalPages - 1 || 
                (index >= currentPage - 1 && index <= currentPage + 1)) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _PageButton(
                  pageNumber: index + 1,
                  isActive: index == currentPage,
                  onPressed: () => onPageChanged(index),
                ),
              );
            } else if (index == currentPage - 2 || index == currentPage + 2) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              );
            }
            return const SizedBox.shrink();
          }),
          
          const SizedBox(width: 16),
          // Next button
          IconButton(
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
            style: IconButton.styleFrom(
              backgroundColor: currentPage < totalPages - 1 ? const Color(0xFFFF782B).withValues(alpha: 0.1) : Colors.grey.shade200,
              foregroundColor: currentPage < totalPages - 1 ? const Color(0xFFFF782B) : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          
          const SizedBox(width: 16),
          // Page info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'Page ${currentPage + 1} of $totalPages',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final int pageNumber;
  final bool isActive;
  final VoidCallback onPressed;

  const _PageButton({
    required this.pageNumber,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFFFF782B) : Colors.white,
          foregroundColor: isActive ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isActive ? const Color(0xFFFF782B) : Colors.grey.shade300,
              width: isActive ? 2 : 1,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class HRDashboardPage extends StatefulWidget {
  const HRDashboardPage({super.key});

  @override
  State<HRDashboardPage> createState() => _HRDashboardPageState();
}

class _HRDashboardPageState extends State<HRDashboardPage> {
  _HRMenu _selected = _HRMenu.overview; // initial: overview/welcome

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmployeeDirectory>.value(
      value: EmployeeDirectory(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HR Dashboard'),
          backgroundColor: const Color(0xFFFF782B),
          foregroundColor: Colors.white,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return Row(
                children: [
                  _Sidebar(
                    selected: _selected,
                    onSelect: (m) => setState(() => _selected = m),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _RightPanel(selected: _selected)),
                ],
              );
            }
            return Column(
              children: [
                _TopNav(
                  selected: _selected,
                  onSelect: (m) => setState(() => _selected = m),
                ),
                const Divider(height: 1),
                Expanded(child: _RightPanel(selected: _selected)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final _HRMenu selected;
  final ValueChanged<_HRMenu> onSelect;
  const _Sidebar({required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.grey.shade50,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: Color(0xFFFF782B)),
            title: const Text('Overview'),
            selected: selected == _HRMenu.overview,
            onTap: () => onSelect(_HRMenu.overview),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFFFF782B)),
            title: const Text('Help and Support'),
            selected: selected == _HRMenu.queries,
            onTap: () => onSelect(_HRMenu.queries),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.work_outline, color: Color(0xFFFF782B)),
            title: const Text('Jobs'),
            selected: selected == _HRMenu.postJob,
            onTap: () => onSelect(_HRMenu.postJob),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined, color: Color(0xFFFF782B)),
            title: const Text('Internships'),
            selected: selected == _HRMenu.postInternship,
            onTap: () => onSelect(_HRMenu.postInternship),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline, color: Color(0xFFFF782B)),
            title: const Text('Employee Details'),
            selected: selected == _HRMenu.employeeDetails,
            onTap: () => onSelect(_HRMenu.employeeDetails),
          ),
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  final _HRMenu selected;
  final ValueChanged<_HRMenu> onSelect;
  const _TopNav({required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 56,
      color: Colors.grey.shade50,
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.overview),
            icon: const Icon(Icons.dashboard_outlined, color: Color(0xFFFF782B)),
            label: const Text('Overview'),
          ),
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.queries),
            icon: const Icon(Icons.help_outline, color: Color(0xFFFF782B)),
            label: const Text('Help and Support'),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.postJob),
            icon: const Icon(Icons.work_outline, color: Color(0xFFFF782B)),
            label: const Text('Jobs'),
          ),
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.postInternship),
            icon: const Icon(Icons.school_outlined, color: Color(0xFFFF782B)),
            label: const Text('Internships'),
          ),
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.employeeDetails),
            icon: const Icon(Icons.people_outline, color: Color(0xFFFF782B)),
            label: const Text('Employee Details'),
          ),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  final _HRMenu selected;
  const _RightPanel({required this.selected});
  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (selected) {
      case _HRMenu.overview:
        child = _WelcomePanel();
        break;
      case _HRMenu.queries:
        child = const _QueriesList();
        break;
      case _HRMenu.postJob:
        child = const _JobsModule();
        break;
      case _HRMenu.postInternship:
        child = const _InternshipsModule();
        break;
      case _HRMenu.employeeDetails:
        child = const _EmployeeDetailsModule();
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: child,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFFF782B)),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Welcome to the HR Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Select an option from the left to get started.'),
          ],
        ),
      ),
    );
  }
}

class _QueriesList extends StatelessWidget {
  const _QueriesList();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SupportStore.I,
      builder: (context, _) {
        final items = SupportStore.I.items;
        return _InfoCard(
          icon: Icons.help_outline,
          title: 'Help and Support',
          child: items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No submissions yet.'),
                )
              : Column(
                  children: [
                    for (final q in items)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.email_outlined, color: Color(0xFFFF782B)),
                        title: Text(q.email),
                        subtitle: Text(q.description),
                        trailing: Text(
                          '${q.createdAt.year.toString().padLeft(4,'0')}-${q.createdAt.month.toString().padLeft(2,'0')}-${q.createdAt.day.toString().padLeft(2,'0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _PostJobFormInline extends StatefulWidget {
  const _PostJobFormInline();
  @override
  State<_PostJobFormInline> createState() => _PostJobFormInlineState();
}

class _PostJobFormInlineState extends State<_PostJobFormInline> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _experience = TextEditingController();
  final _skills = TextEditingController();
  final _responsibilities = TextEditingController();
  final _qualifications = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _department = TextEditingController();
  final _postingDate = TextEditingController();
  final _applicationDeadline = TextEditingController();
  final _jobId = TextEditingController();
  String _contractType = 'Full-Time';

  @override
  void dispose() {
    _title.dispose();
    _experience.dispose();
    _skills.dispose();
    _responsibilities.dispose();
    _qualifications.dispose();
    _description.dispose();
    _location.dispose();
    _department.dispose();
    _postingDate.dispose();
    _applicationDeadline.dispose();
    _jobId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize defaults when first built
    if (_postingDate.text.isEmpty) {
      final now = DateTime.now();
      _postingDate.text = '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    }
    if (_jobId.text.isEmpty) {
      _jobId.text = 'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }

    return SizedBox(
      width: 820,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const Text('Post New Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                const Text('Basic Details', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 700;
                  if (wide) {
                    return Column(children: [
                      Row(children: [
                        Expanded(child: _buildField('Title', _title)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Department', _department)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _buildField('Location', _location, hint: 'City, Country')),
                        const SizedBox(width: 12),
                        Expanded(child: _dropdownContractType()),
                      ]),
                    ]);
                  }
                  return Column(children: [
                    _buildField('Title', _title),
                    const SizedBox(height: 12),
                    _buildField('Department', _department),
                    const SizedBox(height: 12),
                    _buildField('Location', _location, hint: 'City, Country'),
                    const SizedBox(height: 12),
                    _dropdownContractType(),
                  ]);
                }),
                const SizedBox(height: 16),
                const Text('Qualifications & Experience', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 700;
                  if (wide) {
                    return Column(children: [
                      Row(children: [
                        Expanded(child: _buildField('Experience', _experience, hint: 'e.g., 3-5 years')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Skills', _skills, hint: 'Comma-separated skills')),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _buildMultiline('Responsibilities', _responsibilities)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMultiline('Qualifications', _qualifications)),
                      ]),
                    ]);
                  }
                  return Column(children: [
                    _buildField('Experience', _experience, hint: 'e.g., 3-5 years'),
                    const SizedBox(height: 12),
                    _buildField('Skills', _skills, hint: 'Comma-separated skills'),
                    const SizedBox(height: 12),
                    _buildMultiline('Responsibilities', _responsibilities),
                    const SizedBox(height: 12),
                    _buildMultiline('Qualifications', _qualifications),
                  ]);
                }),
                const SizedBox(height: 16),
                const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildMultiline('Description', _description),
                const SizedBox(height: 16),
                const Text('Timing & IDs', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _dateRow(),
                const SizedBox(height: 12),
                _buildField('Job ID', _jobId, hint: 'Auto-filled, you can edit'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final job = JobPost(
                          id: _jobId.text.trim(),
                          title: _title.text.trim(),
                          description: _description.text.trim(),
                          location: _location.text.trim(),
                          contractType: _contractType,
                          department: _department.text.trim(),
                          postingDate: _postingDate.text.trim(),
                          applicationDeadline: _applicationDeadline.text.trim(),
                          experience: _experience.text.trim(),
                          skills: _splitList(_skills.text),
                          responsibilities: _splitLines(_responsibilities.text),
                          qualifications: _splitLines(_qualifications.text),
                        );
                        PostStore.I.addJob(job);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Job posted successfully')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF782B), foregroundColor: Colors.white),
                    child: const Text('Submit Job', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Manage Jobs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: PostStore.I,
                  builder: (context, _) {
                    final items = PostStore.I.jobs;
                    if (items.isEmpty) {
                      return const Text('No active job posts yet.');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final j = items[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(j.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('${j.id} • ${j.postingDate}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final ok = PostStore.I.deleteJob(j.id);
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Job deleted')),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildMultiline(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _dropdownContractType() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Contract Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _contractType,
          items: const [
            DropdownMenuItem(value: 'Full-Time', child: Text('Full-Time')),
            DropdownMenuItem(value: 'Part-Time', child: Text('Part-Time')),
            DropdownMenuItem(value: 'Contract', child: Text('Contract')),
            DropdownMenuItem(value: 'Temporary', child: Text('Temporary')),
            DropdownMenuItem(value: 'Intern', child: Text('Intern')),
          ],
          onChanged: (v) => setState(() => _contractType = v ?? 'Full-Time'),
        ),
      ),
    );
  }

  Widget _dateRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField('Posting Date', _postingDate, allowPast: true),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField('Application Deadline', _applicationDeadline),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {bool allowPast = false}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.date_range_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        final firstDate = allowPast ? DateTime(now.year - 5) : now;
        final picked = await showDatePicker(
          context: context,
          firstDate: firstDate,
          lastDate: DateTime(now.year + 5),
          initialDate: now,
        );
        if (picked != null) {
          final s = '${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
          setState(() => controller.text = s);
        }
      },
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please select $label' : null,
    );
  }

  List<String> _splitList(String input) {
    return input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  List<String> _splitLines(String input) {
    return input.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}

class _PostInternshipFormInline extends StatefulWidget {
  const _PostInternshipFormInline();
  @override
  State<_PostInternshipFormInline> createState() => _PostInternshipFormInlineState();
}

class _PostInternshipFormInlineState extends State<_PostInternshipFormInline> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _skill = TextEditingController();
  final _qualification = TextEditingController();
  final _duration = TextEditingController();
  final _description = TextEditingController();
  final _postingDate = TextEditingController();
  // Removed: Location, Contract Type, Internship ID as per requirements

  @override
  void dispose() {
    _title.dispose();
    _skill.dispose();
    _qualification.dispose();
    _duration.dispose();
    _description.dispose();
    _postingDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize defaults
    if (_postingDate.text.isEmpty) {
      final now = DateTime.now();
      _postingDate.text = '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    }

    return SizedBox(
      width: 820,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const Text('Post New Internship', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                const Text('Basic Details', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 700;
                  if (wide) {
                    return Column(children: [
                      Row(children: [
                        Expanded(child: _buildField('Title', _title)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Duration', _duration, hint: 'e.g., 3 months')),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _buildField('Skill', _skill, hint: 'Primary skill required')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Qualification', _qualification, hint: 'e.g., BSc, BTech')),
                      ]),
                    ]);
                  }
                  return Column(children: [
                    _buildField('Title', _title),
                    const SizedBox(height: 12),
                    _buildField('Duration', _duration, hint: 'e.g., 3 months'),
                    const SizedBox(height: 12),
                    _buildField('Skill', _skill, hint: 'Primary skill required'),
                    const SizedBox(height: 12),
                    _buildField('Qualification', _qualification, hint: 'e.g., BSc, BTech'),
                  ]);
                }),
                const SizedBox(height: 16),
                const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildMultiline('Description', _description),
                const SizedBox(height: 12),
                _buildDateField('Posting Date', _postingDate, allowPast: true),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final genId = 'INT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                        final post = InternshipPost(
                          id: genId,
                          title: _title.text.trim(),
                          skill: _skill.text.trim(),
                          qualification: _qualification.text.trim(),
                          duration: _duration.text.trim(),
                          description: _description.text.trim(),
                          location: '',
                          contractType: '',
                          postingDate: _postingDate.text.trim(),
                        );
                        PostStore.I.addInternship(post);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Internship posted successfully')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF782B), foregroundColor: Colors.white),
                    child: const Text('Submit Internship', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Manage Internships', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: PostStore.I,
                  builder: (context, _) {
                    final items = PostStore.I.internships;
                    if (items.isEmpty) {
                      return const Text('No active internship posts yet.');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final it = items[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('${it.id} • ${it.postingDate}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final ok = PostStore.I.deleteInternship(it.id);
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Internship deleted')),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildMultiline(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {bool allowPast = false}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.date_range_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        final firstDate = allowPast ? DateTime(now.year - 5) : now;
        final picked = await showDatePicker(
          context: context,
          firstDate: firstDate,
          lastDate: DateTime(now.year + 5),
          initialDate: now,
        );
        if (picked != null) {
          final s = '${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
          setState(() => controller.text = s);
        }
      },
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please select $label' : null,
    );
  }
}
