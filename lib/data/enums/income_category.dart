import 'package:flutter/material.dart';

extension IncomeCategoryX on IncomeCategory {
  /// Value stored in Firestore
  String get key => name;

  /// Human-readable label
  String get label {
    switch (this) {
      case IncomeCategory.salary:
        return 'Salary';
      case IncomeCategory.freelance:
        return 'Freelance';
      case IncomeCategory.investment:
        return 'Investment';
      case IncomeCategory.other:
        return 'Other';
    }
  }

  /// Icon for UI
  IconData get icon {
    switch (this) {
      case IncomeCategory.salary:
        return Icons.attach_money;
      case IncomeCategory.freelance:
        return Icons.work;
      case IncomeCategory.investment:
        return Icons.trending_up;
      case IncomeCategory.other:
        return Icons.money;
    }
  }
}

IncomeCategory incomeCategoryFromString(String value) {
  return IncomeCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => IncomeCategory.salary, // safe fallback
  );
}

enum IncomeCategory {
  salary,
  freelance,
  investment,
  other,
}
