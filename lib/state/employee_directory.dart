import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class EmployeePersonalDetails {
  EmployeePersonalDetails({
    required this.fullName,
    required this.familyName,
    required this.corporateEmail,
    required this.personalEmail,
    required this.mobileNumber,
    required this.alternateMobileNumber,
    required this.currentAddress,
    required this.permanentAddress,
    required this.panId,
    required this.aadharId,
    required this.dateOfBirth,
    required this.bloodGroup,
    Set<String>? assignedAssets,
    this.otherAssets = '',
    this.profileImageBytes,
  }) : assignedAssets = assignedAssets ?? <String>{};

  String fullName;
  String familyName;
  String corporateEmail;
  String personalEmail;
  String mobileNumber;
  String alternateMobileNumber;
  String currentAddress;
  String permanentAddress;
  String panId;
  String aadharId;
  DateTime? dateOfBirth;
  String bloodGroup;
  Set<String> assignedAssets;
  String otherAssets;
  Uint8List? profileImageBytes;

  EmployeePersonalDetails copy() {
    return EmployeePersonalDetails(
      fullName: fullName,
      familyName: familyName,
      corporateEmail: corporateEmail,
      personalEmail: personalEmail,
      mobileNumber: mobileNumber,
      alternateMobileNumber: alternateMobileNumber,
      currentAddress: currentAddress,
      permanentAddress: permanentAddress,
      panId: panId,
      aadharId: aadharId,
      dateOfBirth: dateOfBirth != null
          ? DateTime.fromMillisecondsSinceEpoch(dateOfBirth!.millisecondsSinceEpoch)
          : null,
      bloodGroup: bloodGroup,
      assignedAssets: Set<String>.from(assignedAssets),
      otherAssets: otherAssets,
      profileImageBytes: profileImageBytes != null
          ? Uint8List.fromList(profileImageBytes!)
          : null,
    );
  }
}

class EmployeeEducationEntry {
  EmployeeEducationEntry({
    this.level = '',
    this.institution = '',
    this.degree = '',
    this.year = '',
    this.grade = '',
    this.documentBytes,
    this.documentName,
  });

  String level;
  String institution;
  String degree;
  String year;
  String grade;
  Uint8List? documentBytes;
  String? documentName;

  EmployeeEducationEntry copy() {
    return EmployeeEducationEntry(
      level: level,
      institution: institution,
      degree: degree,
      year: year,
      grade: grade,
      documentBytes:
          documentBytes != null ? Uint8List.fromList(documentBytes!) : null,
      documentName: documentName,
    );
  }
}

class EmployeeEmploymentEntry {
  EmployeeEmploymentEntry({
    this.companyName = '',
    this.designation = '',
    this.fromDate,
    this.toDate,
    this.documentBytes,
    this.documentName,
  });

  String companyName;
  String designation;
  DateTime? fromDate;
  DateTime? toDate;
  Uint8List? documentBytes;
  String? documentName;

  EmployeeEmploymentEntry copy() {
    return EmployeeEmploymentEntry(
      companyName: companyName,
      designation: designation,
      fromDate: fromDate != null
          ? DateTime.fromMillisecondsSinceEpoch(fromDate!.millisecondsSinceEpoch)
          : null,
      toDate: toDate != null
          ? DateTime.fromMillisecondsSinceEpoch(toDate!.millisecondsSinceEpoch)
          : null,
      documentBytes:
          documentBytes != null ? Uint8List.fromList(documentBytes!) : null,
      documentName: documentName,
    );
  }
}

class EmployeeProfessionalProfile {
  EmployeeProfessionalProfile({
    this.position = '',
    this.employeeId = '',
    this.department = '',
    this.managerName = '',
    this.employmentType = '',
    this.location = '',
    this.workSpace = '',
    this.jobLevel = '',
    this.startDate,
    this.confirmationDate,
    this.skills = '',
    List<EmployeeEducationEntry>? education,
    List<EmployeeEmploymentEntry>? employmentHistory,
  })  : education = education ?? <EmployeeEducationEntry>[],
        employmentHistory = employmentHistory ?? <EmployeeEmploymentEntry>[];

  String position;
  String employeeId;
  String department;
  String managerName;
  String employmentType;
  String location;
  String workSpace;
  String jobLevel;
  DateTime? startDate;
  DateTime? confirmationDate;
  String skills;
  List<EmployeeEducationEntry> education;
  List<EmployeeEmploymentEntry> employmentHistory;

  EmployeeProfessionalProfile copy() {
    return EmployeeProfessionalProfile(
      position: position,
      employeeId: employeeId,
      department: department,
      managerName: managerName,
      employmentType: employmentType,
      location: location,
      workSpace: workSpace,
      jobLevel: jobLevel,
      startDate: startDate != null
          ? DateTime.fromMillisecondsSinceEpoch(startDate!.millisecondsSinceEpoch)
          : null,
      confirmationDate: confirmationDate != null
          ? DateTime.fromMillisecondsSinceEpoch(
              confirmationDate!.millisecondsSinceEpoch,
            )
          : null,
      skills: skills,
      education: education.map((e) => e.copy()).toList(),
      employmentHistory: employmentHistory.map((e) => e.copy()).toList(),
    );
  }
}

