import 'dart:typed_data';

class EmployeeProfessionalProfile {
  String position;
  String employeeId;
  String department;
  String managerName;
  String employmentType;
  String location;
  String workSpace;
  String jobLevel;
  String skills; // Comma-separated list as used by UI
  DateTime? startDate;
  DateTime? confirmationDate;
  List<EmployeeEducationEntry> education;
  List<EmployeeEmploymentEntry> employmentHistory;

  EmployeeProfessionalProfile({
    this.position = '',
    this.employeeId = '',
    this.department = '',
    this.managerName = '',
    this.employmentType = '',
    this.location = '',
    this.workSpace = '',
    this.jobLevel = '',
    this.skills = '',
    this.startDate,
    this.confirmationDate,
    List<EmployeeEducationEntry>? education,
    List<EmployeeEmploymentEntry>? employmentHistory,
  })  : education = education ?? <EmployeeEducationEntry>[],
        employmentHistory = employmentHistory ?? <EmployeeEmploymentEntry>[];

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
      skills: skills,
      startDate: startDate != null ? DateTime.fromMillisecondsSinceEpoch(startDate!.millisecondsSinceEpoch) : null,
      confirmationDate: confirmationDate != null
          ? DateTime.fromMillisecondsSinceEpoch(confirmationDate!.millisecondsSinceEpoch)
          : null,
      education: education.map((e) => e.copy()).toList(),
      employmentHistory: employmentHistory.map((e) => e.copy()).toList(),
    );
  }
}

class EmployeeEducationEntry {
  String level;
  String institution;
  String degree;
  String year;
  String grade;
  String? documentName;
  Uint8List? documentBytes;

  EmployeeEducationEntry({
    this.level = '',
    this.institution = '',
    this.degree = '',
    this.year = '',
    this.grade = '',
    this.documentName,
    this.documentBytes,
  });

  EmployeeEducationEntry copy() {
    return EmployeeEducationEntry(
      level: level,
      institution: institution,
      degree: degree,
      year: year,
      grade: grade,
      documentName: documentName,
      documentBytes: documentBytes != null ? Uint8List.fromList(documentBytes!) : null,
    );
  }
}

class EmployeeEmploymentEntry {
  String companyName;
  String designation;
  DateTime? fromDate;
  DateTime? toDate;
  String? documentName;
  Uint8List? documentBytes;

  EmployeeEmploymentEntry({
    this.companyName = '',
    this.designation = '',
    this.fromDate,
    this.toDate,
    this.documentName,
    this.documentBytes,
  });

  EmployeeEmploymentEntry copy() {
    return EmployeeEmploymentEntry(
      companyName: companyName,
      designation: designation,
      fromDate: fromDate != null ? DateTime.fromMillisecondsSinceEpoch(fromDate!.millisecondsSinceEpoch) : null,
      toDate: toDate != null ? DateTime.fromMillisecondsSinceEpoch(toDate!.millisecondsSinceEpoch) : null,
      documentName: documentName,
      documentBytes: documentBytes != null ? Uint8List.fromList(documentBytes!) : null,
    );
  }
}
