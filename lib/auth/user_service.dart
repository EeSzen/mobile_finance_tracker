import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createUserIfNotExists(User user) async {
  final userRef =
      FirebaseFirestore.instance.collection('fintrack_users').doc(user.uid);

  final snapshot = await userRef.get();

  if (!snapshot.exists) {
    await userRef.set({
      'email': user.email,
      'displayName': user.displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
  