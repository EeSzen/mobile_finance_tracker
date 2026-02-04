import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/data/enums/expenses_category.dart';
import 'package:fintrack/data/enums/payment_category.dart';

class Expense {
  final String? docId;
  final int amountCents;
  final ExpenseCategory category;
  final PaymentCategory paymentCategory;
  final String note;
  final DateTime timestamp;

  Expense({
    this.docId,
    required this.amountCents,
    required this.category,
    required this.paymentCategory,
    this.note = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'amountCents': amountCents,
      'category': category.key,
      'paymentCategory': paymentCategory.key,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, {required String docId}) {
    return Expense(
      docId: docId,
      amountCents: map['amountCents'],
      category: expenseCategoryFromString(map['category']),
      paymentCategory: paymentCategoryFromString(map['paymentCategory']),
      note: map['note'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  double get amount => amountCents / 100;

  Expense copy({String? docId}) {
    return Expense(
      docId: docId,
      amountCents: amountCents,
      category: category,
      paymentCategory: paymentCategory,
      note: note,
      timestamp: timestamp,
    );
  }
}
