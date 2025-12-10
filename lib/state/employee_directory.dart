import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import '../utils/document_picker.dart';
import '../services/employee_profile_service.dart';

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
    this.bankAccountHolderName = '',
    this.bankAccountNumber = '',
    this.bankIfscCode = '',
    this.bankName = '',
    this.bankDetailsLocked = false,
    this.currentProjectName = '',
    this.currentProjectDuration = '',
    this.currentProjectManager = '',
    List<ProjectAllocationEntry>? projectHistory,
  })  : assignedAssets = assignedAssets ?? <String>{},
        projectHistory = projectHistory ?? <ProjectAllocationEntry>[];

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
  String bankAccountHolderName;
  String bankAccountNumber;
  String bankIfscCode;
  String bankName;
  bool bankDetailsLocked;
  String currentProjectName;
  String currentProjectDuration;
  String currentProjectManager;
  List<ProjectAllocationEntry> projectHistory;

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
      bankAccountHolderName: bankAccountHolderName,
      bankAccountNumber: bankAccountNumber,
      bankIfscCode: bankIfscCode,
      bankName: bankName,
      bankDetailsLocked: bankDetailsLocked,
      currentProjectName: currentProjectName,
      currentProjectDuration: currentProjectDuration,
      currentProjectManager: currentProjectManager,
      projectHistory: projectHistory.map((e) => e.copy()).toList(),
    );
  }
}

class ProjectAllocationEntry {
  ProjectAllocationEntry({
    this.projectName = '',
    this.duration = '',
    this.reportingManager = '',
  });

  String projectName;
  String duration;
  String reportingManager;

  ProjectAllocationEntry copy() {
    return ProjectAllocationEntry(
      projectName: projectName,
      duration: duration,
      reportingManager: reportingManager,
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
    CompensationInfo? compensation,
    TaxInfo? tax,
  });

  final String id;
  String name;
  String primaryEmail;
  EmployeePersonalDetails personal;
  EmployeeProfessionalProfile professional;
  CompensationInfo compensation = CompensationInfo.empty();
  TaxInfo tax = TaxInfo.empty();

  EmployeeRecord copy() {
    return EmployeeRecord(
      id: id,
      name: name,
      primaryEmail: primaryEmail,
      personal: personal.copy(),
      professional: professional.copy(),
    )
      ..compensation = compensation.copy()
      ..tax = tax.copy();
  }
}

class EmployeeDirectory extends ChangeNotifier {
  static const String fallbackEmployeeId = 'EMP001';

