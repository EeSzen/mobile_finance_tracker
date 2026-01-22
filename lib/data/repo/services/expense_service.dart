import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/data/model/expense.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Stream<List<Expense>> getExpensesStream() {
    return _expenses
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => 
            Expense.fromMap(
              doc.data() as Map<String, dynamic>)
            ).toList());
  }
}
