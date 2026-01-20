// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/widgets.dart';
// import 'package:my_app/data/model/task.dart';

// class TodoRepoFireImpl {
//   static final TodoRepoFireImpl _instance = TodoRepoFireImpl._internal();
//   TodoRepoFireImpl._internal();

//   factory TodoRepoFireImpl(){
//     return _instance;
//   }

//   final _collection = FirebaseFirestore.instance.collection("todos");

//   Stream<List<Task>> getAllTasks(){
//     return _collection.snapshots().map((event) {
//       return event.docs.map((doc){
//         debugPrint("********************");
//         debugPrint(doc.data().toString());
//         debugPrint("********************");
//         return Task .fromMap(doc.data()).copy(docId: doc.id);
//       }).toList();
//     });
//   }

//   Future<Task?> getTaskById(String docId) async {
//     final res = await _collection.doc(docId).get();
//     if(res.data() == null){
//       return null;
//     }

//     return Task.fromMap(res.data()!).copy(docId: res.id);
//   }

//   Future<void> addTask(Task task) async {
//     await _collection.add(task.toMap());
//   }

//   Future<void> updateTask(Task task) async {
//     await _collection.doc(task.docId!).set(task.toMap());
//   }

//   Future<void> deleteTask(String docId) async {
//     await _collection.doc(docId).delete();
//   }

// }