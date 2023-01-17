import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:palakat/shared/utils.dart';
import 'dart:developer' as dev;

class FirestoreService {
  FirebaseFirestore firestore;

  FirestoreService() : firestore = FirebaseFirestore.instance;

  // ignore: unused_field
  final String _keyCollectionApp = 'app';
  // ignore: unused_field
  final String _keyCollectionChurches = 'churches';
  // ignore: unused_field
  final String _keyCollectionEvents = 'events';
  // ignore: unused_field
  final String _keyCollectionMembership = 'membership';
  // ignore: unused_field
  final String _keyCollectionUsers = 'users';

  dynamic firestoreLogger(
    dynamic Function() request,
    String? operation,
  ) async {
    operation = operation ?? 'logging';
    try {
      final res = request();
      dev.log('[FIRESTORE] $operation SUCCESS');
      return res;
    } catch (e) {
      dev.log('[FIRESTORE] $operation ERROR');
      dev.log(e.toString());
      return null;
    }
  }

  ///can get user from id or phone
  Future<Object?> getUser({required String phoneOrId}) async {
    final isPhoneNumber = phoneOrId.isNumericOnly;
    final col = firestore.collection(_keyCollectionUsers);

    if (isPhoneNumber) {
      final phone = phoneOrId.cleanPhone();
      DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreLogger(
        col.where("phone", isEqualTo: phone).get,
        'getUser(phone)',
      );
      return doc!.data();
    }

    final id = phoneOrId;
    DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreLogger(
      col.doc(id).get,
      'getUser(user_id)',
    );
    return doc!.data();
  }

  Future<Object?> getMembership({required String id}) async {
    final col = firestore.collection(_keyCollectionMembership);
    DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreLogger(
      col.doc(id).get,
      'getMembership',
    );
    return doc!.data();
  }

  Future<Object?> getChurch({required String id}) async {
    final col = firestore.collection(_keyCollectionChurches);
    DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreLogger(
      col.doc(id).get,
      'getChurch',
    );
    return doc!.data();
  }}
