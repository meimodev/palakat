import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtil {
  static CollectionReference<Map<String, dynamic>> get accounts =>
      FirebaseFirestore.instance.collection("accounts");

  static CollectionReference<Map<String, dynamic>> get memberships =>
      FirebaseFirestore.instance.collection("membership");

  static CollectionReference<Map<String, dynamic>> get churches =>
      FirebaseFirestore.instance.collection("churches");

  static CollectionReference<Map<String, dynamic>> get columns =>
      FirebaseFirestore.instance.collection("columns");

  static CollectionReference<Map<String, dynamic>> get activities =>
      FirebaseFirestore.instance.collection("activities");
}
