import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/data/model/users.dart';

class UserRepo {
  final _db = FirebaseFirestore.instance;

  Future<AppUser> getUser(String uid)async{
    final doc = await _db.collection("fintrack_users").doc(uid).get();

    if (!doc.exists) {
      throw Exception("User document missing");
    }

    return AppUser.fromMap(uid, doc.data()!);
  }
}