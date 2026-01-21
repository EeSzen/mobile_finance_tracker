import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/data/model/revenue.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

class RevenueService {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _revenues =>
      _db.collection("fintrack_users").doc(userId).collection("Revenues");

  Future<void> addRevenue(Revenue revenue) async {
    await _revenues.add(revenue.toMap());
  }

  Future<void> updateRevenue(String docId, Revenue revenue) async {
    await _revenues.doc(docId).update(revenue.toMap());
  }

  Future<void> deleteRevenue(String docId) async {
    await _revenues.doc(docId).delete();
  }

  Stream<List<Revenue>> getRevenuesStream() {
    return _revenues
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => 
            Revenue.fromMap(
              doc.data() as Map<String, dynamic>)
            ).toList());
  }
}