class EmployeeRecord {
  EmployeeRecord({
    required this.id,
    required this.name,
    required this.primaryEmail,
    required this.personal,
    required this.professional,
  });

  final String id;
  String name;
  String primaryEmail;
  EmployeePersonalDetails personal;
  EmployeeProfessionalProfile professional;

  EmployeeRecord copy() {
    return EmployeeRecord(
      id: id,
      name: name,
      primaryEmail: primaryEmail,
      personal: personal.copy(),
      professional: professional.copy(),
    );
  }
}

class EmployeeDirectory extends ChangeNotifier {
  EmployeeDirectory() {
    final personal = EmployeePersonalDetails(
      fullName: 'John Doe',
      familyName: 'Robert Doe (Father), Jane Doe (Mother), Mary Doe (Spouse)',
      corporateEmail: 'john.doe@apexnuera.com',
      personalEmail: 'john.doe@gmail.com',
      mobileNumber: '+91 98765 43210',
      alternateMobileNumber: '+91 98765 43211',
      currentAddress: '123 Main Street, Tech City, State - 123456',
      permanentAddress: '456 Home Street, Hometown, State - 654321',
      panId: 'ABCDE1234F',
      aadharId: '1234 5678 9012',
      dateOfBirth: DateTime(1990, 5, 15),
      bloodGroup: 'O+',
      assignedAssets: {'Laptop', 'Headphones'},
      otherAssets: 'External Monitor',
    );

    final professional = EmployeeProfessionalProfile(
      position: 'Senior Software Engineer',
      employeeId: 'EMP001',
      department: 'Engineering',
      managerName: 'John Smith',
      employmentType: 'Full time',
      location: 'New York, NY',
      workSpace: 'Hybrid',
      jobLevel: 'Level 5',
      startDate: DateTime(2022, 1, 15),
      confirmationDate: DateTime(2022, 7, 15),
      skills: 'Flutter, Dart, React, Node.js, Python, AWS',
      education: [
        EmployeeEducationEntry(
          level: 'Highest Graduation',
          institution: 'MIT',
          degree: 'Bachelor of Computer Science',
          year: '2020',
          grade: 'A+',
        ),
      ],
      employmentHistory: [
        EmployeeEmploymentEntry(
          companyName: 'Tech Corp',
          designation: 'Software Developer',
          fromDate: DateTime(2020, 6, 1),
          toDate: DateTime(2022, 1, 14),
        ),
      ],
    );

    final seedEmployee = EmployeeRecord(
      id: 'EMP001',
      name: personal.fullName,
      primaryEmail: personal.corporateEmail,
      personal: personal,
      professional: professional,
    );

    _employees[seedEmployee.id] = seedEmployee;
    _primaryEmployeeId = seedEmployee.id;
  }

  final Map<String, EmployeeRecord> _employees = <String, EmployeeRecord>{};
  late String _primaryEmployeeId;

  UnmodifiableListView<EmployeeRecord> get employees =>
      UnmodifiableListView<EmployeeRecord>(_employees.values);

  String get primaryEmployeeId => _primaryEmployeeId;

  EmployeeRecord getById(String id) {
    final record = _employees[id];
    if (record == null) {
      throw StateError('Employee with id $id not found');
    }
    return record;
  }

  EmployeeRecord? tryGetById(String id) => _employees[id];

  void setPrimaryEmployee(String id) {
    if (_employees.containsKey(id)) {
      _primaryEmployeeId = id;
      notifyListeners();
    }
  }

  void updatePersonalDetails(String id, EmployeePersonalDetails details) {
    final record = _employees[id];
    if (record == null) return;
    record.personal = details.copy();
    record.name = record.personal.fullName;
    record.primaryEmail = record.personal.corporateEmail;
    notifyListeners();
  }

  void updateProfessionalProfile(String id, EmployeeProfessionalProfile profile) {
    final record = _employees[id];
    if (record == null) return;
    record.professional = profile.copy();
    notifyListeners();
  }

  void updateProfileImage(String id, Uint8List? bytes) {
    final record = _employees[id];
    if (record == null) return;
    record.personal.profileImageBytes = bytes != null
        ? Uint8List.fromList(bytes)
        : null;
    notifyListeners();
  }

  void touchEmployee(String id) {
    if (_employees.containsKey(id)) {
      notifyListeners();
    }
  }

  void addEmployee(EmployeeRecord record) {
    _employees[record.id] = record.copy();
    notifyListeners();
  }

  void removeEmployee(String id) {
    _employees.remove(id);
    notifyListeners();
  }
}
