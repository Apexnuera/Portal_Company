/// Comprehensive validation utilities for the Company Portal
/// Includes email, password, mobile, DOB, PAN, Aadhaar validations

class Validators {
  // Email validation - supports common email formats
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }
    
    final email = value.trim();
    
    // Comprehensive email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email (e.g., example@gmail.com)';
    }
    
    return null;
  }

  // Password validation - must start with capital letter, include numbers, symbols, lowercase, exactly 10 characters
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    
    if (value.length != 10) {
      return 'Password must be exactly 10 characters';
    }
    
    // Check if starts with capital letter
    if (!RegExp(r'^[A-Z]').hasMatch(value)) {
      return 'Password must start with a capital letter';
    }
    
    // Check for lowercase letters
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain lowercase letters';
    }
    
    // Check for numbers
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain numbers';
    }
    
    // Check for symbols
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;~`]').hasMatch(value)) {
      return 'Password must contain symbols';
    }
    
    return null;
  }

  // Mobile number validation - exactly 10 digits, numbers only
  static String? validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }
    
    final mobile = value.trim();
    
    // Check if contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      return 'Mobile number must contain only numbers';
    }
    
    // Check if exactly 10 digits
    if (mobile.length != 10) {
      return 'Mobile number must be exactly 10 digits';
    }
    
    return null;
  }

  // Date of Birth validation - not today, age must be > 18
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Please select date of birth';
    }
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(value.year, value.month, value.day);
    
    // Check if selected date is today
    if (selectedDate.isAtSame(todayDate)) {
      return 'Date of birth cannot be today';
    }
    
    // Check if date is in future
    if (selectedDate.isAfter(todayDate)) {
      return 'Date of birth cannot be in future';
    }
    
    // Calculate age
    final age = today.year - value.year;
    final monthDiff = today.month - value.month;
    final dayDiff = today.day - value.day;
    
    final actualAge = (monthDiff < 0 || (monthDiff == 0 && dayDiff < 0)) ? age - 1 : age;
    
    if (actualAge < 18) {
      return 'Employee must be at least 18 years old';
    }
    
    return null;
  }

  // PAN validation - format: ABCDE1234F
  static String? validatePAN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // PAN is optional in most cases
    }
    
    final pan = value.trim().toUpperCase();
    
    // PAN format: 5 letters, 4 digits, 1 letter
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    
    if (!panRegex.hasMatch(pan)) {
      return 'Invalid PAN format (e.g., ABCDE1234F)';
    }
    
    return null;
  }

  // Aadhaar validation - exactly 12 digits
  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Aadhaar is optional in most cases
    }
    
    final aadhaar = value.trim().replaceAll(' ', '');
    
    // Check if contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(aadhaar)) {
      return 'Aadhaar must contain only numbers';
    }
    
    // Check if exactly 12 digits
    if (aadhaar.length != 12) {
      return 'Aadhaar must be exactly 12 digits';
    }
    
    return null;
  }

  // Employee ID validation - alphanumeric
  static String? validateEmployeeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter employee ID';
    }
    
    final empId = value.trim();
    
    // Allow alphanumeric characters, hyphens, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(empId)) {
      return 'Employee ID can only contain letters, numbers, hyphens, and underscores';
    }
    
    if (empId.length < 3) {
      return 'Employee ID must be at least 3 characters';
    }
    
    return null;
  }

  // Name validation - alphabets and spaces only
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    
    final name = value.trim();
    
    // Allow alphabets, spaces, dots, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(name)) {
      return '$fieldName can only contain letters';
    }
    
    if (name.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Salary/Amount validation
  static String? validateAmount(String? value, {String fieldName = 'Amount'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    
    final amount = value.trim();
    
    // Allow numbers and optional decimal point
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(amount)) {
      return '$fieldName must be a valid number';
    }
    
    final numValue = double.tryParse(amount);
    if (numValue == null || numValue < 0) {
      return '$fieldName must be a positive number';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}

// Extension to check if two dates are the same day
extension DateTimeComparison on DateTime {
  bool isAtSame(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
