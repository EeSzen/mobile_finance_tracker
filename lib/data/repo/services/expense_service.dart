import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/data/model/expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

class ExpenseService {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _expenses =>
      _db.collection("fintrack_users").doc(userId).collection("expenses");

  Future<void> addExpense(Expense expense) async {
    await _expenses.add(expense.toMap());
  }

  Future<void> updateExpense(String docId, Expense expense) async {
    await _expenses.doc(docId).update(expense.toMap());
  }

  Future<void> deleteExpense(String docId) async {
    await _expenses.doc(docId).delete();
  }

  Future<Expense?> getExpenseById(String docId) async {
    try {
      final doc = await _expenses.doc(docId).get();
      if (!doc.exists) return null;
      
      return Expense.fromMap(
        doc.data() as Map<String, dynamic>,
        docId: doc.id,
      );
    } catch (e) {
      debugPrint('Error fetching expense: $e');
      return null;
    }
  }

  Stream<List<Expense>> getExpensesStream() {
    return _expenses
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => 
            Expense.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id
              )
            ).toList());
  }
}
