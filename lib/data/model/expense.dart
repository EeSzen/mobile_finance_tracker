import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/data/enums/expenses_category.dart';

class Expense {
  final String? docId;
  final int amountCents;
  final ExpenseCategory category;
  final String note;
  final DateTime timestamp;

  Expense({
    this.docId,
    required this.amountCents,
    required this.category,
    this.note = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'amountCents': amountCents,
      'category': category.key, // STRING stored
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Expense(
      docId: docId,
      amountCents: map['amountCents'],
      category: expenseCategoryFromString(map['category']),
      note: map['note'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Expense copy({String? docId}) {
    return Expense(
      docId: docId ?? this.docId,
      amountCents: amountCents,
      category: category,
      note: note,
      timestamp: timestamp,
    );
  }
}
