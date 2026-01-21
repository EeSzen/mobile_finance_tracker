
import 'package:flutter/material.dart';

extension ExpenseCategoryX on ExpenseCategory {
  /// Value stored in Firestore
  String get key => name;

  /// Human-readable label
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
    }
  }

  /// Icon for UI
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.fastfood;
      case ExpenseCategory.transport:
        return Icons.directions_bus;
      case ExpenseCategory.rent:
        return Icons.request_quote_outlined;
      case ExpenseCategory.utilities:
        return Icons.lightbulb;
      case ExpenseCategory.entertainment:
        return Icons.movie;
    }
  }
}

ExpenseCategory expenseCategoryFromString(String value) {
  return ExpenseCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ExpenseCategory.food, // safe fallback
  );
}


enum ExpenseCategory {
  food,
  transport,
  rent,
  utilities,
  entertainment,
}
