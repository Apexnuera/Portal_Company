import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class EmployeeProfile {
  final String employeeId;
  final String fullName;
  final String familyName;
  final String corporateEmail;
  final String personalEmail;
  final String mobileNumber;
  final String alternateMobileNumber;
  final String currentAddress;
  final String permanentAddress;
  final String panId;
  final String aadharId;
  final DateTime? dateOfBirth;
  final String bloodGroup;
  final Uint8List? profileImageBytes;

  const EmployeeProfile({
    required this.employeeId,
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
    required this.profileImageBytes,
  });

  factory EmployeeProfile.initial() {
    return EmployeeProfile(
      employeeId: 'EMP001',
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
      profileImageBytes: null,
    );
  }

  EmployeeProfile copyWith({
    String? employeeId,
    String? fullName,
    String? familyName,
    String? corporateEmail,
    String? personalEmail,
    String? mobileNumber,
    String? alternateMobileNumber,
    String? currentAddress,
    String? permanentAddress,
    String? panId,
    String? aadharId,
    DateTime? dateOfBirth,
    String? bloodGroup,
    Uint8List? profileImageBytes,
    bool resetProfileImageBytes = false,
  }) {
    return EmployeeProfile(
      employeeId: employeeId ?? this.employeeId,
      fullName: fullName ?? this.fullName,
      familyName: familyName ?? this.familyName,
      corporateEmail: corporateEmail ?? this.corporateEmail,
      personalEmail: personalEmail ?? this.personalEmail,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      alternateMobileNumber: alternateMobileNumber ?? this.alternateMobileNumber,
      currentAddress: currentAddress ?? this.currentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      panId: panId ?? this.panId,
      aadharId: aadharId ?? this.aadharId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      profileImageBytes: resetProfileImageBytes
          ? profileImageBytes
          : (profileImageBytes ?? this.profileImageBytes),
    );
  }
}

class EmployeeProfileManager extends ChangeNotifier {
  EmployeeProfileManager._();

  static final EmployeeProfileManager instance = EmployeeProfileManager._();

  EmployeeProfile _profile = EmployeeProfile.initial();

  EmployeeProfile get profile => _profile;

  void updatePersonalDetails({
    required String fullName,
    required String familyName,
    required String corporateEmail,
    required String personalEmail,
    required String mobileNumber,
    required String alternateMobileNumber,
    required String currentAddress,
    required String permanentAddress,
    required String panId,
    required String aadharId,
    required DateTime? dateOfBirth,
    required String bloodGroup,
  }) {
    _profile = _profile.copyWith(
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
      dateOfBirth: dateOfBirth,
      bloodGroup: bloodGroup,
    );
    notifyListeners();
  }

  void updateProfileImage(Uint8List? bytes) {
    _profile = _profile.copyWith(
      profileImageBytes: bytes,
      resetProfileImageBytes: true,
    );
    notifyListeners();
  }

  void loadFromRecord({
    required String employeeId,
    required String fullName,
    required String corporateEmail,
  }) {
    _profile = _profile.copyWith(
      employeeId: employeeId,
      fullName: fullName,
      corporateEmail: corporateEmail,
    );
    notifyListeners();
  }
}