  EmployeeDirectory() {
    _seedFallbackEmployee();
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

  void _seedFallbackEmployee() {
    if (!_employees.containsKey(fallbackEmployeeId)) {
      _employees[fallbackEmployeeId] = _createFallbackEmployeeRecord();
    }
    _primaryEmployeeId = fallbackEmployeeId;
  }

  void updatePersonalDetails(String id, EmployeePersonalDetails details) {
    final record = _employees[id];
    if (record == null) return;
    record.personal = details.copy();
    record.name = record.personal.fullName;
    record.primaryEmail = record.personal.corporateEmail;
    notifyListeners();
    
    // Sync to Supabase
    EmployeeProfileService.instance.updatePersonalDetails(details).catchError((e) {
      debugPrint('Failed to sync personal details to Supabase: $e');
    });
  }

  void updateProfessionalProfile(String id, EmployeeProfessionalProfile profile) {
    final record = _employees[id];
    if (record == null) return;
    record.professional = profile.copy();
    notifyListeners();
    
    // Sync to Supabase
    final currentProfile = EmployeeProfileService.instance.currentProfile;
    if (currentProfile != null && currentProfile.id == id) {
      // Updating own profile
      EmployeeProfileService.instance.updateProfessionalProfile(profile).catchError((e) {
        debugPrint('Failed to sync professional profile to Supabase: $e');
      });
    } else {
      // Updating another employee's profile (HR mode)
      EmployeeProfileService.instance.updateProfessionalProfileForEmployee(id, profile).catchError((e) {
        debugPrint('Failed to sync professional profile to Supabase (HR): $e');
      });
    }
  }

  void updateCompensation(String id, CompensationInfo data) {
    final record = _employees[id];
    if (record == null) return;
    record.compensation = data.copy();
    notifyListeners();
    
    // Sync to Supabase
    EmployeeProfileService.instance.updateCompensation(data).catchError((e) {
      debugPrint('Failed to sync compensation to Supabase: $e');
    });
  }

  void updateTax(String id, TaxInfo data) {
    final record = _employees[id];
    if (record == null) return;
    record.tax = data.copy();
    notifyListeners();
    
    // Sync to Supabase
    EmployeeProfileService.instance.updateTaxInfo(data).catchError((e) {
      debugPrint('Failed to sync tax info to Supabase: $e');
    });
  }

  void updateCompensationValue(String id, {double? basic, double? gross, double? net, double? travelAllowance}) {
    final record = _employees[id];
    if (record == null) return;
    if (basic != null) record.compensation.basic = basic;
    if (gross != null) record.compensation.gross = gross;
    if (net != null) record.compensation.net = net;
    if (travelAllowance != null) record.compensation.travelAllowance = travelAllowance;
    notifyListeners();
  }

  void addCompensationDocument(String id, String type, DocumentFile file) {
    final record = _employees[id];
    if (record == null) return;
    final doc = CompensationDocument(name: file.name, date: DateTime.now(), data: file.data);
    switch (type) {
      case 'Payslips':
        record.compensation.payslips.add(doc);
        break;
      case 'Bonuses and Incentives':
        record.compensation.bonusesAndIncentives.add(doc);
        break;
      case 'Benefits Summary':
        record.compensation.benefitsSummary.add(doc);
        break;
      case 'Compensation Letters / Agreements':
        record.compensation.compensationLetters.add(doc);
        break;
      case 'Offer Letters':
        record.compensation.offerLetters.add(doc);
        break;
      case 'Reimbursements':
        record.compensation.reimbursements.add(doc);
        break;
      case 'Compensation Policies and FAQs':
        record.compensation.compensationPolicies.add(doc);
        break;
    }
    notifyListeners();
  }

  void removeCompensationDocument(String id, String type, CompensationDocument doc) {
    final record = _employees[id];
    if (record == null) return;
    switch (type) {
      case 'Payslips':
        record.compensation.payslips.remove(doc);
        break;
      case 'Bonuses and Incentives':
        record.compensation.bonusesAndIncentives.remove(doc);
        break;
      case 'Benefits Summary':
        record.compensation.benefitsSummary.remove(doc);
        break;
      case 'Compensation Letters / Agreements':
        record.compensation.compensationLetters.remove(doc);
        break;
      case 'Offer Letters':
        record.compensation.offerLetters.remove(doc);
        break;
      case 'Reimbursements':
        record.compensation.reimbursements.remove(doc);
        break;
      case 'Compensation Policies and FAQs':
        record.compensation.compensationPolicies.remove(doc);
        break;
    }
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

  static EmployeeRecord _createFallbackEmployeeRecord() {
    final personal = EmployeePersonalDetails(
      fullName: 'John Doe',
      familyName: '',
      corporateEmail: 'john.doe@company.com',
      personalEmail: 'john.doe@example.com',
      mobileNumber: '',
      alternateMobileNumber: '',
      currentAddress: '',
      permanentAddress: '',
      panId: '',
      aadharId: '',
      dateOfBirth: null,
      bloodGroup: '',
      assignedAssets: <String>{},
      otherAssets: '',
      profileImageBytes: null,
      bankAccountHolderName: '',
      bankAccountNumber: '',
      bankIfscCode: '',
      bankName: '',
      bankDetailsLocked: false,
      currentProjectName: '',
      currentProjectDuration: '',
      currentProjectManager: '',
      projectHistory: <ProjectAllocationEntry>[],
    );

    final professional = EmployeeProfessionalProfile(
      position: '',
      employeeId: fallbackEmployeeId,
      department: '',
      managerName: '',
      employmentType: '',
      location: '',
      workSpace: '',
      jobLevel: '',
      skills: '',
    );

    final record = EmployeeRecord(
      id: fallbackEmployeeId,
      name: personal.fullName,
      primaryEmail: personal.corporateEmail,
      personal: personal,
      professional: professional,
    );
    record.compensation = CompensationInfo.empty();
    record.tax = TaxInfo.empty();
    return record;
  }
}

class CompensationDocument {
  CompensationDocument({
    required this.name,
    required this.date,
    required this.data,
  });

  final String name;
  final DateTime date;
  final Uint8List data;

  CompensationDocument copy() {
    return CompensationDocument(
      name: name,
      date: date,
      data: Uint8List.fromList(data),
    );
  }
}

class CompensationInfo {
  CompensationInfo({
    this.basic = 0.0,
    this.net = 0.0,
    this.gross = 0.0,
    this.travelAllowance = 0.0,
    List<CompensationDocument>? payslips,
    List<CompensationDocument>? bonusesAndIncentives,
    List<CompensationDocument>? benefitsSummary,
    List<CompensationDocument>? compensationLetters,
    List<CompensationDocument>? offerLetters,
    List<CompensationDocument>? reimbursements,
    List<CompensationDocument>? compensationPolicies,
  })  : payslips = payslips ?? <CompensationDocument>[],
        bonusesAndIncentives = bonusesAndIncentives ?? <CompensationDocument>[],
        benefitsSummary = benefitsSummary ?? <CompensationDocument>[],
        compensationLetters = compensationLetters ?? <CompensationDocument>[],
        offerLetters = offerLetters ?? <CompensationDocument>[],
        reimbursements = reimbursements ?? <CompensationDocument>[],
        compensationPolicies = compensationPolicies ?? <CompensationDocument>[];

  double basic;
  double net;
  double gross;
  double travelAllowance;
  List<CompensationDocument> payslips;
  List<CompensationDocument> bonusesAndIncentives;
  List<CompensationDocument> benefitsSummary;
  List<CompensationDocument> compensationLetters;
  List<CompensationDocument> offerLetters;
  List<CompensationDocument> reimbursements;
  List<CompensationDocument> compensationPolicies;

  CompensationInfo copy() {
    return CompensationInfo(
      basic: basic,
      net: net,
      gross: gross,
      travelAllowance: travelAllowance,
      payslips: payslips.map((d) => d.copy()).toList(),
      bonusesAndIncentives: bonusesAndIncentives.map((d) => d.copy()).toList(),
      benefitsSummary: benefitsSummary.map((d) => d.copy()).toList(),
      compensationLetters: compensationLetters.map((d) => d.copy()).toList(),
      offerLetters: offerLetters.map((d) => d.copy()).toList(),
      reimbursements: reimbursements.map((d) => d.copy()).toList(),
      compensationPolicies: compensationPolicies.map((d) => d.copy()).toList(),
    );
  }

  factory CompensationInfo.empty() => CompensationInfo();
}

class TaxInfo {
  TaxInfo({this.regime = ''}); // 'New' or 'Old'
  String regime;

  TaxInfo copy() => TaxInfo(regime: regime);

  factory TaxInfo.empty() => TaxInfo();
}
