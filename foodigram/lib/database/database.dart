import 'package:cloud_firestore/cloud_firestore.dart';

class CloudBaseHandler {
  final CollectionReference _firestoreRef =
      FirebaseFirestore.instance.collection('posts');

  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection("users");

  Future<void> addUser(Map<String, dynamic> account) {
    return _usersRef.doc(account['uid']).set(account);
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return _usersRef.doc(uid).get();
  }

  Future<void> updateUser(Map<String, dynamic> data, String uid) {
    return _usersRef.doc(uid).update(data);
  }

  Future<QuerySnapshot> getDataCollection() {
    return _firestoreRef.orderBy('timestamp').get();
  }

  Stream<QuerySnapshot> streamDataCollection() {
    return _firestoreRef.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return _firestoreRef.doc(id).get();
  }

  Future<void> removeDocument(String id) {
    return _firestoreRef.doc(id).delete();
  }

  Future<DocumentReference> addDocument(Map<String, dynamic> data) {
    return _firestoreRef.add(data);
  }

  Future<void> updateDocument(Map<String, dynamic> data, String id) {
    return _firestoreRef.doc(id).set(data);
  }
}
