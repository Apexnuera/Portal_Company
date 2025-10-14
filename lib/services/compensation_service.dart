import 'package:flutter/foundation.dart';

// Data Models
class SalaryInfo {
  final double baseSalary;
  final double grossSalary;
  final String currency;
  final String payFrequency;
  final DateTime effectiveDate;
  final String salaryGrade;
  final Map<String, double> components;

  SalaryInfo({
    required this.baseSalary,
    required this.grossSalary,
    required this.currency,
    required this.payFrequency,
    required this.effectiveDate,
    required this.salaryGrade,
    required this.components,
  });
}

class Payslip {
  final String id;
  final DateTime payPeriod;
  final double grossPay;
  final double netPay;
  final double totalDeductions;
  final String status;
  final String downloadUrl;

  Payslip({
    required this.id,
    required this.payPeriod,
    required this.grossPay,
    required this.netPay,
    required this.totalDeductions,
    required this.status,
    required this.downloadUrl,
  });
}

class Bonus {
  final String type;
  final double amount;
  final DateTime date;
  final String description;
  final String status;

  Bonus({
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
  });
}

class Benefit {
  final String name;
  final String type;
  final String description;
  final double employerContribution;
  final double employeeContribution;
  final String status;

  Benefit({
    required this.name,
    required this.type,
    required this.description,
    required this.employerContribution,
    required this.employeeContribution,
    required this.status,
  });
}

class CompensationDocument {
  final String id;
  final String title;
  final String type;
  final DateTime date;
  final String downloadUrl;
  final String status;

  CompensationDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.downloadUrl,
    required this.status,
  });
}

class Reimbursement {
  final String id;
  final String type;
  final double amount;
  final DateTime submittedDate;
  final DateTime? processedDate;
  final String status;
  final String description;

  Reimbursement({
    required this.id,
    required this.type,
    required this.amount,
    required this.submittedDate,
    this.processedDate,
    required this.status,
    required this.description,
  });
}

class Deduction {
  final String name;
  final double amount;
  final String type;
  final String description;
  final List<DeductionBreakdown> breakdown;

  Deduction({
    required this.name,
    required this.amount,
    required this.type,
    required this.description,
    required this.breakdown,
  });
}

class DeductionBreakdown {
  final String component;
  final double amount;
  final String description;

  DeductionBreakdown({
    required this.component,
    required this.amount,
    required this.description,
  });
}

class CompensationPolicy {
  final String title;
  final String category;
  final String description;
  final List<String> keyPoints;

  CompensationPolicy({
    required this.title,
    required this.category,
    required this.description,
    required this.keyPoints,
  });
}

// Compensation Service
class CompensationService extends ChangeNotifier {
  CompensationService._internal();
  static final CompensationService instance = CompensationService._internal();

  // Sample data - in a real app, this would come from an API
  late SalaryInfo _salaryInfo;
  late List<Payslip> _payslips;
  late List<Bonus> _bonuses;
  late List<Benefit> _benefits;
  late List<CompensationDocument> _documents;
  late List<Reimbursement> _reimbursements;
  late List<Deduction> _deductions;
  late List<CompensationPolicy> _policies;

  // Getters
  SalaryInfo get salaryInfo => _salaryInfo;
  List<Payslip> get payslips => List.unmodifiable(_payslips);
  List<Bonus> get bonuses => List.unmodifiable(_bonuses);
  List<Benefit> get benefits => List.unmodifiable(_benefits);
  List<CompensationDocument> get documents => List.unmodifiable(_documents);
  List<Reimbursement> get reimbursements => List.unmodifiable(_reimbursements);
  List<Deduction> get deductions => List.unmodifiable(_deductions);
  List<CompensationPolicy> get policies => List.unmodifiable(_policies);

  void initialize() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Initialize with empty data - no sample records
    _salaryInfo = SalaryInfo(
      baseSalary: 0,
      grossSalary: 0,
      currency: 'INR',
      payFrequency: 'Monthly',
      effectiveDate: DateTime.now(),
      salaryGrade: '',
      components: {},
    );

    // Initialize empty lists - no sample data
    _payslips = [];
    _bonuses = [];
    _benefits = [];
    _documents = [];
    _reimbursements = [];
    _deductions = [];
    _policies = [];
  }

  String formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatMonthYear(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
